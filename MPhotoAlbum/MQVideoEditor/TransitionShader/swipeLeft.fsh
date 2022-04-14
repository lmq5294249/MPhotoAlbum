/*
 The picture moves from right to left
 */
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

vec4 transition (vec2 uv) {
  if (1.0 - uv.x > progress) {
    return getFromColor(vec2(uv.x + progress, uv.y));
  } else {
    return getToColor(vec2(uv.x + progress - 1.0, uv.y));
  }
}

void main()
{
    glFragColor = transition(TextureCoordsVarying);
}
