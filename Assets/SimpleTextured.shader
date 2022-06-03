// shader lab code specific to unity
Shader "ClassShaders/Simple Textured" {

    // you can add parameters that can be modified through the editor
    Properties {
        _AmbientMaterial("Ambient Color", Color) = (1, 1, 1, 1)
        _DiffuseMaterial("Diffuse Color", Color) = (1, 1, 1, 1)
        _SpecularMaterial("Specular Material", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Float) = 100
        _Tex("The texture", 2D) = "white" {}
        _NormalMap("Normal map", 2D) = "white" {}
        
    }

    SubShader { // you can have different subshaders so unity decides which one to use

        Pass {
            // a single shader can have several passes 
            // a pass - process of vertex / fragment shader 

            // NOW WE START WITH THE ACTUAL SHADER CODE
            // WE ARE GOING TO BE USING CG
            CGPROGRAM
            
            // setting up the name of our vertex and fragment shader
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            uniform float4 _AmbientMaterial;
            uniform float4 _DiffuseMaterial;
            uniform float4 _SpecularMaterial;
            uniform float _Shininess;
            uniform float4 _LightColor0;
            uniform sampler2D _Tex;
            uniform sampler2D _NormalMap;

            // to send / receive several values in the shader 
            // we need structs 

            struct vertexInput {

                float4 vertexPos : POSITION;
                float3 normal : NORMAL;
                float4 coord : TEXCOORD0;
            };

            struct vertexOutput {
                
                float4 position : SV_POSITION;
                float3 normal : NORMAL;
                float4 vertex : TEXCOORD1;
                float4 coord : TEXCOORD0;
            };

            // declare the vertex shader
            // float4 - vector size 4 of floats
            // TYPE - define the kind of information we are using
            // SEMANTICS - define the use of the information
            vertexOutput vert(vertexInput input) {
                
                // receive original position of vertex
                // transform to consider world space
                // return modified position

                vertexOutput result;
                result.position = UnityObjectToClipPos(input.vertexPos);
                // normal is a vector pointing "outwards"
                result.normal = input.normal; 
                result.vertex = input.vertexPos;
                result.coord = input.coord;

                return result;
            }

            float4 frag(vertexOutput input) : COLOR {

                float3 mappedNormal = tex2D(_NormalMap, input.coord.xy).xyz;

                // how to retrieve value from texture 
                // input is a 2D UV coordinate
                // output is a float4 color
                
                // return tex2D(_Tex, input.coord.xy);

                
                // PHONGS REFLECTION MODEL
                // ka - material for ambient lighting
                // ia - light for ambient lighting 
                
                // color = ka*i + kd * i * (L . N)
                // rgba
                // xyzw
                
                float i = _LightColor0;

                // AMBIENT LIGHTING
                float4 ambient = _AmbientMaterial * i * 0.25;

                // DIFFUSE LIGHTING
                // kd * i * (L . N)
                
                // VERY CONFUSING THING TO KEEP IN MIND ALWAYS WHEN 
                // WORKING ON SHADERS:
                // VERIFY THE SPACE OF YOUR VECTORS (LOCAL VS WORLD)

                // N - normal vector for this point
                float3 n = UnityObjectToWorldNormal(input.normal);

                // L - vector that points to light 
                float3 lm = normalize(_WorldSpaceLightPos0.xyz);

                // dot product of two vectors
                // A . B = |A||B|cosO

                float4 diffuse = _DiffuseMaterial * i * max(0.0, dot(lm, n));

                // SPECULAR LIGHTING

                // ks * i * (R . V)a
                float4 ks = _SpecularMaterial;
                float a = _Shininess;

                // calculating R
                // R represents the perfect reflection of the light
                // when hitting this point
                float3 r = reflect(-lm, n);

                // calculating V
                // V is a vector that goes from the current point
                // to the camera
                // WE NEED:
                // 1. get the point in world space
                float3 vertexGlobal = mul(unity_ObjectToWorld, input.vertex).xyz;
                
                // 2. get the position of camera
                float3 camera = _WorldSpaceCameraPos;

                // 3. get the vector that points from the vertex to the camera
                float3 v = normalize(camera - vertexGlobal);

                float4 specular = ks * i * pow(max(0.0, dot(r, v)), a);

                float4 phong = ambient + diffuse + specular; 
                float4 tex = tex2D(_Tex, input.coord.xy);

                // return float4(0.0, 1.0, 0.0, 1.0);
                return phong * tex;      
                
            }

            ENDCG
        }
    }
}