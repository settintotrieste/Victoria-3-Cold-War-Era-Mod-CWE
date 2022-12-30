Includes = {
	"cw/pdxterrain.fxh"
	"jomini/jomini_colormap.fxh"
	"jomini/jomini_colormap_constants.fxh"
	"jomini/jomini_province_overlays.fxh"
	"cw/utility.fxh"
	"cw/camera.fxh"
	"sharedconstants.fxh"
	"constants_game.fxh"
}

PixelShader = {

	TextureSampler FlatmapNoiseMap
	{
		Index = 7
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/textures/flatmap_noise.dds"
		srgb = no
	}

	TextureSampler LandMaskMap
	{
		Index = 9
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/textures/land_mask.dds"
		srgb = yes
	}

	#// Highlight in Red
	#// Occupatioon in Green
	TextureSampler HighlightGradient
	{
		Ref = HighlightGradient
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}

	TextureSampler ImpassableTerrainTexture
	{
		Ref = ImpassableTerrain
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}

	TextureSampler MapPaintingTextures
	{
		Ref = MapPaintingTexturesRef
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}

	TextureSampler CoaAtlas
	{
		Ref = CoaAtlasTexture
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	BufferTexture ProvinceCountryIdBuffer
	{
		Ref = ProvinceCountryId
		type = int
	}
	BufferTexture CountryCoaUvBuffer
	{
		Ref = CountryFlagUvs
		type = float4
	}
	ConstantBuffer( MapCoaConstants0 )
	{
		float MapCoaAngle;
		float MapCoaAspectRatio;
		float MapCoaSize;
		float MapCoaSizeFlatmap;
		float MapCoaBlend;
		float MapCoaBlendFlatmap;
		float MapCoaBlendFadeStart;
		float MapCoaBlendFadeEnd;
		float MapCoaRowOffset;
		float MapCoaRowCount;
		bool  MapCoaEnabled;
	}

	Code
	[[
		#define LAND_COLOR ToLinear( HSVtoRGB( float3( 0.11f, 0.06f, 0.89f ) ) )
		#define HIGHLIGHT_RANGE 0.5f

		int SampleCountryIndex( float2 MapCoords )
		{
			float2 ColorIndex = PdxTex2D( ProvinceColorIndirectionTexture, MapCoords ).rg;
			int Index = ColorIndex.x * 255.0 + ColorIndex.y * 255.0 * 256.0;
			return PdxReadBuffer( ProvinceCountryIdBuffer, Index ).r;
		}

		void ApplyCoaColorBlend( float2 MapCoords, float2 ParalaxCoord, inout float3 Color, inout float PreLightingBlend, inout float PostLightingBlend )
		{
			// Coat of arms should only be shown in some map modes
			if( !MapCoaEnabled )
			{
				return;
			}

			// Provinces where Controller == Owner will have CountryId -1
			int CountryId = SampleCountryIndex( MapCoords );
			if( CountryId >= 0 )
			{
				float CoaAlpha = 1.0f;
				#ifdef HIGH_QUALITY_SHADERS
					float2 Texel = vec2( 1.0f ) / ProvinceMapSize;
					float2 Pixel = ( MapCoords * ProvinceMapSize + 0.5 );
					float2 FracCoord = frac( Pixel );
					Pixel = floor( Pixel ) / ProvinceMapSize - Texel * 0.5f;
					float C00 = 1.0f - saturate( abs( CountryId - SampleCountryIndex( Pixel ) ) );
					float C10 = 1.0f - saturate( abs( CountryId - SampleCountryIndex( Pixel + float2( Texel.x, 0.0 ) ) ) );
					float C01 = 1.0f - saturate( abs( CountryId - SampleCountryIndex( Pixel + float2( 0.0, Texel.y ) ) ) );
					float C11 = 1.0f - saturate( abs( CountryId - SampleCountryIndex( Pixel + Texel ) ) );
					float x0 = lerp( C00, C10, FracCoord.x );
					float x1 = lerp( C01, C11, FracCoord.x );
					CoaAlpha = RemapClamped( lerp( x0, x1, FracCoord.y ), 0.5f, 0.75f, 0.0f, 1.0f );
				#endif
				float4 FlagUvs = PdxReadBuffer4( CountryCoaUvBuffer, CountryId );
				float2 CoaSize = FlatMapLerp < 0.5f ? float2( MapCoaSize, MapCoaSize / MapCoaAspectRatio ) : float2( MapCoaSizeFlatmap, MapCoaSizeFlatmap / MapCoaAspectRatio );
				float2 CoaUV = ParalaxCoord * ProvinceMapSize / CoaSize;

				// Rotate
				float2 Rotation = float2( cos( MapCoaAngle ), sin( MapCoaAngle ) );
				CoaUV.x *= MapCoaAspectRatio;
				CoaUV = float2( CoaUV.x * Rotation.x - CoaUV.y * Rotation.y, CoaUV.x * Rotation.y + CoaUV.y * Rotation.x );
				CoaUV.x /= MapCoaAspectRatio;

				float2 CoaDdx = ddx( CoaUV );
				float2 CoaDdy = ddy( CoaUV );

				// Offset rows horizontally
				CoaUV.x += MapCoaRowOffset * int( mod( CoaUV.y, MapCoaRowCount ) );

				// Tile, flip, and scale to match the atlas
				CoaUV = frac( CoaUV );
				CoaUV.y = 1.0f - CoaUV.y;
				CoaUV = FlagUvs.xy + CoaUV * FlagUvs.zw;

				// First blend in gradient border color on top of CoA color
				// Then adjust the border blend value so that CoA is always shown regardless of gradient
				float3 CoaColor = PdxTex2DGrad( CoaAtlas, CoaUV, CoaDdx, CoaDdy ).rgb;
				CoaColor = ToLinear( CoaColor );

				float Opacity = CoaAlpha * ( MapCoaBlend * ( 1.0f - FlatMapLerp ) ) + ( MapCoaBlendFlatmap * FlatMapLerp );

				float FadeStart = ( MapCoaBlendFadeStart - MapCoaBlendFadeEnd );
				float CloseZoomBlend = FadeStart - CameraPosition.y + ( MapCoaBlendFadeEnd );
				CloseZoomBlend = smoothstep( FadeStart, 0.0f, CloseZoomBlend );
				Opacity *= CloseZoomBlend;

				PreLightingBlend = max( Opacity, PreLightingBlend );

				// Occupation highlight
				float Gradient = 1.0 - PdxTex2D( HighlightGradient, MapCoords ).g;
				float GradientAdd = LevelsScan( Gradient, OCCUPATION_HIGHLIGHT_POSITION, OCCUPATION_HIGHLIGHT_CONTRAST );
				float HighlightAlpha = Opacity * GradientAdd * Gradient;
				float3 HighlightColor = Color * OCCUPATION_HIGHLIGHT_COLOR_MULT;

				// Result
				Color = lerp( Color, saturate( CoaColor ), Opacity );
				Color = lerp( Color, saturate( HighlightColor ), saturate( HighlightAlpha * OCCUPATION_HIGHLIGHT_STRENGTH ) * OCCUPATION_HIGHLIGHT_ALPHA );
			}
 		}

		void ApplyMapTextureAndAlpha( inout float3 Color, inout float alpha, float Mask, float2 UV, int index )
		{
			float4 MapTexture = PdxTex2D( MapPaintingTextures, float3( UV, index ) );
			Color = lerp( Color, MapTexture.rgb, Mask * MapTexture.a );
			alpha = lerp( alpha, alpha * MapTexture.a, Mask );
		}

		void GameProvinceOverlayAndBlend( float2 ColorMapCoords, float3 WorldSpacePos, out float3 ColorOverlay, out float PreLightingBlend, out float PostLightingBlend )
		{
			// Paralx Coord
			float3 ToCam = normalize( CameraPosition - WorldSpacePos );
			float ParalaxDist = ( ImpassableTerrainHeight - WorldSpacePos.y ) / ToCam.y;
			float3 ParalaxCoord = WorldSpacePos + ToCam * ParalaxDist;
			ParalaxCoord.xz = ParalaxCoord.xz * WorldSpaceToTerrain0To1;

			// Gradient border values
			float DistanceFieldValue = CalcDistanceFieldValue( ColorMapCoords );
			float Edge = smoothstep( GB_EdgeWidth + max( 0.001f, GB_EdgeSmoothness ), GB_EdgeWidth, DistanceFieldValue );
			float GradientAlpha = lerp( GB_GradientAlphaInside, GB_GradientAlphaOutside, RemapClamped( DistanceFieldValue, GB_EdgeWidth + GB_GradientWidth, GB_EdgeWidth, 0.0f, 1.0f ) );

			// Default color
			ColorOverlay = LAND_COLOR;
			float4 ProvinceOverlayColorWithAlpha = vec4( 0.0f );

			// Color textures
			float4 PrimaryColor = BilinearColorSample( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture );
			float4 SecondaryColor = BilinearColorSampleAtOffset( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, SecondaryProvinceColorsOffset );
			float4 AlternateColor = BilinearColorSampleAtOffset( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, AlternateProvinceColorsOffset );
			float4 HighlightColor = BilinearColorSampleAtOffset( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );

			// Land/Ocean/Lake masks
			float LandMask = PdxTex2DLod0( LandMaskMap, float2( ColorMapCoords.x, 1.0f - ColorMapCoords.y ) ).r;
			float EndLandMask = 0.0f;
			float ShoreLinesStripes = 0.0f;

			float4 LakeColor = float4( 0.0f, 0.0f, 0.0f, 1.0f );	// Needs to match color in mappaintingmanager.cpp
			float4 LakeDiff = LakeColor - AlternateColor;

			// Not a lake and doesn't have water mass
			if( LandMask <= 0.0f || dot( LakeDiff, LakeDiff ) > 0.1f )
			{
				float4 SeaColor = float4( 0.0f, 0.0f, 1.0f, 0.0f );	// Needs to match color in mappaintingmanager.cpp
				float4 SeaDiff = SeaColor - AlternateColor;

				// Not a sea, so we can use regular landmask
				if( dot( SeaDiff, SeaDiff ) > 0.1f )
				{
					EndLandMask = LandMask;
				}
			}

			// Primary as texture or color
			if ( !_UseMapmodeTextures )
			{
				// Get color
				ProvinceOverlayColorWithAlpha = AlphaBlendAOverB( PrimaryColor, SecondaryColor );
				ProvinceOverlayColorWithAlpha.rgb = lerp( ProvinceOverlayColorWithAlpha.rgb * GB_GradientColorMul, ProvinceOverlayColorWithAlpha.rgb * GB_EdgeColorMul, Edge );
				ProvinceOverlayColorWithAlpha.a = ProvinceOverlayColorWithAlpha.a * max( GradientAlpha, GB_EdgeAlpha * Edge );

				// Apply decentralized country color
				float4 DecentralizedColor = DecentralizedCountryColor;
				float DecentralizedMask = saturate( 1.0f - Edge );

				DecentralizedColor.rgb = DecentralizedCountryColor.rgb;
				DecentralizedColor.a *= AlternateColor.g;
				DecentralizedMask = DecentralizedMask * DecentralizedColor.a * FlatMapLerp;
				ProvinceOverlayColorWithAlpha = lerp( ProvinceOverlayColorWithAlpha, DecentralizedColor, DecentralizedMask );

				// Apply impassable terrain color
				float4 ImpassableDiffuse = float4( PdxTex2D( ImpassableTerrainTexture, float2( ParalaxCoord.x * 2.0f, 1.0f - ParalaxCoord.z ) * ImpassableTerrainTiling ).rgb,  AlternateColor.r );
				ImpassableDiffuse.rgb = Lighten( ImpassableDiffuse.rgb, ImpassableTerrainColor.rgb );
				float ImpassableMask = ImpassableDiffuse.a * ImpassableTerrainColor.a * ( 1.0f - FlatMapLerp );

				// Fade impassable close
				float FadeStart = ( DistanceFadeStart - DistanceFadeEnd );
				float CloseZoomBlend = FadeStart - CameraPosition.y + DistanceFadeEnd;
				CloseZoomBlend = smoothstep( FadeStart, 0.0f, CloseZoomBlend );
				ImpassableMask *= CloseZoomBlend;
				ProvinceOverlayColorWithAlpha = lerp( ProvinceOverlayColorWithAlpha, ImpassableDiffuse, ImpassableMask );

				// Get blendmode
				GetGradiantBorderBlendValues( ProvinceOverlayColorWithAlpha, PreLightingBlend, PostLightingBlend );

				// Apply impassable terrain blendmode
				PreLightingBlend = lerp( PreLightingBlend, 0.0f, ImpassableMask );
				PostLightingBlend = lerp( PostLightingBlend, 1.0f, ImpassableMask );

				// Apply output
				ColorOverlay = ProvinceOverlayColorWithAlpha.rgb;
			}
			else
			{
				float2 MapTextureUvSize = FlatMapLerp < 0.5f ? _MapPaintingTextureTiling : _MapPaintingFlatmapTextureTiling;
				float2 MapTextureUv = float2( ParalaxCoord.x * 2.0f, 1.0f - ParalaxCoord.z ) * MapTextureUvSize;

				// Offset rows horizontally
				MapTextureUv.x += MAPMODE_UV_ROW_OFFSET * int( mod( MapTextureUv.y, MAPMODE_UV_ROW_COUNT ) );

				float MapTextureAlpha = 1.0f;
				float AlphaMask = 0.0f;

				if ( !_UsePrimaryRedAsGradient )
				{
					ApplyMapTextureAndAlpha( ColorOverlay, MapTextureAlpha, PrimaryColor.r, MapTextureUv, 0 );
					AlphaMask += PrimaryColor.r;
				}
				ApplyMapTextureAndAlpha( ColorOverlay, MapTextureAlpha, PrimaryColor.g, MapTextureUv, 1 );
				ApplyMapTextureAndAlpha( ColorOverlay, MapTextureAlpha, PrimaryColor.b, MapTextureUv, 2 );
				ApplyMapTextureAndAlpha( ColorOverlay, MapTextureAlpha, PrimaryColor.a, MapTextureUv, 3 );

				ApplyMapTextureAndAlpha( ColorOverlay, MapTextureAlpha, SecondaryColor.r, MapTextureUv, 4 );
				ApplyMapTextureAndAlpha( ColorOverlay, MapTextureAlpha, SecondaryColor.g, MapTextureUv, 5 );
				ApplyMapTextureAndAlpha( ColorOverlay, MapTextureAlpha, SecondaryColor.b, MapTextureUv, 6 );
				ApplyMapTextureAndAlpha( ColorOverlay, MapTextureAlpha, SecondaryColor.a, MapTextureUv, 7 );

				ApplyMapTextureAndAlpha( ColorOverlay, MapTextureAlpha, AlternateColor.r, MapTextureUv, 8 );
				ApplyMapTextureAndAlpha( ColorOverlay, MapTextureAlpha, AlternateColor.g, MapTextureUv, 9 );

				AlphaMask += PrimaryColor.g + PrimaryColor.b + PrimaryColor.a;
				AlphaMask += SecondaryColor.r + SecondaryColor.g + SecondaryColor.b + SecondaryColor.a;
				AlphaMask += AlternateColor.r + AlternateColor.g;
				AlphaMask = saturate( AlphaMask * EndLandMask * MapTextureAlpha );

				ProvinceOverlayColorWithAlpha.a = lerp( ProvinceOverlayColorWithAlpha.a, 1.0f, AlphaMask );

				ColorOverlay.rgb = lerp( ColorOverlay.rgb * GB_GradientColorMul, ColorOverlay.rgb * GB_EdgeColorMul, Edge );
				ProvinceOverlayColorWithAlpha.a = ProvinceOverlayColorWithAlpha.a * max( GradientAlpha * ( 1.0f - pow( Edge, 2 ) ), GB_EdgeAlpha * Edge );

				GetGradiantBorderBlendValues( ProvinceOverlayColorWithAlpha, PreLightingBlend, PostLightingBlend );
			}

			ApplyCoaColorBlend( ColorMapCoords, ParalaxCoord.xz, ColorOverlay, PreLightingBlend, PostLightingBlend );
		}

		float3 ApplyDynamicFlatmap( float3 FlatMapDiffuse, float2 ColorMapCoords, float2 WorldSpacePosXZ )
		{
			float ExtentStr = ShorelineExtentStr;
			float Alpha = ShorelineAlpha;
			float UVScale = ShoreLinesUVScale;

			#ifndef LOW_QUALITY_SHADERS
				float MaskBlur = ShorelineMaskBlur;
				float LandMaskBlur = PdxTex2DLod( LandMaskMap, float2( ColorMapCoords.x, 1.0f - ColorMapCoords.y ), MaskBlur ).r;
				float ShoreLines = PdxTex2D( FlatmapNoiseMap, ColorMapCoords * UVScale ).r;
				ShoreLines *= saturate( Alpha );
			#endif

			float LandMask = 0.0f;
			float ShoreLinesStripes = 0.0f;

			float4 AlternateColor = BilinearColorSampleAtOffset( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, AlternateProvinceColorsOffset );
			AlternateColor.rg = vec2( 0.0f ); // Zero out unused channels to avoid issues
			float4 LakeColor = float4( 0.0f, 0.0f, 0.0f, 1.0f ); // Needs to match color in mappaintingmanager.cpp
			float4 SeaColor = float4( 0.0f, 0.0f, 1.0f, 0.0f );	// Needs to match color in mappaintingmanager.cpp
			float4 LakeDiff = LakeColor - AlternateColor;
			float4 SeaDiff = SeaColor - AlternateColor;
			float4 LakeSeaDiff = dot( LakeDiff, LakeDiff ) * dot( SeaDiff, SeaDiff );

			// Land color
			float3 Land = LAND_COLOR;
			float OutlineValue = 1.0f - smoothstep( 0.75f, 1.0f, LakeSeaDiff );
			Land = lerp( Land, FlatMapDiffuse, OutlineValue );

			// Not a lake and doesn't have water mass
			if( dot( LakeDiff, LakeDiff ) > 0.1f )
			{
				#ifndef LOW_QUALITY_SHADERS
					ShoreLinesStripes = saturate( LandMaskBlur * ShoreLines * ShorelineExtentStr );
				#endif
				ShoreLinesStripes = saturate( ShoreLinesStripes * ShorelineAlpha );
				ShoreLinesStripes = clamp( ShoreLinesStripes, 0.0, 0.5f );
				FlatMapDiffuse = lerp( FlatMapDiffuse, vec3( 0.0f ), ShoreLinesStripes );

				// Not sea, so apply land mask
				if( dot( SeaDiff, SeaDiff ) > 0.1f )
				{
					LandMask = smoothstep( 0.0f, 0.25f, LakeSeaDiff );
				}
			}

			// Blends in shorelines/flatmap color adjustments
			FlatMapDiffuse = lerp( FlatMapDiffuse, Land, LandMask );

			return FlatMapDiffuse;
		}

		// Convenicence function for changing blend modes in all shaders
		float3 ApplyColorOverlay( float3 Color, float3 ColorOverlay, float Blend )
		{
			float3 HSV_ = RGBtoHSV( ColorOverlay.rgb );
			HSV_.x += 0.0f;		// Hue
			HSV_.y *= 0.95f; 	// Saturation
			HSV_.z *= 0.35f;	// Value
			ColorOverlay.rgb = lerp( ColorOverlay.rgb, HSVtoRGB( HSV_ ), 1.0f - FlatMapLerp );

			Color = lerp( Color, ColorOverlay, Blend );
			return Color;
		}

		float3 ApplyHighlight( float3 Color, float2 Coordinate )
		{
			float Gradient = PdxTex2D( HighlightGradient, Coordinate ).r;

			float SingleSamplingSafeDistance = 0.49f;
			float4 HighlightColor = vec4( 0 );
			if( abs( 0.5f - PdxTex2D( HighlightGradient, Coordinate ).r ) > SingleSamplingSafeDistance )
			{
				// Optimisation - We can use the gradient to quickly gauge where it's safe to use a single sample
				// If the gradient is close to 0.5 then there is a color change somewhere nearby, and multi sampling is needed.
				// Otherwise a single sample will do
				HighlightColor = ColorSampleAtOffset( Coordinate, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
			}
			else
			{
			#ifdef HIGH_QUALITY_SHADERS
				// Lots of double samples here
				// There's no meassurable difference between this naive implementation and a bespoke
				// implementation for reducing the number of samples (on GTX 1080Ti) so assuming the
				// the texture cache is able to handle this just fine.
				// Naive implementation reduces code duplication and makes code simpler
				float2 Offset = InvIndirectionMapSize;
				HighlightColor += BilinearColorSampleAtOffset( Coordinate + Offset * float2( -1, -1 ), IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				HighlightColor += BilinearColorSampleAtOffset( Coordinate + Offset * float2(  0, -1 ), IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				HighlightColor += BilinearColorSampleAtOffset( Coordinate + Offset * float2(  1, -1 ), IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );

				HighlightColor += BilinearColorSampleAtOffset( Coordinate + Offset * float2( -1,  0 ), IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				HighlightColor += BilinearColorSampleAtOffset( Coordinate + Offset * float2(  0,  0 ), IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				HighlightColor += BilinearColorSampleAtOffset( Coordinate + Offset * float2(  1,  0 ), IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );

				HighlightColor += BilinearColorSampleAtOffset( Coordinate + Offset * float2( -1,  1 ), IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				HighlightColor += BilinearColorSampleAtOffset( Coordinate + Offset * float2(  0,  1 ), IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				HighlightColor += BilinearColorSampleAtOffset( Coordinate + Offset * float2(  1,  1 ), IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				HighlightColor /= 9.0f;
			#else
				HighlightColor = BilinearColorSampleAtOffset( Coordinate, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
			#endif
			}

			HighlightColor.a *= 1.0f - Gradient;
			HighlightColor.a = RemapClamped( HighlightColor.a, 0.0f, HIGHLIGHT_RANGE, 0.0f, 1.0f );

			Color = lerp( Color, HighlightColor.rgb, HighlightColor.a );
			return Color;
		}
	]]
}
