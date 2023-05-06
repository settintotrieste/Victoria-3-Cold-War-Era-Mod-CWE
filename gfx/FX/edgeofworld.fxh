PixelShader = {
	ConstantBuffer( GameEdgeOfWorldConstants )
	{
		float4	HighCloudColor;
		float4	LowCloudColor;

		float2	BaseCloudScrolling;
		float2	Cloud1Scrolling;
		float2	Cloud2Scrolling;

		int		BaseCloudTileFactor;
		float	BaseCloudStrength;
		float	BaseCloudPosition;
		float	BaseCloudContrast;

		int		Cloud1TileFactor;
		float	Cloud1Strength;
		float	Cloud1Position;
		float	Cloud1Contrast;

		int		Cloud2TileFactor;
		float	Cloud2Strength;
		float	Cloud2Position;
		float	Cloud2Contrast;

		float	ColorMultiply;
		float	FadeDistance;
	}

	TextureSampler EdgeOfWorldTexture
	{
		Ref = EdgeOfWorld
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

	Code [[	

		// TODO: Consider renaming or merging this with Rotate function in standardfuncsgfx.fxh
		void Rotate2( inout float2 p, float a ) 
		{
			p = cos( a ) * p + sin( a ) * float2( p.y, -p.x );
		}

		float Circle( float2 p, float r )
		{
			return ( length( p / r ) - 1.0 ) * r;
		}

		float Rand( float2 c )
		{
			return frac( sin( dot( c.xy, float2( 12.9898, 78.233 ) ) ) * 43758.5453 );
		}

		void BokehLayerLarge( inout float3 color, float2 p, float3 c, inout float LightWeight )
		{
			float wrap = 500.0f;
			if ( mod( floor( p.y / wrap + 0.5 ), 2.0 ) == 0.0 )
			{
				p.x += wrap * 0.5;
			}
			
			float2 p2 = mod( p + 0.5 * wrap, wrap ) - 0.5 * wrap;
			float2 cell = floor( p / wrap + 0.5 );
			float cellR = Rand( cell );
				
			c *= frac( cellR * 3.33 + 3.33 );    
			float radius = lerp( 30.0, 200.0, frac( cellR * 7.77 + 7.77 ) );
			p2.x *= lerp( 0.7, 1.1, frac( cellR * 11.13 + 11.13 ) );
			p2.y *= lerp( 0.7, 1.1, frac( cellR * 17.17 + 17.17 ) );
			
			float sdf = Circle( p2, radius );
			float circle = 1.0 - smoothstep( 0.0, 1.0, sdf * 0.02 );
			float glow	= exp( -sdf * 0.025 ) * 0.2 * ( 1.0 - circle );
			color += c * ( circle + glow );

			LightWeight += c * ( circle + glow ) * 0.2f;
		}

		void BokehLayerMedium( inout float3 color, float2 p, float3 c, inout float LightWeight )
		{
			float wrap = 2500.0f;
			if ( mod( floor( p.y / wrap + 0.5 ), 2.0 ) == 0.0 )
			{
				p.x += wrap * 1.5;
			}
			
			float2 p2 = mod( p + 0.5 * wrap, wrap ) - 0.5 * wrap;
			float2 cell = floor( p / wrap + 0.5 );
			float cellR = Rand( cell );
				
			c *= frac( cellR * 3.33 + 3.33 );
			float radius = lerp( 10.0, 80.0, frac( cellR * 7.77 + 7.77 ) );
			p2.x *= lerp( 0.7, 1.1, frac( cellR * 11.13 + 11.13 ) );
			p2.y *= lerp( 0.7, 1.1, frac( cellR * 17.17 + 17.17 ) );
			
			float sdf = Circle( p2, radius );
			float circle = 1.0 - smoothstep( 0.0, 1.5, sdf * 0.015 );
			float glow	= exp( -sdf * 0.025 ) * 0.1 * ( 1.0 - circle );
			color += c * ( circle + glow );

			LightWeight += c * ( circle + glow ) * 3.0f;
		}

		void BokehLayerMedium2( inout float3 color, float2 p, float3 c, inout float LightWeight )
		{
			float wrap = 1100.0f;
			if ( mod( floor( p.y / wrap + 0.5 ), 2.0 ) == 0.0 )
			{
				p.x += wrap * 1.5;
			}
			
			float2 p2 = mod( p + 0.5 * wrap, wrap ) - 0.5 * wrap;
			float2 cell = floor( p / wrap + 0.5 );
			float cellR = Rand( cell );
				
			c *= frac( cellR * 3.33 + 3.33 );
			float radius = lerp( 10.0, 110.0, frac( cellR * 7.77 + 7.77 ) );
			p2.x *= lerp( 0.7, 1.1, frac( cellR * 11.13 + 11.13 ) );
			p2.y *= lerp( 0.7, 1.1, frac( cellR * 17.17 + 17.17 ) );
			
			float sdf = Circle( p2, radius );
			float circle = 1.0 - smoothstep( 0.0, 1.5, sdf * 0.015 );
			float glow	= exp( -sdf * 0.025 ) * 0.1 * ( 1.0 - circle );
			color += c * ( circle + glow );

			LightWeight += c * ( circle + glow ) * 2.0f;
		}

		void BokehLayerSmall( inout float3 color, float2 p, float3 c, inout float LightWeight )
		{
			float wrap = 7000.0f;
			if ( mod( floor( p.y / wrap + 0.5 ), 2.0 ) == 0.0 )
			{
				p.x += wrap * 0.5;
			}
			
			float2 p2 = mod( p + 0.5 * wrap, wrap ) - 0.5 * wrap;
			float2 cell = floor( p / wrap + 0.5 );
			float cellR = Rand( cell );
				
			c *= frac( cellR * 3.33 + 3.33 );    
			float radius = lerp( 2.0, 12.0, frac( cellR * 7.77 + 7.77 ) );
			p2.x *= lerp( 0.2, 1.0, frac( cellR * 11.13 + 11.13 ) );
			p2.y *= lerp( 0.2, 1.0, frac( cellR * 17.17 + 17.17 ) );
			
			float sdf = Circle( p2, radius );
			float circle = 1.0 - smoothstep( 0.0, 1.0, sdf * 0.02 );
			float glow	= exp( -sdf * 0.025 ) * 0.1 * ( 1.0 - circle );
			color += c * ( circle + glow );

			LightWeight += c * ( circle + glow ) * 5.0f;
		}

		float invLerp(float from, float to, float value)
		{
			return (value - from) / (to - from);
		}
		
	]]
}