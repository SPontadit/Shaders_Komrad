Shader "Custom/GaussianBlurSprite"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_AlphaNoise("alpha", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap("Pixel snap", Float) = 0
		_Size("Size", Range(0, 0.2)) = 0.04
	}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"
			//	"CanUseSpriteAtlas" = "True"
			}

			Cull Off
			Lighting Off
			ZWrite Off
			Blend One OneMinusSrcAlpha

			Pass
			{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile _ PIXELSNAP_ON
				#include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex   : POSITION;
					float4 color	: COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex   : SV_POSITION;
					float4 color	: COLOR;
					float2 uv : TEXCOORD1;
				};

				float4 _MainTex_ST;
				float4 _Color;

				v2f vert(appdata_t IN)
				{
					v2f OUT;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);

					#ifdef PIXELSNAP_ON
					OUT.vertex = UnityPixelSnap(OUT.vertex);
					#endif

					OUT.uv = TRANSFORM_TEX(IN.texcoord, _MainTex);
					OUT.color = IN.color * _Color;

					return OUT;
				}

				sampler2D _MainTex;
				float4 _MainTex_TexelSize;
				float _Size;

				float rand(float2 co) 
				{
					return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
				}

				float4 GaussianBlur(sampler2D mainTex, float2 uv)
				{
					float4 color;
					float4 blurredImage = float4(0, 0, 0, 0);

					float repeat = 45.0;
					for (float i = 0.0; i < repeat; i++)
					{
						float2 q = float2(cos(degrees((i / repeat) * 360.0)), sin(degrees((i / repeat)*360.0))) * (rand(float2(i, uv.x + uv.y)) + _Size);
						float2 uv2 = uv + (q* _Size);
						color = tex2D(mainTex, uv2);
						blurredImage += (color / 2.0 * color.a);
					
						q = float2(cos(degrees((i / repeat) * 360.0)), sin(degrees((i / repeat)*360.0))) * (rand(float2(i+2.0, uv.x + uv.y+24.0)) + _Size);
						uv2 = uv + (q* _Size);
						color = tex2D(mainTex, uv2);
						blurredImage += (color / 2.0 * color.a);
					}

					blurredImage /= repeat;

					return blurredImage;
				}

				half4 frag(v2f IN) : COLOR
				{
					float4 blur = GaussianBlur(_MainTex, IN.uv) * IN.color;

					return blur;
				}
				ENDCG
			}
		}
}