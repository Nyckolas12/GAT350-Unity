Shader "Unlit/CustomShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D ) = "white" {}
        _DissolveThreshold ("Dissolve Threshold", Range(0, 1)) = 0.5
        _EdgeColor ("Edge Color", Color) = (1,1,1,1)
        _EdgeWidth ("Edge Width", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

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

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float4 _NoiseTex_ST;
            float _DissolveThreshold;
            fixed4 _EdgeColor;
            float _EdgeWidth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                //Noise texture
                float noise = tex2D(_NoiseTex, i.uv).r;

                //calculate the dissolve Threshold
                float dissolve = smoothstep(_DissolveThreshold - _EdgeWidth, _DissolveThreshold, noise);

                // Blend the edge color near the dissolve threshold
                fixed4 edgeCol = lerp(_EdgeColor, col, dissolve);

                // Output color based on dissolve
                col.rgb = lerp(edgeCol.rgb, col.rgb, dissolve);
                col.a *= dissolve; // Fade the alpha
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
                /*
                The main point in trying to make this Dissolve shader is to try and create an object dissapearing out of thin air
                I wanted to attepemt to make those cool Dissolve effects like seen in moives
                */

                /*
                All websites used for help
                https://xibanya.github.io/ShaderTutorials/tutorial/Part12Dissolve.html
                https://github.com/Xibanya/ShaderTutorials/blob/master/Assets/Shaders/Toon/XibDissolve.shader
                https://github.com/robertrumney/dissolve-shader/blob/main/DissolveMesh.cs
                https://www.youtube.com/watch?v=U60U9KC7jxk&t=1s
                https://www.youtube.com/watch?time_continue=73&v=taMp1g1pBeE&embeds_referring_euri=https%3A%2F%2Fwww.bing.com%2F&embeds_referring_origin=https%3A%2F%2Fwww.bing.com&source_ve_path=MjM4NTE
                */

                
            }
            ENDCG
        }
    }
}
