Includes = {
	"cw/shadow.fxh"
	"cw/pdxterrain.fxh"
	"cw/utility.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_spline.fxh"
	"jomini/jomini_province_overlays.fxh"
	"sharedconstants.fxh"
	"distance_fog.fxh"
	"cwecoloroverlay.fxh"
	"dynamic_masks.fxh"
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
	TextureSampler NormalTexture
	{
		Ref = PdxTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler MaterialTexture
	{
		Ref = PdxTexture2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler MaskTexture
	{
		Ref = PdxTexture3
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

	Code
	[[

		float4 GetPixelColor(
			VS_OUTPUT Input,
			float2 UV,
			float2 ddx,
			float2 ddy,
			float EdgeOpacityThresholdInWorldSpace,
			float MaskValue )
		{
			float4 Diffuse;
			float4 Properties;
			float3 Normal;

			float2 MapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
			float2 ProvinceCoords = Input.WorldSpacePos.xz / ProvinceMapSize;

			// Using ddx and ddy because there is a code path that supportes stacking texture on top
			// Which results in discontinuties in texture lookup if we don't use ddx, ddy
			Diffuse = PdxTex2DGrad( DiffuseTexture, UV, ddx, ddy );
			Properties = PdxTex2DGrad( MaterialTexture, UV, ddx, ddy );

			// Alpha
			Diffuse.a *= MaskValue;
			Diffuse.a *= JominiFlatSplineEdgeOpacity( Input.UV.x / UVScale, Input.MaxU / UVScale, EdgeOpacityThresholdInWorldSpace);
			Diffuse.a *= 1.0f - FlatMapLerp;	// Flat map fade
			clip( Diffuse.a - 0.0001f );


			// Normals
			float3 TerrainNormal = CalculateNormal( Input.WorldSpacePos.xz );	// Terrain normals
			float3 RoadNormal = JominiFlatSplineSampleNormal( NormalTexture, normalize( TerrainNormal ), normalize( Input.Tangent ), UV, ddx, ddy);	// Using the terrain normal works fine here
			Normal = RoadNormal;

			// Dynamic mask
			ApplyDevastationRoads( Diffuse, Input.WorldSpacePos.xz );

			#ifndef LOW_QUALITY_SHADERS
				float IridescenceMask = 0.0f;
				float TempAlpha = Diffuse.a;	// Can use terrain pollution function if storing alpha
				ApplyPollutionMaterial( Diffuse, TerrainNormal, Properties, Input.WorldSpacePos.xz, IridescenceMask );
				Diffuse.a = TempAlpha;
			#endif

			// Color overlay
			float3 ColorOverlay;
			float PreLightingBlend;
			float PostLightingBlend;
			GameProvinceOverlayAndBlend( ProvinceCoords, Input.WorldSpacePos, ColorOverlay, PreLightingBlend, PostLightingBlend );
			Diffuse.rgb = ApplyColorOverlay( Diffuse.rgb, ColorOverlay, PreLightingBlend );

			// Properties and color
			float3 Color = Diffuse.rgb;
			Properties.a = ScaleRoughnessByDistance( Properties.a, Input.WorldSpacePos );
			SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Properties.a, Properties.g, Properties.b );
			SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTexture );
			#ifndef LOW_QUALITY_SHADERS
				Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
			#endif

			// Effects, post light
			Color = ApplyColorOverlay( Color, ColorOverlay, PostLightingBlend );
			Color = ApplyFogOfWar( Color, Input.WorldSpacePos );
			Color = GameApplyDistanceFog( Color, Input.WorldSpacePos );

			// Province Highlight
			Color = ApplyHighlight( Color, ProvinceCoords );

			DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );
			return float4( Color.rgb, Diffuse.a );
		}

		float4 GetPixelColorWithMaskApplied(
			VS_OUTPUT Input,
			int MaskIndex)
		{
			float2 UV = Input.UV;
			float2 dx=float2(0,0), dy=float2(0,0);

			dx = ddx(UV);
			dy = ddy(UV);

			float2 Mask = float2(1,1);
			Mask = JominiFlatSplineSampleMask( MaskTexture, Input );

			return GetPixelColor( Input, UV, dx, dy, 0, Mask[MaskIndex] );
		}

	]]

	MainCode Background
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				//clip(-1);
				return GetPixelColorWithMaskApplied( Input, 0 );
			}
		]]
	}

	MainCode Foreground
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[

			PDX_MAIN
			{
				//clip(-1);
				return GetPixelColorWithMaskApplied( Input, 1 );
			}
		]]
	}

	MainCode StackedTexturesPass
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[

			PDX_MAIN
			{
				//clip(-1);
				float2 UV = Input.UV;
				float2 dx=float2(0,0), dy=float2(0,0);

				JominiFlatSplineStackedUV( Input, 8, UV, dx, dy );

				return GetPixelColor( Input, UV, dx, dy, 1.2, 1 );
			}
		]]
	}

	MainCode SingleTexturePass
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[

			PDX_MAIN
			{
				//clip(-1);
				float2 UV = Input.UV;
				float2 dx=float2(0,0), dy=float2(0,0);

				dx = ddx(UV);
				dy = ddy(UV);

				return GetPixelColor( Input, UV, dx, dy, 1.2, 1 );
			}
		]]
	}
}

BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
	WriteMask = "RED|GREEN|BLUE"
}

#// Avoid rendering roads under terrain
RasterizerState RasterizerState
{
	DepthBias = -2000
	SlopeScaleDepthBias = -10
}

DepthStencilState DepthStencilState
{
	DepthWriteEnable = no
}

Effect Background
{
	VertexShader = "VertexShader"
	PixelShader = "Background"
}
Effect Foreground
{
	VertexShader = "VertexShader"
	PixelShader = "Foreground"
}

Effect StackedTexturesPass
{
	VertexShader = "VertexShader"
	PixelShader = "StackedTexturesPass"
}
Effect SingleTexturePass
{
	VertexShader = "VertexShader"
	PixelShader = "SingleTexturePass"
}
