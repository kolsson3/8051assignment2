
uniform highp mat4 u_ModelViewMatrix; //Model transform

//Input date from model vertex
attribute vec4 a_Position;
attribute vec4 a_Color;
attribute vec2 a_TexCoord;
attribute vec3 a_Normal;

//Output variables to fragment shader
varying lowp vec3 frag_Position;
varying lowp vec4 frag_Color;
varying lowp vec2 frag_TexCoord;

void main(void)
{
    frag_Color = a_Color;
    frag_Color.a = 0.5;
    gl_Position = u_ModelViewMatrix * a_Position;
    frag_TexCoord = a_TexCoord;
    frag_Position = (u_ModelViewMatrix * a_Position).xyz;
}
