Shader "Custom/Triplanar_FixedRotation"
{
    Properties
    {
        _MainTex("Base Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _Tiling("Tiling", Float) = 1.0
        _NormalStrength("Normal Map Strength", Range(0, 1)) = 1.0
    }

        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            Pass
            {
                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                struct Attributes
                {
                    float4 positionOS : POSITION; // Posición en espacio del objeto
                    float3 normalOS : NORMAL;     // Normal en espacio del objeto
                };

                struct Varyings
                {
                    float4 positionHCS : SV_POSITION;
                    float3 worldPos : TEXCOORD0;    // Posición en espacio mundial
                    float3 worldNormal : TEXCOORD1; // Normal en espacio mundial
                };

                sampler2D _MainTex;
                sampler2D _NormalMap;
                float _Tiling;
                float _NormalStrength;

                Varyings vert(Attributes IN)
                {
                    Varyings OUT;
                    OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                    OUT.worldPos = TransformObjectToWorld(IN.positionOS.xyz); // Transformamos la posición a espacio mundial
                    OUT.worldNormal = normalize(TransformObjectToWorldNormal(IN.normalOS)); // Usamos normales en espacio mundial
                    return OUT;
                }

                float3 GetTriplanarBlend(float3 normal)
                {
                    normal = abs(normal);
                    float3 blendWeights = normal * normal; // Blending suave usando normales al cuadrado
                    blendWeights /= (blendWeights.x + blendWeights.y + blendWeights.z + 0.0001); // Evitamos divisiones por cero
                    return saturate(blendWeights); // Nos aseguramos que no exceda el valor de 1
                }

                float3 GetTriplanarTexture(sampler2D tex, float3 worldPos, float3 blendWeights, float tiling)
                {
                    float2 uvX = worldPos.yz * tiling;
                    float2 uvY = worldPos.xz * tiling;
                    float2 uvZ = worldPos.xy * tiling;

                    float3 texX = tex2D(tex, uvX).rgb * blendWeights.x;
                    float3 texY = tex2D(tex, uvY).rgb * blendWeights.y;
                    float3 texZ = tex2D(tex, uvZ).rgb * blendWeights.z;

                    return texX + texY + texZ;
                }

                float3 GetTriplanarNormal(sampler2D normalMap, float3 worldPos, float3 blendWeights, float tiling, float normalStrength)
                {
                    float2 uvX = worldPos.yz * tiling;
                    float2 uvY = worldPos.xz * tiling;
                    float2 uvZ = worldPos.xy * tiling;

                    float3 normalX = UnpackNormal(tex2D(normalMap, uvX)) * blendWeights.x;
                    float3 normalY = UnpackNormal(tex2D(normalMap, uvY)) * blendWeights.y;
                    float3 normalZ = UnpackNormal(tex2D(normalMap, uvZ)) * blendWeights.z;

                    float3 blendedNormal = normalize(normalX + normalY + normalZ);
                    return lerp(float3(0, 0, 1), blendedNormal, normalStrength);
                }

                half4 frag(Varyings IN) : SV_Target
                {
                    float3 blendWeights = GetTriplanarBlend(IN.worldNormal); // Calculamos el blending usando las normales en espacio mundial

                    float3 albedo = GetTriplanarTexture(_MainTex, IN.worldPos, blendWeights, _Tiling);
                    float3 normal = GetTriplanarNormal(_NormalMap, IN.worldPos, blendWeights, _Tiling, _NormalStrength);

                    return float4(albedo, 1.0); // Mantener alfa en 1 para evitar transparencia
                }
                ENDHLSL
            }
        }

            FallBack "Standard"
}