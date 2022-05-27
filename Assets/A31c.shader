Shader "ClassShaders/Activity A.3.1" {
    SubShader {

        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            struct vertexInput {

                float4 vertexPos : POSITION;
                float3 normal : NORMAL;
            };

            // vertex shader modifies the position of the vertices in space 
            float4 vert(vertexInput input) : SV_POSITION {

                // how to modify the vertices through time
                // through external variables
                // https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html


                // 2 different spaces 
                // 1 is local which is the one we receive
                // float 4 - x,y,z,w OR r,g,b,a
                // in this 3rd one we need to move the vertices in a certain direction
                // to achieve the effect we need to move:
                // - expand: outwards
                // - shrink: inwards

                // HOW TO ACHIEVE IT 
                // 2 choices:
                // 1 - multiply the value of the vector times something
                // 2 - add position + normal * displacement

                // float4 local = vertexPos * cos(_Time.y);

                float4 local = input.vertexPos + float4(input.normal  * cos(_Time.y), 0);
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
