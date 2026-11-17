// SSJJ 离线场景天空盒：对应客户端内建的 SSJJ/Skybox
// （单 SubShader 单 Pass，属性只有 _MainTex，Cull Back，ZWrite Off）。
// 原 shader 同样是序列化产物，这里给出语义等价实现。
// 天空面由 6 个朝向内侧的 Quad 组成，贴图直接采样，不做任何调色。
Shader "SSJJ/SkyboxOffline"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        // 面朝向内侧，Cull Back 正好剔除背面；若朝向反了可改成 0 (Off)
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 2
        _Exposure ("Exposure", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Background" }

        Pass
        {
            Cull [_Cull]
            ZWrite Off
            ZTest LEqual
            Lighting Off
            Fog { Mode Off }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Exposure;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 c = tex2D(_MainTex, i.uv).rgb * _Exposure;
                return fixed4(c, 1);
            }
            ENDCG
        }
    }

    Fallback Off
}
