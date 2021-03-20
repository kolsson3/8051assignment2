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

struct Flashlight
{
    lowp vec3 Position;
    lowp vec3 Direction;
    lowp float CutOff;
};

struct Fog
{
    highp float FogDensity;
    highp float FogDistance;
    lowp vec4 FogColor;
    bool FogIsActive;
};

uniform Light u_Light;
uniform Flashlight u_Flashlight;
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
    
    //Determine fog value
    highp float fog_coord = (gl_FragCoord.z / gl_FragCoord.w) / u_Fog.FogDistance;
    highp float fog = fog_coord * u_Fog.FogDensity;
    
    highp vec4 noFog;// = texture2D(u_Texture, frag_TexCoord) * vec4((AmbientColor + DiffuseColor + SpecularColor), 1.0);
    
    //Flashlight stuff
    highp float theta = dot(normalize(u_Light.Direction), normalize(-u_Flashlight.Direction));
    if(theta > 25.0)
    {
        noFog = vec4((AmbientColor + DiffuseColor + SpecularColor), 1.0);
    }
    else
    {
        noFog = texture2D(u_Texture, frag_TexCoord) * vec4((AmbientColor + DiffuseColor + SpecularColor), 1.0);
    }
    
    
    //Calculate color without fog
    //    highp vec4 noFog = texture2D(u_Texture, frag_TexCoord) * vec4((AmbientColor + DiffuseColor + SpecularColor), 1.0);

    
    
    //If fog is active, add it.
    if(u_Fog.FogIsActive)
    {
        gl_FragColor = mix(u_Fog.FogColor, noFog, clamp(1.0-fog,0.0,1.0));
    }
    else
    {
        gl_FragColor = noFog;
    }
}
