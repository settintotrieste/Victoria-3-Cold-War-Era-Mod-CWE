Includes = {
	"jomini/jomini_river_surface.fxh"
	"jomini/jomini_province_overlays.fxh"
	"cw/pdxterrain.fxh"
	"sharedconstants.fxh"
	"distance_fog.fxh"
	"cwecoloroverlay.fxh"
	"fog_of_war.fxh"
	"ssao_struct.fxh"
	"lowspec_water.fxh"
}

PixelShader =
{
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

	MainCode PS_surface
	{
		Input = "VS_OUTPUT_RIVER"
		Output = "PS_COLOR_SSAO"
		Code
		[[
			PDX_MAIN
			{
				PS_COLOR_SSAO Out;

				float2 MapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				float2 ProvinceCoords = Input.WorldSpacePos.xz / ProvinceMapSize;

				// Light and shadow
				#ifdef LOW_QUALITY_SHADERS
					float4 Color = CalcRiverLowSpec( Input );
				#else
					float4 Color = GameCalcRiver( Input );
				#endif

				// Border color overlay
				float3 ColorOverlay;
				float PreLightingBlend;
				float PostLightingBlend;
				GameProvinceOverlayAndBlend( ProvinceCoords, Input.WorldSpacePos, ColorOverlay, PreLightingBlend, PostLightingBlend );
				Color.rgb = ApplyColorOverlay( Color.rgb, ColorOverlay, saturate( PreLightingBlend + PostLightingBlend ) );

				// Effects, post light
				Color.rgb = ApplyFogOfWar( Color.rgb, Input.WorldSpacePos );
				Color.rgb = GameApplyDistanceFog( Color.rgb, Input.WorldSpacePos );

				// Highlight
				Color.rgb = ApplyHighlight( Color.rgb, ProvinceCoords );

				// Flagmap fade-out
				Color.a *= 1.0f - FlatMapLerp;

				// Output
				Out.Color = Color;
				// Process to mask out SSAO where rivers become opaque, using SSAO color
				Out.SSAOColor = float4(1.0f, 1.0f, 1.0f, Color.a);

				return Out;
			}
		]]
	}
}

Effect river_surface
{
	VertexShader = "VertexShader"
	PixelShader = "PS_surface"
	Defines = { "RIVER" }
}

#// Avoid rendering rivers under terrain
RasterizerState RasterizerState
{
	DepthBias = -2000
	SlopeScaleDepthBias = -10
}