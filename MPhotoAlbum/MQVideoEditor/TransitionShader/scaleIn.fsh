#version 300 es

precision mediump float;

uniform sampler2D fromTexture;
uniform sampler2D toTexture;

uniform float progress;

in vec2 TextureCoordsVarying;

out vec4 glFragColor;

vec4 getFromColor(vec2 uv)
{
    return texture(fromTexture, uv);
}

vec4 getToColor(vec2 uv)
{
    return texture(toTexture, uv);
}

vec4 scale(in vec2 uv){
    uv = 0.5 + (uv - 0.5) * progress;
    return getToColor(uv);
}

vec4 transition (vec2 uv) {
  return mix(getFromColor(uv), scale(uv),progress);
}

void main()
{
    glFragColor = transition(TextureCoordsVarying);
}
