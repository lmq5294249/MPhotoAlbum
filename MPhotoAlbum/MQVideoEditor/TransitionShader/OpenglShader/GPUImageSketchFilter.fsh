#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D fromTexture;
in vec2 TextureCoordsVarying;
out vec4 glFragColor;

in vec2 textureCoordinate;
in vec2 leftTextureCoordinate;
in vec2 rightTextureCoordinate;

in vec2 topTextureCoordinate;
in vec2 topLeftTextureCoordinate;
in vec2 topRightTextureCoordinate;

in vec2 bottomTextureCoordinate;
in vec2 bottomLeftTextureCoordinate;
in vec2 bottomRightTextureCoordinate;

uniform float progress;
float edgeStrength;

void main()
{
    glFragColor.w = 1.0;
    edgeStrength = progress;
    
    float bottomLeftIntensity = texture(fromTexture, bottomLeftTextureCoordinate).r;
    float topRightIntensity = texture(fromTexture, topRightTextureCoordinate).r;
    float topLeftIntensity = texture(fromTexture, topLeftTextureCoordinate).r;
    float bottomRightIntensity = texture(fromTexture, bottomRightTextureCoordinate).r;
    float leftIntensity = texture(fromTexture, leftTextureCoordinate).r;
    float rightIntensity = texture(fromTexture, rightTextureCoordinate).r;
    float bottomIntensity = texture(fromTexture, bottomTextureCoordinate).r;
    float topIntensity = texture(fromTexture, topTextureCoordinate).r;
    float h = -topLeftIntensity - 2.0 * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0 * bottomIntensity + bottomRightIntensity;
    float v = -bottomLeftIntensity - 2.0 * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0 * rightIntensity + topRightIntensity;
    
    float mag = 1.0 - (length(vec2(h, v)) * edgeStrength);
    
    glFragColor = vec4(vec3(mag), 1.0);
}
