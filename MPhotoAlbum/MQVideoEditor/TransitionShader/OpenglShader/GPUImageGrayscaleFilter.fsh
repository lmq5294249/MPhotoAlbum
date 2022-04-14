#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D fromTexture;
in vec2 TextureCoordsVarying;
out vec4 glFragColor;

const vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main()
{
    glFragColor.w = 1.0;
//    vec4 textureColor = texture(fromTexture, vec2(TextureCoordsVarying.x,TextureCoordsVarying.y));
//    float luminance = dot(textureColor.rgb, W);
//    glFragColor = vec4(vec3(luminance), textureColor.a);
    
    vec2 coor = vec2(TextureCoordsVarying.x, TextureCoordsVarying.y);
    vec4 source = texture(fromTexture, coor);
    float r = (source.r + source.g + source.b)/3.0;
    r = source.r*0.3 + source.g*0.59 + source.b*0.11;
    r = dot(source, vec4(0.3, 0.59, 0.11, 0.0));
    vec4 color = vec4(r, r, r, source.a);
    glFragColor = color;
    
    
}
