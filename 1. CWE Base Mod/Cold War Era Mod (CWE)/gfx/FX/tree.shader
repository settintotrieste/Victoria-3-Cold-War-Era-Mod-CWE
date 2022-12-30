Includes = {
	"cw/pdxmesh.fxh"
	"cw/pdxterrain.fxh"
	"cw/utility.fxh"
	"cw/shadow.fxh"
	"cw/alpha_to_coverage.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_mapobject.fxh"
	"jomini/jomini_province_overlays.fxh"
	"pdxmesh_functions.fxh"
	"sharedconstants.fxh"
	"distance_fog.fxh"
	"dynamic_masks.fxh"
	"cwecoloroverlay.fxh"
	"fog_of_war.fxh"
	"ssao_struct.fxh"
}

VertexStruct VS_OUTPUT_TREE
{
	float4 	Position 		: PDX_POSITION;
	float3 	Normal			: TEXCOORD0;
	float3 	Tangent			: TEXCOORD1;
	float3 	Bitangent		: TEXCOORD2;
	float2 	UV0				: TEXCOORD3;
	float3 	WorldSpacePos	: TEXCOORD4;
	uint	InstanceIndex	: TEXCOORD5;
	float3	Scale_Seed_Yaw	: TEXCOORD6;
}

VertexStruct VS_OUTPUT_MAPOBJECT_SHADOW_GAME
{
	float4 Position					: PDX_POSITION;
	float2 UV 						: TEXCOORD0;
	uint InstanceIndex24_Opacity8 	: TEXCOORD1;
	float3 WorldSpacePos			: TEXCOORD2;
}

VertexStruct VS_OUTPUT_PDXMESHSHADOWSTANDARD_GAME
{
	float4 Position				: PDX_POSITION;
	float3 UV_InstanceIndex		: TEXCOORD0;
	float3 WorldSpacePos		: TEXCOORD1;
};

VertexShader =
{

	Code
	[[
		VS_OUTPUT_TREE ConvertOutput( VS_OUTPUT_PDXMESH In )
		{
			VS_OUTPUT_TREE Out;
			Out.Position = In.Position;
			Out.Normal = In.Normal;
			Out.Tangent = In.Tangent;
			Out.Bitangent = In.Bitangent;
			Out.UV0 = In.UV0;
			Out.WorldSpacePos = In.WorldSpacePos;
			return Out;
		}
		void FinalizeOutput( inout VS_OUTPUT_TREE Out, in uint InstanceIndex, in float4x4 WorldMatrix )
		{
			Out.InstanceIndex = InstanceIndex;
			Out.Scale_Seed_Yaw.x = 1.0f;
			Out.Scale_Seed_Yaw.y = CalcRandom( float2( GetMatrixData( WorldMatrix, 0, 2 ), GetMatrixData( WorldMatrix, 2, 2 ) ) );
			Out.Scale_Seed_Yaw.z = frac(Out.Scale_Seed_Yaw.y) * TWO_PI; //We could calculate a correct Yaw from the WorldMatrix, we could also just fake it!
		}

	]]

	MainCode VS_standard
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT_TREE"
		Code
		[[
			PDX_MAIN
			{
				float4x4 WorldMatrix = PdxMeshGetWorldMatrix( Input.InstanceIndices.y );

				#if defined( TREE_BUSH )
					Input.Position = WindTransformBush( Input.Position, WorldMatrix );
				#elif defined( TREE_MEDIUM )
					Input.Position = WindTransformMedium( Input.Position, WorldMatrix );
				#elif defined( TREE_TALL )
					Input.Position = WindTransformTall( Input.Position, WorldMatrix );
				#else
					Input.Position = WindTransform( Input.Position, WorldMatrix );
				#endif

				VS_OUTPUT_TREE Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				FinalizeOutput( Out, Input.InstanceIndices.y, PdxMeshGetWorldMatrix( Input.InstanceIndices.y ) );
				return Out;
			}
		]]
	}
	MainCode VS_mapobject
	{
		Input = "VS_INPUT_PDXMESH_MAPOBJECT"
		Output = "VS_OUTPUT_TREE"
		Code
		[[
			PDX_MAIN
			{
				float4x4 WorldMatrix = UnpackAndGetMapObjectWorldMatrix( Input.InstanceIndex24_Opacity8 );

				#if defined( TREE_BUSH )
					Input.Position = WindTransformBush( Input.Position, WorldMatrix );
				#elif defined( TREE_MEDIUM )
					Input.Position = WindTransformMedium( Input.Position, WorldMatrix );
				#elif defined( TREE_TALL )
					Input.Position = WindTransformTall( Input.Position, WorldMatrix );
				#else
					Input.Position = WindTransform( Input.Position, WorldMatrix );
				#endif

				VS_OUTPUT_TREE Out = ConvertOutput( PdxMeshVertexShader( PdxMeshConvertInput( Input ), Input.InstanceIndex24_Opacity8, WorldMatrix ) );
				FinalizeOutput( Out, Input.InstanceIndex24_Opacity8, WorldMatrix );
				return Out;
			}
		]]
	}
	MainCode VS_standard_shadow
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT_PDXMESHSHADOWSTANDARD_GAME"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_PDXMESHSHADOWSTANDARD_GAME Out;

				float4x4 WorldMatrix = PdxMeshGetWorldMatrix( Input.InstanceIndices.y );

				#if defined( TREE_BUSH )
					Input.Position = WindTransformBush( Input.Position, WorldMatrix );
				#elif defined( TREE_MEDIUM )
					Input.Position = WindTransformMedium( Input.Position, WorldMatrix );
				#elif defined( TREE_TALL )
					Input.Position = WindTransformTall( Input.Position, WorldMatrix );
				#else
					Input.Position = WindTransform( Input.Position, WorldMatrix );
				#endif

				VS_OUTPUT_PDXMESHSHADOWSTANDARD Data = PdxMeshVertexShaderShadowStandard( Input );
				Out.Position = Data.Position;
				Out.UV_InstanceIndex = Data.UV_InstanceIndex;

				Out.WorldSpacePos = mul( WorldMatrix, float4( Input.Position, 1.0f ) ).xyz;

				return Out;
			}
		]]
	}
	MainCode VS_mapobject_shadow
	{
		Input = "VS_INPUT_PDXMESH_MAPOBJECT"
		Output = "VS_OUTPUT_MAPOBJECT_SHADOW_GAME"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_MAPOBJECT_SHADOW_GAME Out;

				float4x4 WorldMatrix = UnpackAndGetMapObjectWorldMatrix( Input.InstanceIndex24_Opacity8 );

				#if defined( TREE_BUSH )
					Input.Position = WindTransformBush( Input.Position, WorldMatrix );
				#elif defined( TREE_MEDIUM )
					Input.Position = WindTransformMedium( Input.Position, WorldMatrix );
				#elif defined( TREE_TALL )
					Input.Position = WindTransformTall( Input.Position, WorldMatrix );
				#else
					Input.Position = WindTransform( Input.Position, WorldMatrix );
				#endif

				VS_OUTPUT_MAPOBJECT_SHADOW Data = ConvertOutputMapObjectShadow( PdxMeshVertexShaderShadow( PdxMeshConvertInput( Input ), 0/*Not supported*/, UnpackAndGetMapObjectWorldMatrix( Input.InstanceIndex24_Opacity8 ) ) );
				Out.Position = Data.Position;
				Out.UV = Data.UV;

				Out.WorldSpacePos = mul( WorldMatrix, float4( Input.Position, 1.0f ) ).xyz;
				Out.InstanceIndex24_Opacity8 = Input.InstanceIndex24_Opacity8;

				return Out;
			}
		]]
	}

}



PixelShader =
{
	TextureSampler DiffuseMap
	{
		Index = 0
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler PropertiesMap
	{
		Index = 1
		Ref = PdxTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler NormalMap
	{
		Index = 2
		Ref = PdxTexture2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler TintMap
	{
		Index = 3
		Ref = PdxTexture3
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"

		file = "gfx/models/environment/trees/tree_tint_01.dds"
		srgb = yes
	}
	TextureSampler ShadowTexture
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		CompareFunction = less_equal
		SamplerType = "Compare"
	}
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

	TextureSampler ColorMapTree
	{
		Ref = ColorMapTree
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}




	TextureSampler WindMapTree
	{
		Ref = WindMapTree
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}

	Code
	[[
		float ApplyOpacity( in float Alpha, in float2 NoiseCoordinate, in uint InstanceIndex )
		{
			#ifdef JOMINI_MAP_OBJECT
				float Opacity = UnpackAndGetMapObjectOpacity( InstanceIndex );
			#else
				float Opacity = PdxMeshGetOpacity( InstanceIndex );
			#endif
			return PdxMeshApplyOpacity( Alpha, NoiseCoordinate, Opacity );
		}

	]]

	MainCode PS_leaf
	{
		Input = "VS_OUTPUT_TREE"
		Output = "PS_COLOR_SSAO"
		Code
		[[
			PDX_MAIN
			{
				PS_COLOR_SSAO Out;

				float4 Diffuse = PdxTex2D( DiffuseMap, Input.UV0 );
				float3 NormalSample = UnpackRRxGNormal( PdxTex2D( NormalMap, Input.UV0 ) );
				float3x3 TBN = Create3x3( normalize( Input.Tangent ), normalize( Input.Bitangent ), normalize( Input.Normal ) );
				float3 Normal = normalize( mul( NormalSample, TBN ) );
				float4 Properties = PdxTex2D( PropertiesMap, Input.UV0 );

				float2 MapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				float2 ProvinceCoords = Input.WorldSpacePos.xz / ProvinceMapSize;

				// Dynamic mask, pre light
				// Colormap blend
				float3 ColorMap = PdxTex2D( ColorMapTree, float2( MapCoords.x, 1.0 - MapCoords.y ) ).rgb;
				Diffuse.rgb = Overlay( Diffuse.rgb, ToGamma( ColorMap ) );

				// Tint blend
				float3 Tint = PdxTex2DLod0( TintMap, float2( Input.Scale_Seed_Yaw.y, 0.5f ) ).rgb;
				Diffuse.rgb = SoftLight( Diffuse.rgb, Tint );

				#ifndef LOW_QUALITY_SHADERS
					ApplyPollutionTrees( Diffuse, MapCoords );
					ApplyDevastationTrees( Diffuse, MapCoords );
				#endif

				// Color overlay, pre light
				float3 ColorOverlay;
				float PreLightingBlend;
				float PostLightingBlend;
				GameProvinceOverlayAndBlend( ProvinceCoords, Input.WorldSpacePos, ColorOverlay, PreLightingBlend, PostLightingBlend );
				Diffuse.rgb = ApplyColorOverlay( Diffuse.rgb, ColorOverlay, PreLightingBlend );

				// Light and shadow
				Properties.a = ScaleRoughnessByDistance( Properties.a, Input.WorldSpacePos );
				SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Properties.a, Properties.g, Properties.b );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTexture );
				#ifndef LOW_QUALITY_SHADERS
					Diffuse.rgb = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );

					// Second sun
					SLightingProperties SecondLightingProps = GetSecondSunLightingProperties( Input.WorldSpacePos );
					float3 SecondSunColor = CalculateSecondSunLighting( MaterialProps, SecondLightingProps );
					Diffuse.rgb += SecondSunColor;
				#endif

				// Effects, post light
				Diffuse.rgb = ApplyColorOverlay( Diffuse.rgb, ColorOverlay, PostLightingBlend );
				Diffuse.rgb = ApplyFogOfWar( Diffuse.rgb, Input.WorldSpacePos );
				Diffuse.rgb = GameApplyDistanceFog( Diffuse.rgb, Input.WorldSpacePos );

				// Province Highlight
				Diffuse.rgb = ApplyHighlight( Diffuse.rgb, ProvinceCoords );

				// Alpha
				Diffuse.a *= ( 1.0f - FlatMapLerp );
				Diffuse.a = ApplyOpacity( Diffuse.a, Input.Position.xy, Input.InstanceIndex );
				Diffuse.a = RescaleAlphaByMipLevel( Diffuse.a, Input.UV0, DiffuseMap) ;
				Diffuse.a = SharpenAlpha( Diffuse.a, 0.7f ) ;

				clip( Diffuse.a - 0.001f );

				// Debug
				DebugReturn( Diffuse.rgb, MaterialProps, LightingProps, EnvironmentMap );

				// Output
				Out.Color = float4( Diffuse.rgb, Diffuse.a );
				float SSAOAlphaFixed = 1.0f - SSAOAlphaTrees + GameCalculateDistanceFogFactor( Input.WorldSpacePos );	// Reduces the applied SSAO on trees
				Out.SSAOColor = float4( saturate( vec3 ( SSAOAlphaFixed ) ), Diffuse.a);

				return Out;
			}
		]]
	}

	MainCode PS_tree_shadow
	{
		Input = "VS_OUTPUT_PDXMESHSHADOWSTANDARD_GAME"
		Output = "void"
		Code
		[[
			PDX_MAIN
			{
				// Alpha
				float Alpha = PdxTex2D( PDXMESH_AlphaBlendShadowMap, Input.UV_InstanceIndex.xy ).a;

				// Devastation
				float2 MapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				float Devastation = GetDevastation( MapCoords ) * 2.0f;
				float DevastatedAlpha = smoothstep( DevastationTreeAlphaReduce, 1.0f, Alpha );
				Alpha = lerp( Alpha, DevastatedAlpha, Devastation );

			#ifdef PDXMESH_USE_DITHERED_OPACITY
				float Opacity = PdxMeshGetOpacity( uint( Input.UV_InstanceIndex.z + 0.5 ) ); // +0.5 to "round", it seems floating point errors can sneak in when interpolating

				// Devastation
				DevastatedAlpha = smoothstep( DevastationTreeAlphaReduce, 1.0f, Opacity );
				Opacity = lerp( Opacity, DevastatedAlpha, Devastation );

				PdxMeshApplyDitheredOpacity( Opacity, Input.Position.xy );
			#endif


				clip( Alpha - 0.5 );
			}
		]]
	}

	MainCode PS_tree_shadow_mapobject
	{
		Input = "VS_OUTPUT_MAPOBJECT_SHADOW_GAME"
		Output = "void"
		Code
		[[
			#ifndef PDXMESH_AlphaBlendShadowMap
				#define PDXMESH_AlphaBlendShadowMap DiffuseMap
			#endif
			PDX_MAIN
			{
				float Opacity = UnpackAndGetMapObjectOpacity( Input.InstanceIndex24_Opacity8 );
				PdxMeshApplyDitheredOpacity( Opacity, Input.Position.xy );

				float Alpha = PdxTex2D( PDXMESH_AlphaBlendShadowMap, Input.UV ).a;

				// Devastation
				float2 MapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				float Devastation = GetDevastation( MapCoords ) * 2.0f;
				float DevastatedAlpha = smoothstep( DevastationTreeAlphaReduce, 1.0f, Alpha );
				Alpha = lerp( Alpha, DevastatedAlpha, Devastation );

				clip( Alpha - 0.5 );
			}
		]]
	}

}


BlendState BlendState
{
	BlendEnable = no
	#SourceBlend = "src_alpha"
	#DestBlend = "inv_src_alpha"
	alphatocoverage = yes
}


RasterizerState RasterizerState
{
	DepthBias = 0
	SlopeScaleDepthBias = 0
}
RasterizerState ShadowRasterizerState
{
	DepthBias = 0
	SlopeScaleDepthBias = 7
}


Effect tree
{
	VertexShader = VS_standard
	PixelShader = PS_leaf
}
Effect treeShadow
{
	VertexShader = VS_standard_shadow
	PixelShader = PS_tree_shadow
	RasterizerState = ShadowRasterizerState
}

Effect tree_bush
{
	VertexShader = VS_standard
	PixelShader = PS_leaf
	Defines = { "TREE_BUSH" }
}
Effect tree_bushShadow
{
	VertexShader = VS_standard_shadow
	PixelShader = PS_tree_shadow
	Defines = { "TREE_BUSH" }
	RasterizerState = ShadowRasterizerState
}

Effect tree_medium
{
	VertexShader = VS_standard
	PixelShader = PS_leaf
	Defines = { "TREE_MEDIUM" }
}
Effect tree_mediumShadow
{
	VertexShader = VS_standard_shadow
	PixelShader = PS_tree_shadow
	Defines = { "TREE_MEDIUM" }
	RasterizerState = ShadowRasterizerState
}

Effect tree_tall
{
	VertexShader = VS_standard
	PixelShader = PS_leaf
	Defines = { "TREE_TALL" }
}
Effect tree_tallShadow
{
	VertexShader = VS_standard_shadow
	PixelShader = PS_tree_shadow
	Defines = { "TREE_TALL" }
	RasterizerState = ShadowRasterizerState
}

Effect tree_snap_to_terrain
{
	VertexShader = VS_standard
	PixelShader = PS_leaf
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}
Effect tree_snap_to_terrainShadow
{
	VertexShader = VS_standard_shadow
	PixelShader = PS_tree_shadow
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}

# Map object shaders
Effect tree_mapobject
{
	VertexShader = VS_mapobject
	PixelShader = PS_leaf
}
Effect treeShadow_mapobject
{
	VertexShader = VS_mapobject_shadow
	PixelShader = PS_tree_shadow_mapobject
	RasterizerState = ShadowRasterizerState
}

Effect tree_bush_mapobject
{
	VertexShader = VS_mapobject
	PixelShader = PS_leaf
	Defines = { "TREE_BUSH" }
}
Effect tree_bushShadow_mapobject
{
	VertexShader = VS_mapobject_shadow
	PixelShader = PS_tree_shadow_mapobject
	Defines = { "TREE_BUSH" }
	RasterizerState = ShadowRasterizerState
}

Effect tree_medium_mapobject
{
	VertexShader = VS_mapobject
	PixelShader = PS_leaf
	Defines = { "TREE_MEDIUM" }
}
Effect tree_mediumShadow_mapobject
{
	VertexShader = VS_mapobject_shadow
	PixelShader = PS_tree_shadow_mapobject
	Defines = { "TREE_MEDIUM" }
	RasterizerState = ShadowRasterizerState
}

Effect tree_tall_mapobject
{
	VertexShader = VS_mapobject
	PixelShader = PS_leaf
	Defines = { "TREE_TALL" }
}
Effect tree_tallShadow_mapobject
{
	VertexShader = VS_mapobject_shadow
	PixelShader = PS_tree_shadow_mapobject
	Defines = { "TREE_TALL" }
	RasterizerState = ShadowRasterizerState
}

Effect tree_snap_to_terrain_mapobject
{
	VertexShader = VS_mapobject
	PixelShader = PS_leaf
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}
Effect tree_snap_to_terrainShadow_mapobject
{
	VertexShader = VS_mapobject_shadow
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}
