Shader "Custom/TVNoiseEffect"
{
	Properties
	{
		[Header(Noise)]
		_MainTex ("Texture", 2D) = "white" {}
		_SecondTex("Second Texture", 2D) = "white" {}

		_Alpha("Alpha", Range(0, 1)) = 1

		_PanningTex1_X("Panning Tex1 X", Float) = 0
		_PanningTex1_Y("Panning Tex1 Y", Float) = 0
		[Space(15)]
		_PanningTex2_X("Panning Tex2 X", Float) = 0
		_PanningTex2_Y("Panning Tex2 Y", Float) = 0
		[Space(15)]
		_ThresholdTex1("Threshold Tex1", Range(0, 1)) = 0.5
		_ThresholdTex2("Threshold Tex2", Range(0, 1)) = 0.5
		
		_IntensityTex2("Intensity Tex2", Range(0, 1)) = 0.5
		_Speed("Speed", Range(0, 5)) = 0.5

		[Space(30)]
		[Header(ScanLine)]
		_ScanLineMask("ScanLine Mask", 2D) = "white" {}
		_ScanLinePanningY("ScanLine Panning Y", Float) = 0
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			sampler2D _SecondTex;
			float _PanningTex1_X;
			float _PanningTex1_Y;
			float _PanningTex2_X;
			float _PanningTex2_Y;
			float _ThresholdTex1;
			float _ThresholdTex2;

			float _IntensityTex2;
			float _Speed;
			float _Alpha;

			fixed4 Glitch(float2 uv)
			{
				float2 offset1 = float2(_PanningTex1_X, _PanningTex1_Y);
				float2 offset2 = float2(_PanningTex2_X, _PanningTex2_Y);


				fixed4 col = tex2D(_MainTex, uv + (_Time.x * (_Speed * offset1)));
				fixed4 col2 = tex2D(_SecondTex, uv + (_Time.x * (_Speed * offset2)));


				float t = cos(_Time.y);
				t = (t + 1.0) * 0.5;

				float threshold = lerp(_ThresholdTex1, _ThresholdTex2, t);
				//threshold 
				col = step(threshold, col);
				col2 = step(threshold, col2);



				float intensity = lerp(0.0, _IntensityTex2, t);

				col2 = max(intensity, col2);

				col = col * col2;
				col = saturate(col);

				return col;
			}

			sampler2D _ScanLineMask;
			float _ScanLinePanningY;

			fixed ScanLine(float2 uv)
			{
				uv.y += _ScanLinePanningY * _Time.x;
				float mask = tex2D(_ScanLineMask, uv);

				return 1 - mask;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(0,0,0,0);
			
				col += Glitch(i.uv);

				col.rgb *= ScanLine(i.uv);	

				col = saturate(col);

				return col * _Alpha;
			}
			ENDCG
		}
	}
}
