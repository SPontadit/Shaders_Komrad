Shader "Unlit/DiscoEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ScanlineTex("Scanline Texture Horizontal", 2D) = "white" {}
		_ScanlineTexVert("Scanline Texture Vertical", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		_Noise("Noise", 2D) = "white" {}
		_Blend("Blend", Range(0, 1)) = 0.5
		_Size("Size", Float) = 1
		_Brightness("Bright", Float) = 1
		_Speed("Speed", Vector) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _ScanlineTex;
			float4 _ScanlineTex_ST;

			sampler2D _ScanlineTexVert;
			float4 _ScanlineTexVert_ST;

			sampler2D _Mask;
			fixed4 _Mask_ST;

			sampler2D _Noise;
			float4 _Noise_ST;

			fixed _Blend;
			fixed _Size;
			float4 _Speed;
			float _Brightness;

			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 speed = _Speed.xy;

				float2 uv = i.uv;

				
				uv.x += (0.45 * step(cos(_Time.y * 10.0), 0.0));
				uv *= -0.05;
				uv -= float2(_Time.x, _Time.x) * (speed / 20.0);

				fixed4 base = tex2D(_MainTex, i.uv);

				fixed4 scanLine = tex2D(_ScanlineTex, uv * _ScanlineTex_ST.xy * _Size);
				scanLine += tex2D(_ScanlineTexVert, uv * _ScanlineTexVert_ST.xy * _Size);
				

				uv = i.uv + float2(_Time.x, _Time.x) * speed;
				fixed4 noise = tex2D(_Noise, uv *_Noise_ST.xy * _Size).r;
				
				scanLine += noise;

				fixed mask = tex2D(_Mask, uv * _Mask_ST.xy * _Size).r;
				//mask = 1.0 - mask;
				scanLine *= mask;

				float bright = lerp(2.0, 5.0, (cos(_Time.y) * 0.5) + 0.5);

				scanLine *= bright;
				
				//mask = saturate(mask);

				return lerp(base, base * scanLine, _Blend);



				scanLine *= noise;

				
				

				//return base * mask;
			}
			ENDCG
		}
	}
}
