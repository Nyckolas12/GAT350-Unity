Shader "Unlit/UnlitMulitTexture"
{
    Properties
    {
        _MainTex1 ("Texture", 2D) = "white" {}
        _MainTex2 ("Texture", 2D) = "white" {}
        _Tint ("Tint", Color) = (1, 1, 1, 1)
        _Intensity("Intensity", Range(0, 1)) = 1
        _Scroll("Scroll", Vector) = (0,0,0,0)
        _Blend("Blend", Range(0,1)) = 0.5
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
                float2 uv : TEXCOORD0;
            };
 
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };
 
            sampler2D _MainTex1;
            sampler2D _MainTex2;
            float4 _MainTex_ST;
            float4 _MainTex2_ST;
 
            fixed4 _Color;
            fixed4 _Tint;
            float _Intensity;
            float4 _Scroll;
            float _Blend
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex1);
                o.uv.x = o.uv.x + (_Time.y * _Scroll.x);
                o.uv.y = o.uv.y + (_Time.y * _Scroll.y);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex1, i.uv);
                fixed4 col2 = tex2D(_MainTex2, i.uv);
                fixed4 col = lerp(col, col2, _Blend)
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
