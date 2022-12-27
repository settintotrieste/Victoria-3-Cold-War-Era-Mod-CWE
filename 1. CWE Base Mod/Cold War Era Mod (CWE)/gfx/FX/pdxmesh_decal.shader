Includes = {
	"cw/shadow.fxh"
	"cw/pdxterrain.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_decals.fxh"
	"jomini/jomini_province_overlays.fxh"
	"dynamic_masks.fxh"
	"distance_fog.fxh"
	"cwecoloroverlay.fxh"
	"fog_of_war.fxh"
}

PixelShader =
{
	TextureSampler DiffuseTexture
	{
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler PropertiesTexture
	{
		Ref = PdxTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler NormalTexture
	{
		Ref = PdxTexture2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
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
}

PixelShader =
{
	Code
	[[
		float4 CalcDecal( float2 UV, float3 Bitangent, float3 WorldSpacePos, float4 Diffuse, float Alpha )
		{
			float2 MapCoords = WorldSpacePos.xz * WorldSpaceToTerrain0To1;
			float2 ProvinceCoords = WorldSpacePos.xz / ProvinceMapSize;

			float4 Properties = PdxTex2D( PropertiesTexture, UV );
			float4 NormalPacked = PdxTex2D( NormalTexture, UV );
			float3 NormalSample = UnpackRRxGNormal( NormalPacked );

			// Alpha blend two sources
			Diffuse.a = CalcHeightBlendFactors( float4( Diffuse.a, 0.3, 0.0, 0.0 ), float4( Alpha, 1.0 - Alpha, 0.0, 0.0 ), 0.25 ).r;
			
			// Devastation
			ApplyDevastationDecal( Diffuse, WorldSpacePos.xz, 1.0 - Properties.r );
			
			float3 Normal = CalculateNormal( WorldSpacePos.xz );
			#ifdef TANGENT_SPACE_NORMALS
				float3 Tangent = cross( Bitangent, Normal );
				float3x3 TBN = Create3x3( normalize( Tangent ), normalize( Bitangent ), Normal );
				Normal = normalize( mul( NormalSample, TBN ) );
			#else
				Normal = ReorientNormal( Normal, NormalSample );
			#endif

			float3 ColorMap = PdxTex2D( ColorTexture, float2( MapCoords.x, 1.0 - MapCoords.y ) ).rgb;
			Diffuse.rgb = SoftLight( Diffuse.rgb, ColorMap, ( 1.0 - Properties.r ) );

			// Color overlay pre light
			float3 ColorOverlay;
			float PreLightingBlend;
			float PostLightingBlend;
			GameProvinceOverlayAndBlend( ProvinceCoords, WorldSpacePos, ColorOverlay, PreLightingBlend, PostLightingBlend );
			Diffuse.rgb = ApplyColorOverlay( Diffuse.rgb, ColorOverlay, PreLightingBlend );

			// Light
			Properties.a = ScaleRoughnessByDistance( Properties.a, WorldSpacePos );
			SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Properties.a, Properties.g, Properties.b );
			SLightingProperties LightingProps = GetSunLightingProperties( WorldSpacePos, ShadowTexture );
			#ifndef LOW_QUALITY_SHADERS
				Diffuse.rgb = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
			#endif

			// Color overlay post light
			#ifndef UNDERWATER
				Diffuse.rgb = ApplyColorOverlay( Diffuse.rgb, ColorOverlay, PostLightingBlend );
				Diffuse.rgb = ApplyFogOfWar( Diffuse.rgb, WorldSpacePos );
				Diffuse.rgb = GameApplyDistanceFog( Diffuse.rgb, WorldSpacePos );
			#endif

			// Province Highlight
			Diffuse.rgb = ApplyHighlight( Diffuse.rgb, ProvinceCoords );

			DebugReturn( Diffuse.rgb, MaterialProps, LightingProps, EnvironmentMap );
			return Diffuse;
		}
	]]

	MainCode PS_world
	{
		TextureSampler DecalAlphaTexture
		{
			Ref = PdxTexture3
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
		}

		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			static const float DECAL_TILING_SCALE = 0.5;
			static const float DECAL_TILING_1024_SCALE = 0.125;

			PDX_MAIN
			{
				float Alpha = PdxTex2D( DecalAlphaTexture, Input.UV0 ).r;
				Alpha = PdxMeshApplyOpacity( Alpha, Input.Position.xy, GetOpacity( Input.InstanceIndex ) );
				

				float2 DetailUV = Input.WorldSpacePos.xz;
				#if defined( TILING_1024 )			
					DetailUV *= float2( DECAL_TILING_1024_SCALE, -DECAL_TILING_1024_SCALE );				
				#else				
					DetailUV *= float2( DECAL_TILING_SCALE, -DECAL_TILING_SCALE );
				#endif

				float4 Diffuse = PdxTex2D( DiffuseTexture, DetailUV );
				Diffuse = CalcDecal( DetailUV, Input.Bitangent, Input.WorldSpacePos, Diffuse, Alpha );
				
				return float4( Diffuse.rgb, Diffuse.a );
			}
		]]
	}

	MainCode PS_local
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( DiffuseTexture, Input.UV0 );
				Diffuse.a = PdxMeshApplyOpacity( Diffuse.a, Input.Position.xy, GetOpacity( Input.InstanceIndex ) );

				Diffuse = CalcDecal( Input.UV0, Input.Bitangent, Input.WorldSpacePos, Diffuse, 0.5 );

				return float4( Diffuse.rgb, Diffuse.a );
			}
		]]
	}
}

RasterizerState RasterizerState
{
	DepthBias = 0
	SlopeScaleDepthBias = 0
}

Effect decal_world
{
	VertexShader = "VS_standard"
	PixelShader = "PS_world"
}

Effect decal_world_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_world"
}

Effect decal_world_1024
{
	VertexShader = "VS_standard"
	PixelShader = "PS_world"

	Defines = { "TILING_1024" }
}

Effect decal_world_1024_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_world"

	Defines = { "TILING_1024" }
}

Effect decal_local
{
	VertexShader = "VS_standard"
	PixelShader = "PS_local"

	Defines = { "TANGENT_SPACE_NORMALS" }
}

Effect decal_local_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_local"

	Defines = { "TANGENT_SPACE_NORMALS" }
}