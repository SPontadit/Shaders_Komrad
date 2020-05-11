Shader "Custom/Neon" {
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_MaskTex("Mask (A)", 2D) = "white" {}
	}
		SubShader{
			Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}
		LOD 200

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
			Pass
	{
		CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag


#include "UnityCG.cginc"

	sampler2D _MainTex;
	sampler2D _MaskTex;
	
	uniform float4 _Color;
	uniform float _Intensity;

	float4 frag(v2f_img i) : COLOR
	{
		float4 c = float4(_Color.r + _Intensity, _Color.g + _Intensity, _Color.b + _Intensity, 0);
		float4 mask = tex2D(_MaskTex, i.uv) * c;
		float4 color = tex2D(_MainTex, i.uv);
	
		float4 r = mask + color;
		r.rgb *= color.a;
		return r;
	}
		ENDCG
	}
	}
}
