Shader "Custom/TriplanarWithNormals"
{
    Properties
    {
        _UpDownTex("Top and Bottom Texture", 2D) = "white" {}
        _SideTex("Side Texture", 2D) = "white" {}
        _UpDownNormal("Top and Bottom Normal Map", 2D) = "bump" {}
        _SideNormal("Side Normal Map", 2D) = "bump" {}
        _TextureScale("Texture Scale", Float) = 1.0
    }

        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200

            CGPROGRAM
            #pragma surface surf Standard fullforwardshadows
            #include "UnityCG.cginc"

            sampler2D _UpDownTex;
            sampler2D _SideTex;
            sampler2D _UpDownNormal;
            sampler2D _SideNormal;
            float _TextureScale;

            struct Input
            {
                float3 worldPos;
                float3 worldNormal;
                INTERNAL_DATA // Necesario para usar worldNormal correctamente
            };

            // Función para obtener las coordenadas de textura en un eje específico
            float2 GetTriplanarUV(float3 worldPos, float scale, int axis)
            {
                if (axis == 0) return worldPos.yz * scale; // Proyección en X
                if (axis == 1) return worldPos.xz * scale; // Proyección en Y
                return worldPos.xy * scale;                // Proyección en Z
            }

            // Función principal del shader
            void surf(Input IN, inout SurfaceOutputStandard o)
            {
                float3 worldNormal = normalize(WorldNormalVector(IN, float3(0,0,1))); // Usa WorldNormalVector con INTERNAL_DATA
                float3 absWorldNormal = abs(worldNormal);

                // Calculamos el blend para las texturas según las normales del mundo
                float3 blend = absWorldNormal / (absWorldNormal.x + absWorldNormal.y + absWorldNormal.z);

                // Obtener UVs para cada proyección
                float2 uvX = GetTriplanarUV(IN.worldPos, _TextureScale, 0);
                float2 uvY = GetTriplanarUV(IN.worldPos, _TextureScale, 1);
                float2 uvZ = GetTriplanarUV(IN.worldPos, _TextureScale, 2);

                // Muestras de color para cada eje
                float4 colorTopBottom = tex2D(_UpDownTex, uvY);
                float4 colorSideX = tex2D(_SideTex, uvX);
                float4 colorSideZ = tex2D(_SideTex, uvZ);

                // Muestras de normales para cada eje
                float3 normalTopBottom = UnpackNormal(tex2D(_UpDownNormal, uvY));
                float3 normalSideX = UnpackNormal(tex2D(_SideNormal, uvX));
                float3 normalSideZ = UnpackNormal(tex2D(_SideNormal, uvZ));

                // Mezclamos los colores según el blend
                o.Albedo = blend.x * colorSideX.rgb + blend.y * colorTopBottom.rgb + blend.z * colorSideZ.rgb;

                // Mezclamos los mapas de normales
                o.Normal = normalize(blend.x * normalSideX + blend.y * normalTopBottom + blend.z * normalSideZ);
            }

            ENDCG
        }

            FallBack "Diffuse"
}