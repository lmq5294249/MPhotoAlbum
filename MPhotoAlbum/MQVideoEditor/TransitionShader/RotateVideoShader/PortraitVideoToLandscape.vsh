attribute vec3 Position;
attribute vec2 TextureCoords;
varying vec2 TextureCoordsVarying;

void main (void) {
    gl_Position = vec4(Position, 1.0);
    TextureCoordsVarying = TextureCoords;
}
