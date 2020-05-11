// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/GlowOnly"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}

		[Header(Outline)]
		_InnerColor("Inner Color", Color) = (0, 0, 0, 0)
		_OuterColor("Outer Color 2", Color) = (0, 0, 0, 0)
		_OutlinePulseSpeed("Outline Pulse Speed", Range(0, 10)) = 0
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

			Pass
			{
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex   : POSITION;
					float4 color    : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 vertex   : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord  : TEXCOORD0;
				};

				fixed4 _Color;

				v2f vert(appdata_t IN)
				{
					v2f OUT;
					OUT.vertex = UnityObjectToClipPos(IN.vertex);
					OUT.texcoord = IN.texcoord;
					OUT.color = IN.color * _Color;

					return OUT;
				}

				sampler2D _MainTex;
				float _OutlineWidth;
				float _OutlineBrightness;
				float _OutlinePulseSpeed;
				float4 _InnerColor;
				float4 _OuterColor;


				fixed4 frag(v2f IN) : SV_Target
				{
					float mask = tex2D(_MainTex, IN.texcoord).r;
					mask *= cos(_Time.y * _OutlinePulseSpeed) * 0.5 + 0.5;

					float4 lerpOutlineColor = lerp(_OuterColor, _InnerColor, mask);

					float4 outlineColor = mask * lerpOutlineColor;
					
					return outlineColor;

				}
			ENDCG
			}
		}
}