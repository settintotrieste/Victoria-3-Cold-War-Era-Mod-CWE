Includes = {
	"cw/pdxterrain.fxh"
	"cw/shadow.fxh"
	"jomini/jomini_water_pdxmesh.fxh"
	"jomini/jomini_mapobject.fxh"
	"sharedconstants.fxh"
	"distance_fog.fxh"
	"cwecoloroverlay.fxh"
	"fog_of_war.fxh"
	"ssao_struct.fxh"
	"pdxwater_game.fxh"
	"lowspec_water.fxh"
}

RasterizerState RasterizerStateBorderLerp
{
	DepthBias = -400
	SlopeScaleDepthBias = -1
}

DepthStencilState DepthStencilStateBorderLerp
{
	DepthWriteEnable = no
}

PixelShader =
{
	TextureSampler FlatMapTexture
	{
		Ref = TerrainFlatMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Clamp"
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

	Code
	[[
		SWaterParameters SetWaterParameters( VS_OUTPUT_WATER Input )
		{
			float2 HeightmapCoordinate = Input.WorldSpacePos.xz;
			#ifdef JOMINIWATER_BORDER_LERP
				HeightmapCoordinate.x -= JOMINIWATER_MapSize.x;
			#endif
			float Height = GetHeightMultisample( HeightmapCoordinate, 0.65 );
			float Depth = Input.WorldSpacePos.y - Height;

			SWaterParameters Params;
			Params._ScreenSpacePos = Input.Position;
			Params._WorldSpacePos = Input.WorldSpacePos;
			Params._WorldUV = Input.UV01;
			Params._Depth = Depth;
			Params._NoiseScale = 0.05f;
			Params._WaveSpeedScale = 1.0f;
			Params._WaveNoiseFlattenMult = 1.0f;
			Params._FlowNormal = CalcFlowGame( FlowMapTexture, FlowNormalTexture, Params._WorldUV, Params._WorldSpacePos.xz, Params._FlowFoamMask );

			return Params;
		}
	]]

	MainCode GameWaterPixelShader
	{
		Input = "VS_OUTPUT_WATER"
		Output = "PS_COLOR_SSAO"
		Code
		[[
			PDX_MAIN
			{
				PS_COLOR_SSAO Out;
				float4 Water = float4( 0.0f, 0.0f, 1.0f, 1.0f );

				#ifdef LOW_QUALITY_SHADERS
					Water = CalcWaterLowSpec( Input );
				#else
					SWaterParameters Params = SetWaterParameters( Input );
					Water = GameCalcWater( Params );
				#endif

				#ifdef CANAL
					Water.a = 1.0f;
				#endif
				clip( Water.a - 0.001f );
				float2 ProvinceCoords = Input.WorldSpacePos.xz / ProvinceMapSize;

				// Simple shadows
				#ifndef LOW_QUALITY_SHADERS
					float4 ShadowProj = mul( ShadowMapTextureMatrix, float4( Input.WorldSpacePos, 1.0 ) );
					float ShadowTerm = CalculateShadow( ShadowProj, ShadowMap );
					Water.rgb = Water.rgb * saturate( ShadowTerm + ( CubemapIntensity * WaterShadowMultiplier ) );
				#endif

				// Fog
				Water.rgb = ApplyFogOfWar( Water.rgb, Input.WorldSpacePos, 0.4 );
				Water.rgb = GameApplyDistanceFog( Water.rgb, Input.WorldSpacePos );

				// Flatmap texture and style
				if( FlatMapLerp > 0.0f )
				{
					float3 FlatMap = PdxTex2D( FlatMapTexture, Input.UV01 ).rgb;
					FlatMap = ApplyDynamicFlatmap( FlatMap, ProvinceCoords, Input.WorldSpacePos.xz );

					Water.rgb = lerp( Water.rgb, FlatMap, FlatMapLerp );
				}

				// Output
				Out.Color = Water;

				// Process to mask out SSAO where water become opaque, using SSAO color
				Out.SSAOColor = float4( 1.0f, 1.0f, 1.0f, Water.a );

				return Out;
			}
		]]
	}
}

RasterizerState RasterizerState
{
	DepthBias = 0
	SlopeScaleDepthBias = 0
}

Effect water
{
	VertexShader = "JominiWaterVertexShader"
	PixelShader = "GameWaterPixelShader"
}

Effect water_border_lerp
{
	VertexShader = "JominiWaterVertexShader"
	PixelShader = "GameWaterPixelShader"

	RasterizerState = "RasterizerStateBorderLerp"
	DepthStencilState = "DepthStencilStateBorderLerp"

	Defines = { "JOMINIWATER_BORDER_LERP" }
}


Effect lake
{
	VertexShader = "VS_jomini_water_mesh"
	PixelShader = "GameWaterPixelShader"
}
Effect lake_mapobject
{
	VertexShader = "VS_jomini_water_mapobject"
	PixelShader = "GameWaterPixelShader"
}


Effect water_canal
{
	VertexShader = "VS_jomini_water_mesh"
	PixelShader = "GameWaterPixelShader"

	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "CANAL" }
}
Effect water_canal_mapobject
{
	VertexShader = "VS_jomini_water_mapobject"
	PixelShader = "GameWaterPixelShader"

	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "CANAL" }
}
