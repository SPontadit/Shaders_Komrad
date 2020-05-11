Shader "NegativeEffect/ScanLine"
{
	Properties
	{
		[HideInInspector] _MainTex("Texture", 2D) = "white" {}
		
		[Header(Color)]
		_RedPower("Red Level", Range(0.0, 7.0)) = 0.5
		_GreenPower("Green Level", Range(0.0, 7.0)) = 1.5
		_BluePower("Blue Level", Range(0.0, 7.0)) = 0.5

		[Header(Mask)]
		[PowerSlider(2.5)] _Attenuation("Attenuation", Range(0.01, 20.0)) = 6.0
		[PowerSlider(5.0)] _Size("Size", Range(0.5, 50.0)) = 1.1

		[Header(Scan)]
		_ScanFrequency("Scan frenquency", Range(0.001, 0.08)) = 0.021
		_ScanFrequencyBis("Scan frenquency Bis", Range(0.001, 0.05)) = 0.021
		_Speed("Speed", Range(0, 20)) = 0

		[Header(Displacement)]
		_DisplacementTex("Displacement Texture", 2D) = "" {}
		_DisplacementStrenght("Strenght", Range(-2.0, 2.0)) = 0.01
	}
	
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;

			float _RedPower;
			float _GreenPower;
			float _BluePower;

			float _Attenuation;
			float _Size;

			float _ScanFrequency;
			float _ScanFrequencyBis;
			float _Speed;

			sampler2D _DisplacementTex;
			float _DisplacementStrenght;

			fixed4 frag(v2f_img i) : SV_Target
			{
				half2 n = tex2D(_DisplacementTex, i.uv);
				half2 d = n * 2 - 1;
				float2 uvDisp = i.uv;
				uvDisp += d * _DisplacementStrenght;
				uvDisp = saturate(uvDisp);

				fixed4 tex = tex2D(_MainTex, uvDisp);

				float2 uv = i.uv;
				float2 uv2 = uv + _Time.x * _Speed;


				//uv2 += float2(sin(i.pos.y) / 50.0 + _Time.y * 50.0 / 2.0, 0.0);

				// Curve image side
				//uv2 *= 1.0 + pow(length(uv*uv*uv*uv), 4.0) * 0.07;
				
				fixed c = 0.8 + 0.8 * uv.y;
				fixed3 color = fixed3(c, c, c);

				fixed3 rain = 0.0;
				color = lerp(rain, color, clamp(_Time.y * 1.5 - .5, 0., 1.));
				

				// Mask
				float2 uv3 = i.pos.xy / _ScreenParams.xy * 2.0 - 1.0;
				color *= 1.0 - pow(length(uv3*uv3*uv3*uv3)* _Size, _Attenuation);


				uv2.y *= _ScreenParams.y / 360.0;
				uv2.x *= _ScreenParams.x / 360.0;
				 
				color.r *= (0.5 + abs(0.5 - fmod(uv2.y		  , _ScanFrequency) / _ScanFrequencyBis) * _RedPower) * 1.5;
				color.g *= (0.5 + abs(0.5 - fmod(uv2.y + 0.007, _ScanFrequency) / _ScanFrequencyBis) * _GreenPower) * 1.5;
				color.b *= (0.5 + abs(0.5 - fmod(uv2.y + 0.014, _ScanFrequency) / _ScanFrequencyBis) * _BluePower) * 1.5;

				// Color correction
				color *= 0.9 + rain * 0.35;
				color *= sqrt(1.5 - 0.5*length(uv));

				color *= tex;
				return fixed4(color, 1);
			}
			ENDCG
		}
	}
}
