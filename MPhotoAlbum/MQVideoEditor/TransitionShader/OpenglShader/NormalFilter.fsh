#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D fromTexture;
in vec2 TextureCoordsVarying;
out vec4 glFragColor;

void main(){
    
    glFragColor.w = 1.0;
    glFragColor = texture(fromTexture, vec2(TextureCoordsVarying.x, TextureCoordsVarying.y));
}
