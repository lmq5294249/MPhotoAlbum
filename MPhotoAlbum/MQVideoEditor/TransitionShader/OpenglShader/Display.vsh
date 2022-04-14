#version 300 es
precision highp float;
precision highp int;
in vec3 Position;
in vec2 TextureCoords;
out vec2 TextureCoordsVarying;
uniform mat4 rotationMat;

void main (void) {
    gl_Position = rotationMat * vec4(Position, 1.0);
    TextureCoordsVarying = TextureCoords;
}

