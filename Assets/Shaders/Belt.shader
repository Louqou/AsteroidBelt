Shader "Custom/Belt" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DensityMap ("Density Map", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_MinimumRenderDistance ("Minimum Render Distance", Float) = 10
		_MaximumFadeDistance ("Maximum Fade Distance", Float) = 20
		_InnerRingDiameter ("Inner Ring Diameter", Range(0, 1)) = 0.5
		_LightWidth ("Planet Size", Range(0, 1)) = 0.5
		_LightScale ("Light Scale", Float) = 5
	}
	SubShader {
		Tags { "RenderType"="Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent"}
		LOD 200
		CULL OFF
		CGPROGRAM

		#pragma surface surf StandardDefaultGI fullforwardshadows alpha:fade

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "UnityPBSLighting.cginc"	
		inline half4 LightingStandardDefaultGI(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
        {
			half4 lighting = LightingStandard(s, viewDir, gi);
			lighting.rgb *= s.Occlusion;
			return lighting;
        }
    
        inline void LightingStandardDefaultGI_GI(
                SurfaceOutputStandard s,
                UnityGIInput data,
                inout UnityGI gi)
        {
			LightingStandard_GI(s, data, gi);
        }

		sampler2D _MainTex;
		sampler2D _DensityMap;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _MaximumFadeDistance;
		float _MinimumRenderDistance;
		half _InnerRingDiameter;
		half _LightWidth;
		float _LightScale;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			half distance = length(IN.worldPos - _WorldSpaceCameraPos);
			clip(distance - _MinimumRenderDistance);
			half2 position = half2((IN.uv_MainTex.x - 0.5) * 2, (IN.uv_MainTex.y - 0.5) * 2);
			half fromCenter = length(position);

			clip(fromCenter - _InnerRingDiameter);
			clip(1 - fromCenter);

			fixed4 density = tex2D(_DensityMap, float2(fromCenter, 0.5));

			o.Albedo = density;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = clamp((distance - _MinimumRenderDistance) / (_MaximumFadeDistance - _MinimumRenderDistance), 0, 1) * density;


			float3 lightToPoint = normalize(_WorldSpaceLightPos0.xyz - IN.worldPos);

			//Planet is at 0, 0, 0
			float3 lightToObject = normalize(_WorldSpaceLightPos0.xyz);
			o.Occlusion = clamp((-dot(lightToPoint, lightToObject) + _LightWidth) * _LightScale, 0, 1);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
