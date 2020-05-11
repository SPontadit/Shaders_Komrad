Shader "Unlit/DanceFloor"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "white" {}
		_ColorTex("Color Texture", 2D) = "white" {}
		_DeformerTex("Deformer Texture", 2D) = "white" {}
	
		_DeformerSpeedX("Deformer Speed X", Float) = 0
		_DeformerSpeedY("Deformer Speed Y", Float) = 0


		[PowerSlider(3.0)] _Intensity("Intensity", Range(-1.5, 1.5)) = 0.1
		[PowerSlider(3.0)] _ColorIntensity("ColorIntensity", Range(0.75, 1.5)) = 0.1
		_ColorSize("Color Size", Range(-5, 5)) = 1
		_ColorSpeedX ("Color Speed X", Float) = 0
		_ColorSpeedY ("Color Speed Y", Float) = 0

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
				float2 uvDeformer : TEXCOORD1;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uvDeformer : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvDeformer = v.uv;
				o.color = v.color;

				return o;
			}

			sampler2D _MaskTex;
			float4 _MaskTex_ST;

			sampler2D _ColorTex;
			float4 _ColorTex_ST;

			sampler2D _DeformerTex;
			float4 _DeformerTex_ST;

			float _ColorSize;
			float _ColorSpeedX;
			float _ColorSpeedY;
			float _DeformerSpeedX;
			float _DeformerSpeedY;

			float _Intensity;
			float _ColorIntensity;
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 danceFloor = tex2D(_MainTex, i.uv);
			
				float2 colorUV = i.uv * _ColorSize;
				colorUV.x += _Time.y * _ColorSpeedX;
				colorUV.y += _Time.y * _ColorSpeedY;

				//colorUV.y += _Time.y * _SpeedY;

				float2 deformerUV = i.uvDeformer * _DeformerTex_ST;
				deformerUV.x += _Time.y * _DeformerSpeedX;
				deformerUV.y += _Time.y * _DeformerSpeedY;

				float deformer = tex2D(_DeformerTex, deformerUV);
				deformer = 1 - deformer;

				float2 uvOffset = deformer * _Intensity * 0.5;
				colorUV += uvOffset;


				fixed4 color = tex2D(_ColorTex, colorUV) * i.color;



				fixed danceFlooMask = tex2D(_MaskTex, (i.uv * _MaskTex_ST.xy) + _MaskTex_ST.zw).r;
				
				float percent = (cos(_Time.y * 15) * 0.5) + 0.5;

				fixed4 finalColor = lerp(danceFloor * (color*0.2), color * danceFloor * danceFlooMask, percent);
				
				danceFlooMask = 1 - danceFlooMask;
				finalColor += danceFloor * danceFlooMask * i.color;

				float bright = lerp(0.85, 1.25, (cos(_Time.y) * 0.5) + 0.5);



				return finalColor * 1.75;
			}

			ENDCG
		}
	}
}
