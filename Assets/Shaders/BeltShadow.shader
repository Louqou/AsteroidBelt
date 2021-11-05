Shader "Custom/BeltShadow" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DensityMap ("Density Map", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_InnerRingDiameter ("Inner Ring Diameter", Range(0, 1)) = 0.5
		_Cutoff ("Cutoff", Range(0, 1)) = 0.5
	}
	SubShader {
		Tags { "RenderType"="TransparentCutout" "IgnoreProjector" = "True" "Queue" = "AlphaTest"}
		LOD 200
		CULL OFF
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard alphatest:_Cutoff addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _DensityMap;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		half _InnerRingDiameter;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			half distance = length(IN.worldPos - _WorldSpaceCameraPos);
			half2 position = half2((IN.uv_MainTex.x - 0.5) * 2, (IN.uv_MainTex.y - 0.5) * 2);
			half fromCenter = length(position);

			clip(fromCenter - _InnerRingDiameter);
			clip(1 - fromCenter);

			fixed4 density = tex2D(_DensityMap, float2(fromCenter, 0.5));

			o.Albedo = fixed3(position.x, position.y, density.r);
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = density.r;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
