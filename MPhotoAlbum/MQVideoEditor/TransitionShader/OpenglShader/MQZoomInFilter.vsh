#version 300 es
precision highp float;
precision highp int;
in vec3 Position;
in vec2 TextureCoords;
out vec2 TextureCoordsVarying;

uniform float texelWidth;
uniform float texelHeight;


void main (void) {
    gl_Position = vec4(Position, 1.0);
    TextureCoordsVarying = vec2(TextureCoords.x,TextureCoords.y);
    
}

