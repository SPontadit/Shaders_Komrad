// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/GlowSprite"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		
		[Header(Outline)]
		_OutlineMask("Outline mask", 2D) = "white" {}
		_InnerColor("Inner Color", Color) = (0, 0, 0, 0)
		_OuterColor ("Outer Color 2", Color) = (0, 0, 0, 0)
		_OutlinePulseSpeed ("Outline Pulse Speed", Range(0, 10)) = 0
		_UVMul("UVMul", float) = 1.0
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
			sampler2D _AlphaTex;

			sampler2D _OutlineMask;
			float _OutlineWidth;
			float _OutlineBrightness;
			float _OutlinePulseSpeed;
			float4 _InnerColor;
			float4 _OuterColor;
			float _UVMul;

			fixed4 SampleSpriteTexture(float2 uv)
			{
				fixed4 color = tex2D(_MainTex, uv);

				return color;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				float2 realTexCoord = (IN.texcoord * 2.0f - float2(1.0, 1.0)) * _UVMul;
				realTexCoord = realTexCoord * 0.5 + float2(0.5, 0.5);
				
				fixed4 c = SampleSpriteTexture(realTexCoord) * IN.color;
				c.rgb *= c.a;
				 

				float mask = tex2D(_OutlineMask, realTexCoord).r;
				mask *= cos(_Time.y * _OutlinePulseSpeed) * 0.5 + 0.5;
				
				float4 lerpOutlineColor = lerp(_OuterColor, _InnerColor, mask);

				float4 outlineColor = mask * lerpOutlineColor;

				c.rgb += outlineColor.rgb;;

				return c;
			}
		ENDCG
		}
	}
}