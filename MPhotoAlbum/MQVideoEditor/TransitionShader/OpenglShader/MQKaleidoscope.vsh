#version 300 es
precision highp float;
precision highp int;
in vec3 Position;
in vec2 TextureCoords;
out vec2 TextureCoordsVarying;

uniform float texelWidth;
uniform float texelHeight;

uniform float texelWidthOffset;
uniform float texelHeightOffset;

out vec2 blurCoordinates[5];

void main (void) {
    gl_Position = vec4(Position, 1.0);
    TextureCoordsVarying = vec2(TextureCoords.x,TextureCoords.y);
    
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    blurCoordinates[0] = TextureCoordsVarying.xy;
    blurCoordinates[1] = TextureCoordsVarying.xy + singleStepOffset * 1.407333;
    blurCoordinates[2] = TextureCoordsVarying.xy - singleStepOffset * 1.407333;
    blurCoordinates[3] = TextureCoordsVarying.xy + singleStepOffset * 3.294215;
    blurCoordinates[4] = TextureCoordsVarying.xy - singleStepOffset * 3.294215;
}

