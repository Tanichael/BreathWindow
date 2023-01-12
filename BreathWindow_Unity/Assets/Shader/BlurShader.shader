Shader "Unlit/BlurShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OriginTex ("Original Texture", 2D) = "white" {}
        _BlurRad("Blur Range", int) = 5
        _FrostRad ("Frost Size", int) = 0
        _DrawRad ("Draw Size", int) = 0
        _FrostUV ("Frost Position", VECTOR) = (0, 0, 0, 0)
        _DrawUV ("Draw Position", VECTOR) = (0, 0, 0, 0)
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

            int isInRange(float4 hitUv, float4 texelSize, float rad, float4 uv)
            {
                if(hitUv.x - rad * texelSize.x < uv.x && uv.x < hitUv.x + rad * texelSize.x && hitUv.y - rad * texelSize.y < uv.y && uv.y < hitUv.y + rad * texelSize.y)
                {
                    return 1;
                } else
                {
                    return 0;
                }
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

            // あるTextureのあるuvについてdelta * deltaの正方形の色を平均化して返す
            half3 sampleBox (sampler2D tex, float4 texelSize, float2 uv, int delta) {
                half3 ncol = half3(0, 0, 0);
                //色合成処理
                for(int dx = -delta; dx <= delta; dx++)
                {
                    for(int dy = -delta; dy <= delta; dy++)
                    {
                        float2 tp = float2(uv.x + dx * texelSize.x, uv.y + dy * texelSize.y);
                        int td = abs(dx) + abs(dy);
                        float weight = calcWeight(delta, td);
                        if (isInTexture(tex, tp))
                        {
                            half3 tcol = sampleMain(tex, tp);
                            ncol.r += weight * tcol.r;
                            ncol.g += weight * tcol.g;
                            ncol.b += weight * tcol.b;
                        }
                    }
                }
                
                return ncol;
            }

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            sampler2D _OriginTex;
            float4 _OriginTex_TexelSize;
            int _BlurRad;
            int _FrostRad;
            int _DrawRad;
            float4 _FrostUV;
            float4 _DrawUV;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                if(isInRange(_FrostUV, _MainTex_TexelSize, _FrostRad, i.uv))
                {
                    half4 col = 1;
                    col.rgb = sampleBox(_OriginTex, _OriginTex_TexelSize, i.uv, 7);
                    col.rgb = (col.rgb + float3(0.25, 0.25, 0.25));
                    return col;
                }
                
                if(isInRange(_DrawUV, _MainTex_TexelSize, _DrawRad, i.uv))
                {
                    return tex2D(_OriginTex, i.uv);
                }

                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
