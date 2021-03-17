//Input date from vertex shader
varying lowp vec4 frag_Color;
varying lowp vec2 frag_TexCoord;
varying lowp vec3 frag_Normal;
varying lowp vec3 frag_Position;

uniform sampler2D u_Texture;
uniform highp float u_MatSpecularIntensity;
uniform highp float u_Shininess;

struct Light
{
    lowp vec3 Color;
    lowp float AmbientIntensity;
    lowp float DiffuseIntensity;
    lowp vec3 Direction;
};

struct Fog
{
    highp float FogDensity;
    highp float FogDistance;
    lowp vec4 FogColor;
    bool FogIsActive;
};

uniform Light u_Light;
uniform Fog u_Fog;

void main(void)
{
    //Ambient
    lowp vec3 AmbientColor = u_Light.Color * u_Light.AmbientIntensity;
    
    //Diffuse
    lowp vec3 Normal = normalize(frag_Normal);
    lowp float DiffuseFactor = max(-dot(Normal, u_Light.Direction), 0.0);
    lowp vec3 DiffuseColor = u_Light.Color * u_Light.DiffuseIntensity * DiffuseFactor;
    
    //Specular
    lowp vec3 Eye = normalize(frag_Position);
    lowp vec3 Reflection = reflect(u_Light.Direction, Normal);
    lowp float SpecularFactor = pow(max(0.0, -dot(Reflection, Eye)), u_Shininess);
    highp vec3 SpecularColor = u_Light.Color * u_MatSpecularIntensity * SpecularFactor;
    
    //Apply lighting and texture
    //gl_FragColor = texture2D(u_Texture, frag_TexCoord) * vec4((AmbientColor + DiffuseColor + SpecularColor), 1.0);

    
    
    highp float perspective_far = 20.0;
    highp float fog_coord = (gl_FragCoord.z / gl_FragCoord.w) / u_Fog.FogDistance;
    highp float fog_density = 6.0;
    highp float fog = fog_coord * u_Fog.FogDensity;
    highp vec4 fog_color = vec4(1,1,1,1);
    highp vec4 noFog = texture2D(u_Texture, frag_TexCoord) * vec4((AmbientColor + DiffuseColor + SpecularColor), 1.0);
    
    
    if(u_Fog.FogIsActive)
    {
        gl_FragColor = mix(u_Fog.FogColor, noFog, clamp(1.0-fog,0.0,1.0));
    }
    else
    {
        gl_FragColor = noFog;
    }
    
    /**
    highp float fogStart = 0.5;
    highp float fogEnd = 5.0;
    lowp float fogFactor = (gl_FragDepth - fogStart)/(fogEnd-fogStart);
    lowp float fogFactor = 1 - clamp (fogFactor, 0.0, 1.0);
    gl_FragColor = vec4(gl_FragColor.xyz, gl_FragColor.w * fogFactor);*/
    
    
    
    
    
}
