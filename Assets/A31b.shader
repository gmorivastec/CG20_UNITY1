Shader "ClassShaders/Activity A.3.1" {
    SubShader {

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            // vertex shader modifies the position of the vertices in space 
            float4 vert(float4 vertexPos : POSITION) : SV_POSITION {

                // how to modify the vertices through time
                // through external variables
                // https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html


                // 2 different spaces 
                // 1 is local which is the one we receive
                // float 4 - x,y,z,w OR r,g,b,a
                float4 local = float4(vertexPos.x, vertexPos.y + (cos(_Time.y + vertexPos.z) * 5), vertexPos.z, vertexPos.w);
                float4 clip = UnityObjectToClipPos(local); 
                // 2nd is the one that we return
                return clip; 
                //return float4(clip.x + _Time.y, clip.y, clip.z, clip.w);
            } 

            float4 frag() : COLOR {

                return float4(0.0, 0.0, 1.0, 1.0);
            }
            ENDCG
        }
    }
}
