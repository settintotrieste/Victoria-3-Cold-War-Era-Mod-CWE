

VertexShader =
{		
	Code
	[[
		#define UI_SCREEN_BURN_UV0_MULT float2( 2.4f, 3.1f )
		#define UI_SCREEN_BURN_UV0_SPEED 0.05f
		#define UI_SCREEN_BURN_UV1_SPEED 0.1f

		#define UI_PANNING_TEXTURE_UV0_MULT float2 ( 5.0f, 1.0f )
		#define UI_PANNING_TEXTURE_UV0_SPEED float2 ( 0.0f, 0.4f )

		#define UI_PANNING_TEXTURE_UV2_MULT float2( 3.0f, 0.5f )
		#define UI_PANNING_TEXTURE_UV2_SPEED float2 ( 0.05f, 0.05f)
	]]
}

PixelShader =
{		
	Code
	[[
		#define UV_DIST_STRENGTH 0.1f

		#define LOWER_EDGE_FALLOFF 0.8f
		#define LOWER_EDGE_MULT 1.0f
		#define LOWER_EDGE_CUT 0.1f
		#define LOWER_EDGE_COL_SLIDE 0.1f

		#define UPPER_EDGE_FALLOFF 0.1f
		#define UPPER_EDGE_COL float3( 0.2f, 0.0f, 0.0f )

		#define FINAL_ALPHA_MULT 1.0f
		#define FINAL_COL_MULT 3.0f
	]]
}
