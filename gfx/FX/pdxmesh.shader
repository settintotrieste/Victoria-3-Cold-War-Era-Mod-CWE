Includes = {
	"cw/pdxmesh.fxh"
	"cw/pdxterrain.fxh"
	"cw/utility.fxh"
	"cw/curve.fxh"
	"cw/shadow.fxh"
	"cw/camera.fxh"
	"cw/heightmap.fxh"
	"cw/alpha_to_coverage.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_water.fxh"
	"jomini/jomini_mapobject.fxh"
	"jomini/jomini_province_overlays.fxh"
	"dynamic_masks.fxh"
	"pdxmesh_functions.fxh"
	"sharedconstants.fxh"
	"fog_of_war.fxh"
	"distance_fog.fxh"
	"cwecoloroverlay.fxh"
	"ssao_struct.fxh"
}

PixelShader =
{
	TextureSampler DiffuseMap
	{
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler PropertiesMap
	{
		Ref = PdxTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler NormalMap
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
	TextureSampler UniqueMap
	{
		Index = 5
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler ShadowMap
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

VertexStruct VS_OUTPUT
{
	float4 Position			: PDX_POSITION;
	float3 Normal			: TEXCOORD0;
	float3 Tangent			: TEXCOORD1;
	float3 Bitangent		: TEXCOORD2;
	float2 UV0				: TEXCOORD3;
	float2 UV1				: TEXCOORD4;
	float3 WorldSpacePos	: TEXCOORD5;
	uint InstanceIndex 	: TEXCOORD6;
};

VertexShader =
{
	Code
	[[
		VS_OUTPUT ConvertOutput( VS_OUTPUT_PDXMESH In )
		{
			VS_OUTPUT Out;

			Out.Position = In.Position;
			Out.Normal = In.Normal;
			Out.Tangent = In.Tangent;
			Out.Bitangent = In.Bitangent;
			Out.UV0 = In.UV0;
			Out.UV1 = In.UV1;
			Out.WorldSpacePos = In.WorldSpacePos;
			return Out;
		}
	]]

	MainCode VS_standard
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				float4x4 WorldMatrix = PdxMeshGetWorldMatrix( Input.InstanceIndices.y );

				#ifdef WINDTRANSFORM
					#if defined( TREE_BUSH )
						Input.Position = WindTransformBush( Input.Position, WorldMatrix );
					#elif defined( TREE_MEDIUM )
						Input.Position = WindTransformMedium( Input.Position, WorldMatrix );
					#elif defined( TREE_TALL )
						Input.Position = WindTransformTall( Input.Position, WorldMatrix );
					#else
						Input.Position = WindTransform( Input.Position, WorldMatrix );
					#endif
				#endif

				#ifdef SNAP_TO_WATER
					Input.Position.y = SnapToWaterLevel( Input.Position.y, WorldMatrix );
				#endif

				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				Out.InstanceIndex = Input.InstanceIndices.y;

				#ifdef PDX_MESH_SNAP_VERTICES_TO_TERRAIN
					Out.Normal = SimpleRotateNormalToTerrain( Out.Normal, Out.WorldSpacePos.xz );
				#endif

				return Out;
			}
		]]
	}
	MainCode VS_standard_shadow
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT_PDXMESHSHADOWSTANDARD"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_PDXMESHSHADOWSTANDARD Out;

				#ifdef SNAP_TO_WATER
					float4x4 WorldMatrix = PdxMeshGetWorldMatrix( Input.InstanceIndices.y );
					Input.Position.y = SnapToWaterLevel( Input.Position.y, WorldMatrix );
				#endif

				Out = PdxMeshVertexShaderShadowStandard( Input );
				return Out;
			}
		]]
	}


	MainCode VS_mapobject
	{
		Input = "VS_INPUT_PDXMESH_MAPOBJECT"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				float4x4 WorldMatrix = UnpackAndGetMapObjectWorldMatrix( Input.InstanceIndex24_Opacity8 );

				#ifdef WINDTRANSFORM
					#if defined( TREE_BUSH )
						Input.Position = WindTransformBush( Input.Position, WorldMatrix );
					#elif defined( TREE_MEDIUM )
						Input.Position = WindTransformMedium( Input.Position, WorldMatrix );
					#elif defined( TREE_TALL )
						Input.Position = WindTransformTall( Input.Position, WorldMatrix );
					#else
						Input.Position = WindTransform( Input.Position, WorldMatrix );
					#endif
				#endif

				#ifdef SNAP_TO_WATER
					Input.Position.y = SnapToWaterLevel( Input.Position.y, WorldMatrix );
				#endif

				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShader( PdxMeshConvertInput( Input ), Input.InstanceIndex24_Opacity8, UnpackAndGetMapObjectWorldMatrix( Input.InstanceIndex24_Opacity8 ) ) );
				Out.InstanceIndex = Input.InstanceIndex24_Opacity8;

				#ifdef PDX_MESH_SNAP_VERTICES_TO_TERRAIN
					Out.Normal = SimpleRotateNormalToTerrain( Out.Normal, Out.WorldSpacePos.xz );
				#endif

				return Out;
			}
		]]
	}
	MainCode VS_mapobject_shadow
	{
		Input = "VS_INPUT_PDXMESH_MAPOBJECT"
		Output = "VS_OUTPUT_MAPOBJECT_SHADOW"
		Code
		[[
			PDX_MAIN
			{
				uint InstanceIndex;
				float Opacity;
				UnpackMapObjectInstanceData( Input.InstanceIndex24_Opacity8, InstanceIndex, Opacity );
				float4x4 WorldMatrix = GetWorldMatrixMapObject( InstanceIndex );

				#ifdef SNAP_TO_WATER
					Input.Position.y = SnapToWaterLevel( Input.Position.y, WorldMatrix );
				#endif

				VS_OUTPUT_MAPOBJECT_SHADOW Out = ConvertOutputMapObjectShadow( PdxMeshVertexShaderShadow( PdxMeshConvertInput( Input ), 0/*Not supported*/, WorldMatrix ) );
				Out.InstanceIndex24_Opacity8 = Input.InstanceIndex24_Opacity8;
				return Out;
			}
		]]
	}

	MainCode VS_sine_animation
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				#ifdef PDX_MESH_UV1
				CalculateSineAnimation( Input.UV1, Input.Position, Input.Normal, Input.Tangent );
				#endif
				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				Out.InstanceIndex = Input.InstanceIndices.y;

				return Out;
			}
		]]
	}
	MainCode VS_sine_animation_shadow
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT_PDXMESHSHADOWSTANDARD"
		Code
		[[
			PDX_MAIN
			{
				CalculateSineAnimation( Input.UV1, Input.Position, Input.Normal, Input.Tangent );
				return PdxMeshVertexShaderShadowStandard( Input );
			}
		]]
	}
}


PixelShader =
{
	Code
	[[
		float ApplyOpacity( float BaseAlpha, float2 NoiseCoordinate, in uint InstanceIndex )
		{
		#ifdef JOMINI_MAP_OBJECT
			float Opacity = UnpackAndGetMapObjectOpacity( InstanceIndex );
		#else
			float Opacity = PdxMeshGetOpacity( InstanceIndex );
		#endif
			return PdxMeshApplyOpacity( BaseAlpha, NoiseCoordinate, Opacity );
		}
	]]
	MainCode PS_standard
	{
		Input = "VS_OUTPUT"
		Output = "PS_COLOR_SSAO"
		Code
		[[
			#define DIFFUSE_UV_SET Input.UV0
			#define NORMAL_UV_SET Input.UV0
			#define PROPERTIES_UV_SET Input.UV0
			#define UNIQUE_UV_SET Input.UV1

			PDX_MAIN
			{
				PS_COLOR_SSAO Out;

				#ifdef UNDERWATER
					clip( _WaterHeight - Input.WorldSpacePos.y + 0.1 ); // +0.1 to avoid gap between water and mesh
				#endif

				float2 MapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				float2 ProvinceCoords = Input.WorldSpacePos.xz / ProvinceMapSize;
				float LocalHeight = Input.WorldSpacePos.y - GetHeight( Input.WorldSpacePos.xz );

				float4 Diffuse = PdxTex2D( DiffuseMap, DIFFUSE_UV_SET );
				float4 Properties = PdxTex2D( PropertiesMap, PROPERTIES_UV_SET );

				// Alpha
				Diffuse.a = ApplyOpacity( Diffuse.a, Input.Position.xy, Input.InstanceIndex );
				#ifdef ALPHA_TO_COVERAGE
					Diffuse.a = RescaleAlphaByMipLevel( Diffuse.a, DIFFUSE_UV_SET, DiffuseMap );
					Diffuse.a = SharpenAlpha( Diffuse.a, 0.5f );
				#endif
				clip( Diffuse.a - 0.001f );

				// Normal calculation
				float3 NormalSample = UnpackRRxGNormal( PdxTex2D( NormalMap, NORMAL_UV_SET ) );

				// Devastation
				ApplyDevastationBuilding( Diffuse.rgb, Input.WorldSpacePos.xz, LocalHeight, DIFFUSE_UV_SET );

				float3 InNormal = normalize( Input.Normal );
				float3x3 TBN = Create3x3( normalize( Input.Tangent ), normalize( Input.Bitangent ), InNormal );
				float3 Normal = normalize( mul( NormalSample, TBN ) );

				// Baked AO
				#if defined( ATLAS )
					float4 Unique = PdxTex2D( UniqueMap, UNIQUE_UV_SET );
					Diffuse.rgb = Overlay( Diffuse.rgb, Unique.rgb );
				#endif

				// Bottom tint effetc
				float TintAngleModifier = saturate( 1.0 - dot( InNormal, float3( 0.0, 1.0, 0.0 ) ) );	// Removes tint from angles facing upwards
				float TintBlend = ( 1.0 - smoothstep( MeshTintHeightMin, MeshTintHeightMax, LocalHeight ) ) * MeshTintColor.a * TintAngleModifier;
				Diffuse.rgb = lerp(  Diffuse.rgb, Overlay( Diffuse.rgb, MeshTintColor.rgb ), TintBlend );

				// Colormap blend, pre light
				#if defined( COLORMAP )
					float3 ColorMap = PdxTex2D( ColorTexture, float2( MapCoords.x, 1.0 - MapCoords.y ) ).rgb;
					Diffuse.rgb = SoftLight( Diffuse.rgb, ColorMap, ( 1 - Properties.r ) );
				#endif

				// Color overlay, pre light
				#ifndef UNDERWATER
					#ifndef NO_BORDERS
						float3 ColorOverlay;
						float PreLightingBlend;
						float PostLightingBlend;
						GameProvinceOverlayAndBlend( ProvinceCoords, Input.WorldSpacePos, ColorOverlay, PreLightingBlend, PostLightingBlend );
						Diffuse.rgb = ApplyColorOverlay( Diffuse.rgb, ColorOverlay, PreLightingBlend );
					#endif
				#endif

				// Light and shadow
				float3 Color = Diffuse.rgb;
				Properties.a = ScaleRoughnessByDistance( Properties.a, Input.WorldSpacePos );
				SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Properties.a, Properties.g, Properties.b );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowMap );
				#ifndef LOW_QUALITY_SHADERS
					#ifndef FLATLIGHT
						Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );

						// Second sun
						#ifndef SINGLESUN
							SLightingProperties SecondLightingProps = GetSecondSunLightingProperties( Input.WorldSpacePos );
							float3 SecondSunColor = CalculateSecondSunLighting( MaterialProps, SecondLightingProps );
							Color += SecondSunColor;
						#endif
					#endif
				#endif

				// Effects, post light
				#ifndef UNDERWATER
					#ifndef NO_BORDERS
						Color = ApplyColorOverlay( Color, ColorOverlay, PostLightingBlend );
					#endif
					#ifndef NO_FOG
						if( FlatMapLerp < 1.0 )
						{
							float3 Unfogged = Color;
							Color = ApplyFogOfWar( Color, Input.WorldSpacePos );
							Color = GameApplyDistanceFog( Color, Input.WorldSpacePos );
							Color = lerp( Color, Unfogged, FlatMapLerp );
						}
					#endif
				#endif

				// Refraction
				#ifdef UNDERWATER
					Diffuse.a = CompressWorldSpace( Input.WorldSpacePos );
				#endif

				// Province Highlight
				Color = ApplyHighlight( Color, ProvinceCoords );

				// Flatmap
				#ifdef FLATMAP
					float OpacityOnLand = 0.25;
				 	float LandMask = PdxTex2DLod0( LandMaskMap, float2( MapCoords.x, 1.0 - MapCoords.y ) ).r;
					Diffuse.a *= ( 1.0 - ( LandMask * ( 1.0 - OpacityOnLand ) ) );
				#endif

				// Debug
				DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );

				// Output
				Out.Color = float4( Color, Diffuse.a );
				float3 SSAOColor_ = SSAOColorMesh.rgb + GameCalculateDistanceFogFactor( Input.WorldSpacePos );
				#ifndef UNDERWATER
					#ifndef NO_BORDERS
						SSAOColor_ = SSAOColor_ + PostLightingBlend;
					#endif
				#endif
				Out.SSAOColor = float4( saturate ( SSAOColor_ ), Diffuse.a);

				return Out;
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = no
}
BlendState alpha_blend
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}
BlendState alpha_to_coverage
{
	BlendEnable = no
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	AlphaToCoverage = yes
}

DepthStencilState depth_test_no_write
{
	DepthEnable = yes
	DepthWriteEnable = no
}

RasterizerState RasterizerState
{
	DepthBias = 0
	SlopeScaleDepthBias = 0
}
RasterizerState ShadowRasterizerState
{
	DepthBias = 0
	SlopeScaleDepthBias = 2
}
RasterizerState FlatmapRasterizerState
{
	DepthBias = -500
	SlopeScaleDepthBias = -7
}

# Standard
Effect standard
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
}
Effect standardShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + no second sun
Effect standard_singlesun
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" "SINGLESUN" }
}
Effect standard_singlesunShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + atlas
Effect standard_atlas
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" }
}
Effect standard_atlasShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + alpha blend
Effect standard_alpha_blend
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_test_no_write"
}
Effect standard_alpha_blendShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + a2c
Effect standard_alpha_to_coverage
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "ALPHA_TO_COVERAGE" }
}
Effect standard_alpha_to_coverageShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "ALPHA_TO_COVERAGE" }
}

# Standard + a2c + snap to water
Effect standard_alpha_to_coverage_snap_to_water
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "ALPHA_TO_COVERAGE" "SNAP_TO_WATER" }
}
Effect standard_alpha_to_coverage_snap_to_waterShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "ALPHA_TO_COVERAGE" "SNAP_TO_WATER" }
}

# Standard + colormap + no second sun
Effect standard_colormap_singlesun
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "COLORMAP" "SINGLESUN" }
}
Effect standard_colormap_singlesunShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + colormap
Effect standard_colormap
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "COLORMAP" }
}
Effect standard_colormapShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + atlas + colormap
Effect standard_atlas_colormap
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" "COLORMAP" }
}
Effect standard_atlas_colormapShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + atlas + colormap + no second sun
Effect standard_atlas_colormap_singlesun
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" "COLORMAP" "SINGLESUN" }
}
Effect standard_atlas_colormap_singlesunmapShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

# Flag animation
Effect standard_flag_basic
{
	VertexShader = "VS_sine_animation"
	PixelShader = "PS_standard"
}
Effect standard_flag_basicShadow
{
	VertexShader = "VS_sine_animation_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + no borders
Effect standard_no_borders
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "NO_BORDERS"  }
}
Effect standard_no_bordersShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

# Snap
Effect snap_to_terrain
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
}
Effect snap_to_terrainShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
	RasterizerState = ShadowRasterizerState
}

# Snap + atlas
Effect snap_to_terrain_atlas
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" }
}
Effect snap_to_terrain_atlasShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" }
	RasterizerState = ShadowRasterizerState
}

# Snap + a2c
Effect snap_to_terrain_alpha_to_coverage
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}
Effect snap_to_terrain_alpha_to_coverageShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}

# Snap + atlas + a2c
Effect snap_to_terrain_atlas_alpha_to_coverage
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "ALPHA_TO_COVERAGE" }
}
Effect snap_to_terrain_atlas_alpha_to_coverageShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}

# Snap + a2c + colormap
Effect snap_to_terrain_alpha_to_coverage_colormap
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "COLORMAP" "ALPHA_TO_COVERAGE" }
}
Effect snap_to_terrain_alpha_to_coverage_colormapShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}

# Snap + a2c + colormap + no second sun
Effect snap_to_terrain_alpha_to_coverage_colormap_singlesun
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "COLORMAP" "ALPHA_TO_COVERAGE" "SINGLESUN" }
}
Effect snap_to_terrain_alpha_to_coverage_colormap_singlesunShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}

# Snap + atlas + a2c + colormap
Effect snap_to_terrain_atlas_alpha_to_coverage_colormap
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "COLORMAP" "ALPHA_TO_COVERAGE" }
}
Effect snap_to_terrain_atlas_alpha_to_coverage_colormapShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}


# Tree trunk
Effect standard_treetrunk
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "WINDTRANSFORM" }
}
Effect standard_treetrunkShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "WINDTRANSFORM" }
}

Effect snap_to_terrain_treetrunk
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" }
}
Effect snap_to_terrain_treetrunkShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" }
}

Effect standard_treetrunk_medium
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "WINDTRANSFORM" "TREE_MEDIUM" }
}
Effect standard_treetrunk_mediumShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "WINDTRANSFORM" "TREE_MEDIUM" }
}

Effect snap_to_terrain_treetrunk_medium
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" "TREE_MEDIUM" }
}
Effect snap_to_terrain_treetrunk_mediumShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" "TREE_MEDIUM" }
}

Effect standard_treetrunk_tall
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "WINDTRANSFORM" "TREE_TALL" }
}
Effect standard_treetrunk_tallShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "WINDTRANSFORM" "TREE_TALL" }
}

Effect snap_to_terrain_treetrunk_tall
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" "TREE_TALL" }
}
Effect snap_to_terrain_treetrunk_tallShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" "TREE_TALL" }
}


# Flatmap
Effect flatmap_alpha_blend
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_test_no_write"
	RasterizerState = FlatmapRasterizerState
	Defines = { "NO_FOG" }
}
Effect flatmap_alpha_blendShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	Defines = { "NO_FOG" }
}
Effect flatmap_alpha_blend_no_borders
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_test_no_write"
	RasterizerState = FlatmapRasterizerState
	Defines = { "NO_BORDERS" "NO_FOG"  }
}
Effect flatmap_alpha_blend_no_bordersShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	Defines = { "NO_FOG" }
	RasterizerState = ShadowRasterizerState
}

# Standard flat light
Effect standard_flat
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"

	Defines = { "FLATLIGHT" }
}
Effect standard_flatShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
}

# Standard flat light + alpha blend
Effect standard_flat_alpha_blend
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_test_no_write"

	Defines = { "FLATLIGHT" }
}
Effect standard_flat_alpha_blendShadow
{
	VertexShader = "VS_standard_shadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	RasterizerState = ShadowRasterizerState
}

# Extra
Effect material_test
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "NORMAL_UV_SET Input.UV1" "DIFFUSE_UV_SET Input.UV1" }
}


############################
# Map object shaders

# Standard
Effect standard_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
}
Effect standardShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + no second sun
Effect standard_singlesun_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" "SINGLESUN" }
}
Effect standard_singlesunShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + no second sun
Effect standard_singlesun_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" "SINGLESUN" }
}
Effect standard_singlesun_mapobjectShadow
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + atlas
Effect standard_atlas_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" }
}
Effect standard_atlasShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + alpha blend
Effect standard_alpha_blend_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_test_no_write"
}
Effect standard_alpha_blendShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
}

# Standard + a2c
Effect standard_alpha_to_coverage_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "ALPHA_TO_COVERAGE" }
}
Effect standard_alpha_to_coverageShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
	Defines = { "ALPHA_TO_COVERAGE" }
}

# Standard + a2c + snap to water
Effect standard_alpha_to_coverage_snap_to_water
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "ALPHA_TO_COVERAGE" "SNAP_TO_WATER" }
}
Effect standard_alpha_to_coverage_snap_to_waterShadow
{
	VertexShader = "VS_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
	Defines = { "ALPHA_TO_COVERAGE" "SNAP_TO_WATER" }
}

# Standard + colormap
Effect standard_colormap_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "COLORMAP" }
}
Effect standard_colormapShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + colormap + no second sun
Effect standard_colormap_singlesun_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "COLORMAP" "SINGLESUN" }
}
Effect standard_colormap_singlesunShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + atlas + colormap
Effect standard_atlas_colormap_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "COLORMAP" "ATLAS" }
}
Effect standard_atlas_colormapShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}

# Standard + atlas + colormap + no second sun
Effect standard_atlas_colormap_singlesunShadow_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" "COLORMAP" "SINGLESUN" }
}
Effect standard_atlas_colormap_singlesun_mapobjectShadow
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}

Effect standard_no_borders_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "NO_BORDERS"  }
}
Effect standard_no_bordersShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}

# Tree trunk
Effect snap_to_terrain_treetrunk_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" }
}
Effect snap_to_terrain_treetrunkShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" }
}

Effect snap_to_terrain_treetrunk_medium_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" "TREE_MEDIUM" }
}
Effect snap_to_terrain_treetrunk_mediumShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" "TREE_MEDIUM" }
}

Effect snap_to_terrain_treetrunk_tall_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" "TREE_TALL" }
}
Effect snap_to_terrain_treetrunk_tallShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "WINDTRANSFORM" "TREE_TALL" }
}

# Flatmap
Effect flatmap_alpha_blend_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_test_no_write"
	RasterizerState = FlatmapRasterizerState
	Defines = { "NO_FOG" "FLATMAP" }
}
Effect flatmap_alpha_blendShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
	Defines = { "NO_FOG" "FLATMAP" "FLATMAP" }
}
Effect flatmap_alpha_blend_no_borders_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_test_no_write"
	RasterizerState = FlatmapRasterizerState
	Defines = { "NO_BORDERS" "NO_FOG" "FLATMAP"  }
}
Effect flatmap_alpha_blend_no_bordersShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	Defines = { "NO_FOG" "FLATMAP" }
	RasterizerState = ShadowRasterizerState
}

# Snap
Effect snap_to_terrain_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN"  }
}
Effect snap_to_terrainShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
	RasterizerState = ShadowRasterizerState
}

# Snap + atlas
Effect snap_to_terrain_atlas_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" }
}
Effect snap_to_terrain_atlasShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" }
	RasterizerState = ShadowRasterizerState
}

# Snap + a2c
Effect snap_to_terrain_alpha_to_coverage_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}
Effect snap_to_terrain_alpha_to_coverageShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}

# Snap + atlas + a2c
Effect snap_to_terrain_atlas_alpha_to_coverage_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "ALPHA_TO_COVERAGE" }
}
Effect snap_to_terrain_atlas_alpha_to_coverageShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}

# Snap + a2c + colormap
Effect snap_to_terrain_alpha_to_coverage_colormap_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "COLORMAP" "ALPHA_TO_COVERAGE" }
}
Effect snap_to_terrain_alpha_to_coverage_colormapShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}

# Snap + a2c + colormap + no second sun
Effect snap_to_terrain_alpha_to_coverage_colormap_singlesun_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "COLORMAP" "ALPHA_TO_COVERAGE" "SINGLESUN" }
}
Effect snap_to_terrain_alpha_to_coverage_colormap_singlesunShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}

# Snap + atlas + a2c + colormap
Effect snap_to_terrain_atlas_alpha_to_coverage_colormap_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "COLORMAP" "ALPHA_TO_COVERAGE" }
}
Effect snap_to_terrain_atlas_alpha_to_coverage_colormapShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ALPHA_TO_COVERAGE" }
}

# Standard flat light
Effect standard_flat_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"

	Defines = { "FLATLIGHT" }
}
Effect standard_flatShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
}

# Standard flat light + alpha blend
Effect standard_flat_alpha_blend_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_test_no_write"

	Defines = { "FLATLIGHT" }
}
Effect standard_flat_alpha_blendShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	RasterizerState = ShadowRasterizerState
}