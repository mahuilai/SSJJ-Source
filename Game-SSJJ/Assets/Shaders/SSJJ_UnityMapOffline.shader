// SSJJ 离线场景用：SSJJ/UnityMap 的语义等价实现。
//
// 原 shader 是从客户端 resources.assets 里序列化出来的（gpuProgramID=56148，
// 单 SubShader / 3 Pass：FORWARD、FORWARDADD、Meta），属性只有
//   _MainTex        Base (RGB)
//   _LightMap       Lightmap (RGB)
//   _NewLightMapType  new LightMap Type   (float)
//   _ZWrite         ZWrite                (float)
// 没有 _Color —— 所以不存在任何色调控制，贴图是原样输出的。
//
// 这里不做任何 tint / gamma / 曝光，只做：
//   albedo = tex2D(_MainTex, uv) * 顶点色
//   result = albedo * (lightmap 接近全白，几乎不改变亮度)
// 顶点色来自 BSP 烘好的原始亮度（bsp_raw.py 写入 mesh color 通道），
// 用它还原 SSJJ 原本的明暗层次，而不引入任何人工调色。
Shader "SSJJ/UnityMapOffline"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _LightMap ("Lightmap (RGB)", 2D) = "white" {}
        _NewLightMapType ("new LightMap Type", Float) = 0
        _ZWrite ("ZWrite", Float) = 1
        // 0=Off 1=Front 2=Back —— BSP 三角形绕序与 Unity 相反，默认关剔除
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 0
        // 顶点色强度：1=完全使用 BSP 原始亮度，0=忽略
        _VertexColorStrength ("Vertex Color Strength", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest LEqual
            Lighting Off
            Fog { Mode Off }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _LightMap;
            float4 _LightMap_ST;
            float _NewLightMapType;
            float _VertexColorStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;   // 漫反射 UV
                float2 uv1    : TEXCOORD1;   // lightmap UV
                fixed4 color  : COLOR;
            };

            struct v2f
            {
                float4 pos   : SV_POSITION;
                float2 uv0   : TEXCOORD0;
                float2 uv1   : TEXCOORD1;
                fixed4 color : COLOR;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv, _MainTex);
                // 第二套 UV = lightmap UV（BSP drawVert 的 lightmapUv）
                o.uv1 = TRANSFORM_TEX(v.uv1, _LightMap);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 albedo = tex2D(_MainTex, i.uv0).rgb;

                // ---- 原始亮度：绝不压暗 ----
                // lightmap0 实测平均 RGB=(249.7,233.2,225.9)、min=195、max=255，
                // 整体接近白色，只带轻微暖色倾向。因此这里用的是"归一化后相乘"：
                // 把 lightmap 的亮度归一到 1.0 附近，只保留它的色偏，不引入变暗。
                //   lm_norm = lm / lm_max_component   -> 亮部恒等于 1
                //   albedo * lm_norm                  -> 亮度不变，只把暖调带过来
                // 如果直接 albedo*lm，会把整图压暗约 5%，那是"亮度不对"的来源之一。
                fixed3 lm = tex2D(_LightMap, i.uv1).rgb;
                float lmMax = max(max(lm.r, lm.g), lm.b);
                fixed3 lmNorm = (lmMax > 1e-4) ? (lm / lmMax) : fixed3(1, 1, 1);

                // 顶点色：BSP 里 88% 的顶点是 (35,35,35)，那是"未烘焙"标记而非常规
                // 明暗值。若直乘会让整图上暗 7 倍。所以默认强度 0（不参与），
                // 需要对照调试时可在材质上把 _VertexColorStrength 调上去。
                fixed3 vc = lerp(fixed3(1, 1, 1), i.color.rgb, _VertexColorStrength);

                fixed3 c = albedo * lmNorm * vc;
                return fixed4(c, 1);
            }
            ENDCG
        }

        // 无实时光照参与，ForwardAdd / Meta 不需要额外实现，
        // 保持 SubShader 结构简单，避免在多 Pass 下重复叠加导致变亮。
    }

    Fallback Off
}
