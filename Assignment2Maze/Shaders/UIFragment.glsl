
//Input date from vertex shader
varying lowp vec4 frag_Color;
varying lowp vec2 frag_TexCoord;
varying lowp vec3 frag_Position;
uniform sampler2D u_Texture;

void main(void)
{
    if(texture2D(u_Texture, frag_TexCoord).a <= 0.5)
    {
        discard; //Discard alpha fragments for player icon to display properly
    }
    gl_FragColor = frag_Color * texture2D(u_Texture, frag_TexCoord);
}
