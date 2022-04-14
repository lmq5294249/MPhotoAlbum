#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D luminanceTexture;
uniform sampler2D chrominanceTexture;
uniform mediump mat3 colorConversionMatrix;

in highp vec2 textureCoordinate;
out vec4 glFragColor;

void main()
{
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    yuv.x = texture(luminanceTexture, textureCoordinate).r;
    yuv.yz = texture(chrominanceTexture, textureCoordinate).ra - vec2(0.5, 0.5);
    rgb = colorConversionMatrix * yuv;
    
    glFragColor = vec4(rgb, 1);
}
