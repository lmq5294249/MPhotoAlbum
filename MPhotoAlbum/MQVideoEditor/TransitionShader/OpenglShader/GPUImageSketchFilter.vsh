#version 300 es
precision highp float;
precision highp int;
in vec3 Position;
in vec2 TextureCoords;
out vec2 TextureCoordsVarying;

uniform float texelWidth;
uniform float texelHeight;

out vec2 leftTextureCoordinate;
out vec2 rightTextureCoordinate;

out vec2 topTextureCoordinate;
out vec2 topLeftTextureCoordinate;
out vec2 topRightTextureCoordinate;

out vec2 bottomTextureCoordinate;
out vec2 bottomLeftTextureCoordinate;
out vec2 bottomRightTextureCoordinate;

uniform float frontCameraValue;

void main (void) {
    gl_Position = vec4(Position, 1.0);
    if (frontCameraValue == 1.0) {
        TextureCoordsVarying = vec2(TextureCoords.x,1.0 -TextureCoords.y);
    }
    else{
        TextureCoordsVarying = TextureCoords;
    }
    
    vec2 widthStep = vec2(texelWidth, 0.0);
    vec2 heightStep = vec2(0.0, texelHeight);
    
    vec2 widthHeightStep = vec2(texelWidth, texelHeight);
    vec2 widthNegativeHeightStep = vec2(texelWidth, -texelHeight);
    
    leftTextureCoordinate = TextureCoordsVarying - widthStep;
    rightTextureCoordinate = TextureCoordsVarying + widthStep;
    
    topTextureCoordinate = TextureCoordsVarying - heightStep;
    topLeftTextureCoordinate = TextureCoordsVarying - widthHeightStep;
    topRightTextureCoordinate = TextureCoordsVarying + widthNegativeHeightStep;
    
    bottomTextureCoordinate = TextureCoordsVarying + heightStep;
    bottomLeftTextureCoordinate = TextureCoordsVarying - widthNegativeHeightStep;
    bottomRightTextureCoordinate = TextureCoordsVarying + widthHeightStep;
}

