#version 300 es
precision highp float;
precision highp int;
in vec4 position;
in vec4 inputTextureCoordinate;
out vec2 textureCoordinate;

uniform mat4 rotationMat;

void main()
{
    gl_Position = rotationMat * position;
    textureCoordinate = inputTextureCoordinate.xy;
}
