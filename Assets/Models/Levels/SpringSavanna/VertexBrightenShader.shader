Shader "Unlit/VertexBrightenShader"
{
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_LightingTreshold ("Lighting Treshold", Range(0.01,1.0)) = 0.500
		_LightingIntensity ("Lighting Intensity", Range(0.00,1.0)) = 0.250
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
				half4 color : COLOR0;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				half4 color : COLOR0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.color = v.color;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			float _LightingTreshold;
			float _LightingIntensity;
			
			float4 frag(v2f IN) : COLOR
			{
				float sub = _LightingTreshold;
				float mult = 1.0/_LightingTreshold;
				float3 col = IN.color.rgb;
				float4 col_add = float4(max(0.0, (col.r - sub)*mult), max(0.0, (col.g - sub)*mult), max(0.0, (col.b - sub)*mult), 0.0)*_LightingIntensity;
				float4 col_mul = float4(min(1.0, col.r*mult), min(1.0, col.g*mult), min(1.0, col.b*mult), 1.0);
				float4 c = tex2D (_MainTex, IN.uv)*col_mul + col_add;
				return c;
			}
			ENDCG
		}
	}
}
