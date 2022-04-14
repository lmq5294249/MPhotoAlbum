#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D fromTexture;
uniform sampler2D maskImageTexture;
in vec2 TextureCoordsVarying;
out vec4 glFragColor;

uniform vec3 iResolution;
uniform float texelWidthOffset;
uniform float texelHeightOffset;
vec2 singleStepOffset;
float strength;

void main()
{
    vec3 texel = texture(fromTexture,TextureCoordsVarying).rgb;
    
    texel = vec3(
                 texture(maskImageTexture,vec2(texel.r, .16666)).r,
                 texture(maskImageTexture,vec2(texel.g, .5)).g,
                 texture(maskImageTexture,vec2(texel.b, .83333)).b);
    
    glFragColor = vec4(texel, 1.0);
}
