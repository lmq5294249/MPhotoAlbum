#version 300 es

precision mediump float;

uniform sampler2D fromTexture;
uniform sampler2D toTexture;

uniform float progress;

float amplitude = 100.0; // = 100.0
float speed = 50.0; // = 50.0

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
  vec2 dir = uv - vec2(.5);
  float dist = length(dir);
  vec2 offset = dir * (sin(progress * dist * amplitude - progress * speed) + .5) / 30.;
  return mix(
    getFromColor(uv + offset),
    getToColor(uv),
    smoothstep(0.2, 1.0, progress)
  );
}

void main()
{
    glFragColor = transition(TextureCoordsVarying);
}
