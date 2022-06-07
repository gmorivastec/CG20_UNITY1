// shader lab code specific to unity
Shader "ClassShaders/Toon Shader with Border" {

    // you can add parameters that can be modified through the editor
    Properties {
        _AmbientMaterial("Ambient Color", Color) = (1, 1, 1, 1)
        _DiffuseMaterial("Diffuse Color", Color) = (1, 1, 1, 1)
        _SpecularMaterial("Specular Material", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Float) = 100
        _FirstCut("First Cut", Float) = 0.33
        _SecondCut("Second Cut", Float) = 0.66
        _Tex("The texture", 2D) = "white" {}
        _Width("outline width", Float) = 0.03
    }

    SubShader { // you can have different subshaders so unity decides which one to use

        Stencil {

            Ref 1
            Comp Always
            Pass Replace
        }

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
            uniform float _FirstCut;
            uniform float _SecondCut;
            uniform sampler2D _Tex;

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

                // calculating R
                // R represents the perfect reflection of the light
                // when hitting this point
                float3 r = reflect(-lm, n);

                // calculating V
                // V is a vector that goes from the current point
                // to the camera
                // WE NEED:
                // 1. get the point in world space
                
                // 2. get the position of camera
                float3 camera = _WorldSpaceCameraPos;

                // 3. get the vector that points from the vertex to the camera
                

                float4 specular = float4(0, 0, 0, 0);

                // return float4(0.0, 1.0, 0.0, 1.0);
                float4 result = ambient + diffuse + specular;

                // grayscale
                // commonly used to determine amount of "light" in a point
                // (how dark or light is)

                // grayscale means same amount of r, g and b
                float average = (result.r + result.g + result.b) / 3;

                float4 textureColor = tex2D(_Tex, input.coord.xy);
                if(average <= _FirstCut)
                    return _AmbientMaterial * textureColor * 0.4;

                if(average <= _SecondCut)
                    return _AmbientMaterial * textureColor * 0.5;

                return _AmbientMaterial * textureColor;
            }

            ENDCG
        }

        Pass {

            Cull off

            Stencil {

                Ref 1
                Comp NotEqual
                Pass Keep
            }

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            uniform float _Width;

            float4 vert(float4 vertex : POSITION, float3 normal : NORMAL) : SV_POSITION {
                
                // return a slightly larger model than original
                return UnityObjectToClipPos(vertex + normal * _Width);
            }

            float4 frag() : COLOR {
                return float4(0, 0, 0, 1);
            }


            ENDCG
        }
    }
}