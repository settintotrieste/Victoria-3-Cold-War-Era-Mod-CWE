Includes = {
	"cw/pdxterrain.fxh"
	"cw/heightmap.fxh"
	"cw/utility.fxh"
	"cw/lighting.fxh"
	"cw/shadow.fxh"
	"cw/camera.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_province_overlays.fxh"
	"jomini/jomini_water.fxh"
	"lowspec_terrain.fxh"
	"sharedconstants.fxh"
	"standardfuncsgfx.fxh"
	"distance_fog.fxh"
	"coloroverlay.fxh"
	"dynamic_masks.fxh"
	"fog_of_war.fxh"
	"ssao_struct.fxh"
}


VertexStruct VS_OUTPUT_PDX_TERRAIN
{
	float4 Position			: PDX_POSITION;
	float3 WorldSpacePos	: TEXCOORD0;
	float4 ShadowProj		: TEXCOORD1;
};

VertexStruct VS_OUTPUT_PDX_TERRAIN_SHADOW
{
	float4 Position			: PDX_POSITION;
};

VertexShader =
{
	Code
	[[
		VS_OUTPUT_PDX_TERRAIN TerrainVertex( float2 WithinNodePos, float2 NodeOffset, float NodeScale, float2 LodDirection, float LodLerpFactor )
		{
			STerrainVertex Vertex = CalcTerrainVertex( WithinNodePos, NodeOffset, NodeScale, LodDirection, LodLerpFactor );

			#ifdef TERRAIN_FLAT_MAP_LERP
				Vertex.WorldSpacePos.y = lerp( Vertex.WorldSpacePos.y, FlatMapHeight, FlatMapLerp );
			#endif
			#ifdef TERRAIN_FLAT_MAP
				Vertex.WorldSpacePos.y = FlatMapHeight;
			#endif

			VS_OUTPUT_PDX_TERRAIN Out;
			Out.WorldSpacePos = Vertex.WorldSpacePos;

			Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Vertex.WorldSpacePos, 1.0 ) );
			Out.ShadowProj = mul( ShadowMapTextureMatrix, float4( Vertex.WorldSpacePos, 1.0 ) );

			return Out;
		}
	]]

	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_TERRAIN"
		Output = "VS_OUTPUT_PDX_TERRAIN"
		Code
		[[
			PDX_MAIN
			{
				return TerrainVertex( Input.UV, Input.NodeOffset_Scale_Lerp.xy, Input.NodeOffset_Scale_Lerp.z, Input.LodDirection, Input.NodeOffset_Scale_Lerp.w );
			}
		]]
	}

	MainCode VertexShaderSkirt
	{
		Input = "VS_INPUT_PDX_TERRAIN_SKIRT"
		Output = "VS_OUTPUT_PDX_TERRAIN"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_PDX_TERRAIN Out = TerrainVertex( Input.UV, Input.NodeOffset_Scale_Lerp.xy, Input.NodeOffset_Scale_Lerp.z, Input.LodDirection, Input.NodeOffset_Scale_Lerp.w );

				float3 Position = FixPositionForSkirt( Out.WorldSpacePos, Input.VertexID );
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Position, 1.0 ) );

				return Out;
			}
		]]
	}

		MainCode VertexShaderShadow
	{
		Input = "VS_INPUT_PDX_TERRAIN"
		Output = "VS_OUTPUT_PDX_TERRAIN_SHADOW"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_PDX_TERRAIN_SHADOW Out;
				Out.Position = TerrainVertex( Input.UV, Input.NodeOffset_Scale_Lerp.xy, Input.NodeOffset_Scale_Lerp.z, Input.LodDirection, Input.NodeOffset_Scale_Lerp.w ).Position;
				return Out;
			}
		]]
	}

	MainCode VertexShaderShadowSkirt
	{
		Input = "VS_INPUT_PDX_TERRAIN_SKIRT"
		Output = "VS_OUTPUT_PDX_TERRAIN_SHADOW"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_PDX_TERRAIN TerrainVert = TerrainVertex( Input.UV, Input.NodeOffset_Scale_Lerp.xy, Input.NodeOffset_Scale_Lerp.z, Input.LodDirection, Input.NodeOffset_Scale_Lerp.w );
				float3 Position = FixPositionForSkirt( TerrainVert.WorldSpacePos, Input.VertexID );

				VS_OUTPUT_PDX_TERRAIN_SHADOW Out;
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Position, 1.0 ) );

				return Out;
			}
		]]
	}
}



PixelShader =
{
	# PdxTerrain uses texture index 0 - 6

	# Jomini specific
	TextureSampler ShadowMap
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		CompareFunction = less_equal
		SamplerType = "Compare"
	}

	# Game specific
	TextureSampler EnvironmentMap
	{
		Ref = JominiEnvironmentMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		Type = "Cube"
	}
	TextureSampler FlatMapTexture
	{
		Ref = TerrainFlatMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Clamp"
	}

	Code
	[[
		void CropToWorldSize( in VS_OUTPUT_PDX_TERRAIN Input )
		{
			float LerpFactor = saturate( ( Input.Position.z - 0.9 ) * 10.0 );
			clip( vec2(1.0) - ( Input.WorldSpacePos.xz - float2( lerp( 0.1, 2.0, LerpFactor ), 0.0 ) ) * WorldSpaceToTerrain0To1 );
		}
	]]

	MainCode PixelShader
	{
		Input = "VS_OUTPUT_PDX_TERRAIN"
		Output = "PS_COLOR_SSAO"
		Code
		[[
			float3 GameCalculateEnvironmentLighting( SMaterialProperties MaterialProps, SLightingProperties LightingProps )
			{
				float3 DiffuseIBL = vec3( 0.0f );
				float3 SpecularIBL = vec3( 0.0f );

				// Cubemap Diffuse light
				float3 RotatedDiffuseCubemapUV = mul( CastTo3x3( LightingProps._CubemapYRotation ), MaterialProps._Normal );
				float3 DiffuseRad = PdxTexCubeLod( EnvironmentMap, RotatedDiffuseCubemapUV, ( PDX_NumMips - 1 - PDX_MipOffset ) ).rgb * LightingProps._CubemapIntensity; // TODO, maybe we should split diffuse and spec intensity?
				DiffuseIBL = DiffuseRad * MaterialProps._DiffuseColor;

				// Cubemap specular light
				float3 ReflectionVector = reflect( -LightingProps._ToCameraDir, MaterialProps._Normal );
				float3 DominantReflectionVector = GetSpecularDominantDir( MaterialProps._Normal, ReflectionVector, MaterialProps._Roughness );

				float NdotR = saturate( dot( MaterialProps._Normal, DominantReflectionVector ) );
				float3 SpecularReflection = F_Schlick( MaterialProps._SpecularColor, vec3(1.0), NdotR );
				float SpecularFade = GetReductionInMicrofacets( MaterialProps._Roughness );

				float MipLevel = BurleyToMipSimple( MaterialProps._PerceptualRoughness );
				float3 RotatedSpecularCubemapUV = mul( CastTo3x3( LightingProps._CubemapYRotation ), DominantReflectionVector );
				float3 SpecularRad = PdxTexCubeLod( EnvironmentMap, RotatedSpecularCubemapUV, MipLevel ).rgb * LightingProps._CubemapIntensity; // TODO, maybe we should split diffuse and spec intensity?
				SpecularIBL = SpecularRad * SpecularFade * SpecularReflection;

				return DiffuseIBL + SpecularIBL;
			}

			float3 GameCalculateSunLighting( SMaterialProperties MaterialProps, SLightingProperties LightingProps, float3 WorldSpacePos, inout float IridescenceMask  )
			{
				float3 DiffuseLight = vec3( 0.0f );
				float3 SpecularLight = vec3( 0.0f );

				// Light vectors
				float3 H = normalize( LightingProps._ToCameraDir + LightingProps._ToLightDir );
				float NdotV = abs( dot( MaterialProps._Normal, LightingProps._ToCameraDir ) ) + 1e-5;
				float NdotL = saturate( dot( MaterialProps._Normal, LightingProps._ToLightDir ) );
				float NdotH = saturate( dot( MaterialProps._Normal, H ) );
				float LdotH = saturate( dot( LightingProps._ToLightDir, H ) );
				float3 LightIntensity = LightingProps._LightIntensity * NdotL * LightingProps._ShadowTerm;

				// Sun diffuse light
				float DiffuseBRDF = CalcDiffuseBRDF( NdotV, NdotL, LdotH, MaterialProps._PerceptualRoughness );
				DiffuseLight = DiffuseBRDF * MaterialProps._DiffuseColor * LightIntensity;

				// Iridescense for sun specular
				GetIridescense( MaterialProps, NdotV, EnvironmentMap, WorldSpacePos, IridescenceMask );

				// Sun specular light
				float3 F = F_Schlick( MaterialProps._SpecularColor, vec3( 1.0f ), LdotH );
				float D = D_GGX( NdotH, lerp( 0.03f , 1.0f , MaterialProps._Roughness ) );		// Remap to avoid super small and super bright highlights
				#ifdef PDX_SimpleLighting
					float Vis = V_Optimized( LdotH, MaterialProps._Roughness );
				#else
					float Vis = V_Schlick( NdotL, NdotV, MaterialProps._Roughness );
				#endif
				Vis = lerp( Vis, 1.0f, IridescenceMask );				// Iridescence calculates its own fresnel
				SpecularLight = D * F * Vis * LightIntensity;

				// Iridescense rimlight specular
				#ifdef HIGH_QUALITY_SHADERS
					CalculateIridescenceRimlight( MaterialProps, LightingProps, SpecularLight, IridescenceMask );
				#endif

				return DiffuseLight + SpecularLight;
			}

			PDX_MAIN
			{
				PS_COLOR_SSAO Out;

				CropToWorldSize( Input );
				#ifndef UNDERWATER
					clip( GetHeight( Input.WorldSpacePos.xz ) - _WaterHeight + 1.0 ); // +0.1 to avoid gap between water and mesh
				#endif

				// Materials
				float4 DetailDiffuse = vec4( 1.0 );
				float3 DetailNormal = vec3( 1.0 );
				float4 DetailMaterial = vec4( 1.0 );

				// UV Coordinates
				float2 MapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				float2 ProvinceCoords = Input.WorldSpacePos.xz / ProvinceMapSize;

				// Get terrain material
				CalculateDetails( Input.WorldSpacePos.xz, DetailDiffuse, DetailNormal, DetailMaterial );

				float IridescenceMask = 0.0f;
				#ifndef UNDERWATER
					// Dynamic mask alpha
					ApplyPollutionMaterial( DetailDiffuse, DetailNormal, DetailMaterial, Input.WorldSpacePos.xz, IridescenceMask );
					ApplyDevastationMaterial( DetailDiffuse, DetailNormal, DetailMaterial, Input.WorldSpacePos.xz );
				#endif

				// Normals
				float3 Normal = CalculateNormal( Input.WorldSpacePos.xz );
				float3 ReorientedNormal = ReorientNormal( Normal, DetailNormal );

				// Colormap overlay
				float3 ColorMap = PdxTex2D( ColorTexture, float2( MapCoords.x, 1.0 - MapCoords.y ) ).rgb;
				float3 Diffuse = SoftLight( DetailDiffuse.rgb, ColorMap, ( 1 - DetailMaterial.r ) );

				// Border color overlay
				float3 ColorOverlay;
				float PreLightingBlend;
				float PostLightingBlend;

				#ifndef UNDERWATER
					GameProvinceOverlayAndBlend( ProvinceCoords, Input.WorldSpacePos, ColorOverlay, PreLightingBlend, PostLightingBlend );
					Diffuse = ApplyColorOverlay( Diffuse, ColorOverlay, saturate( PreLightingBlend ) );
				#endif

				// Light and shadow
				float ShadowTerm = CalculateShadow( Input.ShadowProj, ShadowMap );

				DetailMaterial.a = ScaleRoughnessByDistance( DetailMaterial.a, Input.WorldSpacePos );
				SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse, ReorientedNormal, DetailMaterial.a, DetailMaterial.g, DetailMaterial.b );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTerm );

				float3 FinalColor = GameCalculateEnvironmentLighting( MaterialProps, LightingProps );
				FinalColor += GameCalculateSunLighting( MaterialProps, LightingProps, Input.WorldSpacePos, IridescenceMask );

				#ifndef UNDERWATER
					// Effects, post light
					#ifdef TERRAIN_COLOR_OVERLAY
						FinalColor = ApplyColorOverlay( FinalColor, ColorOverlay, PostLightingBlend );
					#endif
					FinalColor = ApplyFogOfWar( FinalColor, Input.WorldSpacePos );
					FinalColor = GameApplyDistanceFog( FinalColor, Input.WorldSpacePos );

					// Blend from Terrain to Flatmap
					#ifdef TERRAIN_FLAT_MAP_LERP
						// Flatmap texture and style
						float3 FlatMap = PdxTex2D( FlatMapTexture, float2( MapCoords.x, 1.0 - MapCoords.y ) ).rgb;
						FlatMap = lerp(FlatMap, ApplyDynamicFlatmap( FlatMap, ProvinceCoords, Input.WorldSpacePos.xz ), 0.25);

						// Border color overlay on flatmap
						FlatMap *= lerp( vec3( 1.0 ), ColorOverlay, saturate( PreLightingBlend + PostLightingBlend ) );
						FinalColor = lerp( FinalColor, FlatMap, FlatMapLerp );
					#endif

					// Highlight color overlay
					#ifdef TERRAIN_COLOR_OVERLAY
						FinalColor = ApplyHighlight( FinalColor, ProvinceCoords );
					#endif
				#endif //not UNDERWATER

				// Underwater
				float Alpha = 1.0;
				#ifdef UNDERWATER
					Alpha = CompressWorldSpace( Input.WorldSpacePos );
				#endif

				// Debug
				#ifdef TERRAIN_DEBUG
					TerrainDebug( FinalColor, Input.WorldSpacePos );
				#endif
				DebugReturn( FinalColor, MaterialProps, LightingProps, EnvironmentMap );

				// Output
				Out.Color = float4( FinalColor, Alpha );
				float3 SSAOAlphaFixed = vec3( 1.0f ) - SSAOAlphaTerrain; // Reduces the applied SSAO on terrain
				#ifndef UNDERWATER
					#ifdef TERRAIN_COLOR_OVERLAY
						SSAOAlphaFixed = SSAOAlphaFixed + PostLightingBlend;
					#endif
				#endif
				Out.SSAOColor = float4( saturate( SSAOAlphaFixed ), saturate( Alpha - GameCalculateDistanceFogFactor ( Input.WorldSpacePos ) ) );

				return Out;
			}
		]]
	}

	MainCode PixelShaderLowSpec
	{
		Input = "VS_OUTPUT_PDX_TERRAIN_LOW_SPEC"
		Output = "PS_COLOR_SSAO"
		Code
		[[
			PDX_MAIN
			{
				PS_COLOR_SSAO Out;

				float LerpFactor = saturate( ( Input.Position.z - 0.9 ) * 10.0 );
				clip( vec2(1.0) - ( Input.WorldSpacePos.xz - float2( lerp( 0.1, 2.0, LerpFactor ), 0.0 ) ) * WorldSpaceToTerrain0To1 );

				float3 DetailDiffuse = Input.DetailDiffuse;
				float4 DetailMaterial = Input.DetailMaterial;
				float3 ColorMap = Input.ColorMap;
				float3 FlatMap = Input.FlatMap;
				float3 Normal = Input.Normal;

				// UV Coordinates
				float2 MapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				float2 ProvinceCoords = Input.WorldSpacePos.xz / ProvinceMapSize;

				// Colormap overlay
				float3 Diffuse = SoftLight( DetailDiffuse.rgb, ColorMap, ( 1 - DetailMaterial.r ) );

				// Border color overlay
				float3 ColorOverlay;
				float PreLightingBlend;
				float PostLightingBlend;
				GameProvinceOverlayAndBlend( ProvinceCoords, Input.WorldSpacePos, ColorOverlay, PreLightingBlend, PostLightingBlend );
				Diffuse = ApplyColorOverlay( Diffuse, ColorOverlay, saturate( PreLightingBlend ) );

				#ifndef UNDERWATER
					// Effects, post light
					#ifdef TERRAIN_COLOR_OVERLAY
						Diffuse = ApplyColorOverlay( Diffuse, ColorOverlay, PostLightingBlend );
					#endif
					Diffuse = ApplyFogOfWar( Diffuse, Input.WorldSpacePos );
					Diffuse = GameApplyDistanceFog( Diffuse, Input.WorldSpacePos );

					// Blend from Terrain to Flatmap
					#ifdef TERRAIN_FLAT_MAP_LERP
						// Flatmap texture and style
						FlatMap = lerp(FlatMap, ApplyDynamicFlatmap( FlatMap, ProvinceCoords, Input.WorldSpacePos.xz ), 0.25);

						// Border color overlay on flatmap
						FlatMap *= lerp( vec3( 1.0 ), ColorOverlay, saturate( PreLightingBlend + PostLightingBlend ) );
						Diffuse = lerp( Diffuse, FlatMap, FlatMapLerp );
					#endif

					// Highlight color overlay
					#ifdef TERRAIN_COLOR_OVERLAY
						Diffuse = ApplyHighlight( Diffuse, ProvinceCoords );
					#endif
				#endif//not UNDERWATER

				// Output
				Out.Color = float4( Diffuse, 1.0f );
				Out.SSAOColor = float4( vec4(1.0f) );

				return Out;

			}
		]]
	}

	MainCode PixelShaderFlatMap
	{
		Input = "VS_OUTPUT_PDX_TERRAIN"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				CropToWorldSize( Input );

				float2 MapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				float2 ProvinceCoords = Input.WorldSpacePos.xz / ProvinceMapSize;

				// Flatmap texture and style
				float3 FlatMap = PdxTex2D( FlatMapTexture, float2( MapCoords.x, 1.0 - MapCoords.y ) ).rgb;
				FlatMap = lerp(FlatMap, ApplyDynamicFlatmap( FlatMap, ProvinceCoords, Input.WorldSpacePos.xz ), 0.25);


				// Border color overlay
				#ifdef TERRAIN_COLOR_OVERLAY
					float3 ColorOverlay;
					float PreLightingBlend;
					float PostLightingBlend;
					GameProvinceOverlayAndBlend( ProvinceCoords, Input.WorldSpacePos, ColorOverlay, PreLightingBlend, PostLightingBlend );

					FlatMap *= lerp( vec3( 1.0 ), ColorOverlay, saturate( PreLightingBlend + PostLightingBlend ) );
				#endif

				// Flatmap color
				float3 FinalColor = FlatMap;

				// Highlight color overlay
				#ifdef TERRAIN_COLOR_OVERLAY
					FinalColor = ApplyHighlight( FinalColor, ProvinceCoords );
				#endif

				// Debug
				#ifdef TERRAIN_DEBUG
					TerrainDebug( FinalColor, Input.WorldSpacePos );
				#endif

				return float4( FinalColor, 1 );
			}
		]]
	}

	MainCode PixelShaderShadow
	{
		Input = "VS_OUTPUT_PDX_TERRAIN_SHADOW"
		Output = "void"
		Code
		[[
			PDX_MAIN
			{
			}
		]]
	}
}

RasterizerState RasterizerState
{
	DepthBias = 150
	SlopeScaleDepthBias = 0
}
RasterizerState ShadowRasterizerState
{
	DepthBias = 0
	SlopeScaleDepthBias = 2
}

Effect PdxTerrain
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	Defines = { "TERRAIN_COLOR_OVERLAY" "TERRAIN_WRAP_X" }
}

Effect PdxTerrainLowSpec
{
	VertexShader = "VertexShaderLowSpec"
	PixelShader = "PixelShaderLowSpec"

	Defines = { "TERRAIN_COLOR_OVERLAY" "TERRAIN_WRAP_X" }
}

Effect PdxTerrainSkirt
{
	VertexShader = "VertexShaderSkirt"
	PixelShader = "PixelShader"

	Defines = { "TERRAIN_COLOR_OVERLAY" "TERRAIN_WRAP_X" }
}

Effect PdxTerrainLowSpecSkirt
{
	VertexShader = "VertexShaderLowSpecSkirt"
	PixelShader = "PixelShaderLowSpec"

	Defines = { "TERRAIN_COLOR_OVERLAY" "TERRAIN_WRAP_X" }
}

Effect PdxTerrainFlat
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderFlatMap"

	Defines = { "TERRAIN_FLAT_MAP" }
}

Effect PdxTerrainFlatSkirt
{
	VertexShader = "VertexShaderSkirt"
	PixelShader = "PixelShaderFlatMap"

	Defines = { "TERRAIN_FLAT_MAP" }
}

Effect PdxTerrainShadow
{
	VertexShader = "VertexShaderShadow"
	PixelShader = "PixelShaderShadow"
	RasterizerState = ShadowRasterizerState
}

Effect PdxTerrainShadowSkirt
{
	VertexShader = "VertexShaderShadowSkirt"
	PixelShader = "PixelShaderShadow"
	RasterizerState = ShadowRasterizerState
}