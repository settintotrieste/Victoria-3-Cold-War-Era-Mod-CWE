Includes = {
	"cw/fullscreen_vertexshader.fxh"
	"cw/random.fxh"
	"jomini/jomini_colormap_constants.fxh"
	"cwecoloroverlay.fxh"
}

ConstantBuffer( PdxConstantBuffer0 )
{
	float2		KernelSize;
	int			NumSamples;
	float alignment_dummy;
	float4		DiscSamples[8];
}

PixelShader =
{
	MainCode PixelShader
	{
		Input = "VS_OUTPUT_FULLSCREEN"
		Output = "PDX_COLOR"
		Code
		[[
			float2 RotateDisc( float2 Disc, float2 Rotate )
			{
				return float2( Disc.x * Rotate.x - Disc.y * Rotate.y, Disc.x * Rotate.y + Disc.y * Rotate.x );
			}
			PDX_MAIN
			{
				// Scan the map for pixels that have a highlight color with non-zero alpha.
				// The gradient's alpha will be the % of samples that have a highlight color.
				// Poisson disc sampling is used to cover a large area with relatively few samples.
				// To avoid recalculating the poisson offsets for each pixel we get a precalculated
				// list of samples from the CPU, that each pixel can rotate randomly to avoid visible
				// artifacts that normally appear when they all sample using the same pattern.
				float Alpha = 0.0;
				float RandomAngle = CalcRandom( Input.uv ) * 3.14159 * 2.0;
				float2 Rotate = float2( cos( RandomAngle ), sin( RandomAngle ) );
				int Samples = ( NumSamples + 1 ) / 2;
				for( int i = 0; i < Samples; ++i )
				{
					float2 ColorIndex = PdxTex2DLod0( ProvinceColorIndirectionTexture, Input.uv + RotateDisc( DiscSamples[i].xy, Rotate ) * KernelSize ).rg;
					Alpha += step( 1.0f/255.0f, PdxTex2DLoad0( ProvinceColorTexture, int2( ColorIndex * 255.0 + vec2( 0.5 ) + HighlightProvinceColorsOffset ) ).r );

					ColorIndex = PdxTex2DLod0( ProvinceColorIndirectionTexture, Input.uv + RotateDisc( DiscSamples[i].zw, Rotate ) * KernelSize ).rg;
					Alpha += step( 1.0f/255.0f, PdxTex2DLoad0( ProvinceColorTexture, int2( ColorIndex * 255.0 + vec2( 0.5 ) + HighlightProvinceColorsOffset ) ).r );
				}
				Alpha /= Samples * 2;

			float CoaAlpha = 0.0;
			int CountryId = SampleCountryIndex( Input.uv );
			// Provinces where Controller == Owner will have CountryId -1
			if( CountryId >= 0 )
			{
				for( int i = 0; i < Samples; ++i )
				{
					float2 ColorIndex = PdxTex2DLod0( ProvinceColorIndirectionTexture, Input.uv + RotateDisc( DiscSamples[i].xy, Rotate ) * KernelSize ).rg;
					int Index = ColorIndex.x * 255.0 + ColorIndex.y * 255.0 * 256.0;
					CoaAlpha += step( 1.0f / 255.0f,  PdxReadBuffer( ProvinceCountryIdBuffer, Index ).r );

					ColorIndex = PdxTex2DLod0( ProvinceColorIndirectionTexture, Input.uv + RotateDisc( DiscSamples[i].zw, Rotate ) * KernelSize ).rg;
					Index = ColorIndex.x * 255.0 + ColorIndex.y * 255.0 * 256.0;
					CoaAlpha += step( 1.0f / 255.0f,  PdxReadBuffer( ProvinceCountryIdBuffer, Index ).r );
				}
				CoaAlpha /= Samples * 2;
			}


				return float4( Alpha, CoaAlpha, 0, 0 );
			}
		]]
	}
}

BlendState BlendState
{
	BlendEnable = no
}
Effect RenderGradient
{
	VertexShader = VertexShaderFullscreen
	PixelShader = PixelShader
}