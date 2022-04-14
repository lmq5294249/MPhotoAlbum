#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D fromTexture;
in vec2 TextureCoordsVarying;
out vec4 glFragColor;

in vec2 blurCoordinates[5];

void main()
{
    lowp vec4 sum = vec4(0.0);
    sum += texture(fromTexture, blurCoordinates[0]) * 0.204164;
    sum += texture(fromTexture, blurCoordinates[1]) * 0.304005;
    sum += texture(fromTexture, blurCoordinates[2]) * 0.304005;
    sum += texture(fromTexture, blurCoordinates[3]) * 0.093913;
    sum += texture(fromTexture, blurCoordinates[4]) * 0.093913;
    
    glFragColor = sum;
}
