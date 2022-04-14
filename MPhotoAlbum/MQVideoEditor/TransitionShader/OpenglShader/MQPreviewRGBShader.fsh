#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D inputImageTexture;

in vec2 textureCoordinate;
out vec4 glFragColor;

void main()
{
    glFragColor = texture(inputImageTexture, vec2(textureCoordinate.x,textureCoordinate.y));
}
