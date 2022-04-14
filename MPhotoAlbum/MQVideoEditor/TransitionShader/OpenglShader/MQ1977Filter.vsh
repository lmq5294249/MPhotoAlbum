#version 300 es
precision highp float;
precision highp int;
in vec3 Position;
in vec2 TextureCoords;
out vec2 TextureCoordsVarying;
uniform float frontCameraValue;

void main (void) {
    gl_Position = vec4(Position, 1.0);
    if (frontCameraValue == 1.0) {
        TextureCoordsVarying = vec2(TextureCoords.x,1.0 -TextureCoords.y);
    }
    else{
        TextureCoordsVarying = TextureCoords;
    }
}

