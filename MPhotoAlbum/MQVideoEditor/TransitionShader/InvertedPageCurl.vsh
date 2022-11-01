#version 300 es

in vec3 Position;
in vec2 TextureCoords;
out vec2 TextureCoordsVarying;

void main (void) {
    
    gl_Position = vec4(Position, 1.0);
    TextureCoordsVarying = TextureCoords;
}
