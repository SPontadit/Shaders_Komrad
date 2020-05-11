Shader "Custom/ThresholdSprite"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

		_MaskTex("Sprite Mask", 2D) = "white" {}
		_Alpha("Alpha", Range(0, 1)) = 1

		_ThresholdColorBegin("Threshold Color Begin", Color) = (1, 1, 1, 1)
		_ThresholdColorEnd("Threshold Color End", Color) = (1, 1, 1, 1)
		_Width("Width", Range(0, 1)) = 0.05
		_Period("Period", Float) = 3
		_Pause("Pause", Float) = 2
		_Intensity("-", Float) = 1
		_BaseTime("-", Float) = 0
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

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
				float4 color    : COLOR;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
				float4 vertex : SV_POSITION;
			};


			fixed4 _Color;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.color = v.color * _Color;
				
				return o;
			}

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _ThresholdColorBegin;
			float4 _ThresholdColorEnd;

			sampler2D _MaskTex;
			float _Alpha;

			float _DebugThreshold;
			float _Width;
			float _Period;
			float _Pause;
			float _Intensity;
			float _BaseTime;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed mask = tex2D(_MaskTex, i.uv).r;

				float total = _Period + _Pause;
				float periodPercent = (_BaseTime % _Period) / _Period;

				float threshold = lerp(0.0, 1.0, periodPercent);
				saturate(threshold);

				float lowLevel = saturate(threshold - _Width);
				float hightLevel = saturate(threshold + _Width);

				fixed power = step(lowLevel, mask) * step(mask, hightLevel);
				
				float4 lerpThresholdColor = lerp(_ThresholdColorBegin, _ThresholdColorEnd, mask);

				col.rgb += (power * lerpThresholdColor * mask) * _Alpha * _Intensity;

				return col;
			}
			ENDCG
		}
	}
}
