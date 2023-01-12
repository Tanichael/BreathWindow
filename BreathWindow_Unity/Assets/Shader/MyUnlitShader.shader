Shader "Unlit/MyUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
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
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            //uvがとあるTexture内にあるかどうか調べる関数
            int isInTexture(sampler2D tex, float2 uv)
            {
                return 1;
            }

            float calcWeight(float r, int dist)
            {
                float weight = 1;
                int row = (2 * r + 1);
                return weight / (row * row);
            }
            
            // テクスチャからサンプリングしてRGBのみ返す
            half3 sampleMain(sampler2D tex, float2 uv){
                return tex2D(tex, uv).rgb;
            }

            // 対角線上の4点からサンプリングした色の平均値を返す
            half3 sampleBox (sampler2D tex, float4 texelSize, float2 uv, float delta) {
                // half3 ncol = half3(0, 0, 0);
                // //色合成処理
                // for(int dx = -delta; dx <= delta; dx++)
                // {
                //     for(int dy = -delta; dy <= delta; dy++)
                //     {
                //         float2 tp = float2(uv.x + dx, uv.y + dy);
                //         int td = abs(dx) + abs(dy);
                //         float weight = calcWeight(delta, td);
                //         if (isInTexture(tex, tp))
                //         {
                //             half3 tcol = sampleMain(tex, tp);
                //             ncol.r += weight * tcol.r;
                //             ncol.g += weight * tcol.g;
                //             ncol.b += weight * tcol.b;
                //         }
                //     }
                // }
                //
                // return ncol;
                // float4 offset = texelSize.xyxy * float2(-delta, delta).xxyy;
                // half3 sum = sampleMain(tex, uv + offset.xy) + sampleMain(tex, uv + offset.zy) + sampleMain(tex, uv + offset.xw) + sampleMain(tex, uv + offset.zw);
                // return sum * 0.25;

                return sampleMain(tex, uv);
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = ComputeGrabScreenPos(o.vertex);
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            sampler2D _CameraOpaqueTexture;
            float4 _CameraOpaqueTexture_TexelSize;

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                half4 col = 1;
                col.rgb = sampleBox(_CameraOpaqueTexture, _CameraOpaqueTexture_TexelSize, i.uv, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
