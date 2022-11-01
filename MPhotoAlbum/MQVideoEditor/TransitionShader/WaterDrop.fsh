#version 300 es

precision mediump float;

uniform sampler2D fromTexture;
uniform sampler2D toTexture;

uniform float progress;

float amplitude = 30.0; // = 30
float speed = 30.0; // = 30

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

vec4 transition(vec2 p) {
  vec2 dir = p - vec2(.5);
  float dist = length(dir);

  if (dist > progress) {
    return mix(getFromColor( p), getToColor( p), progress);
  } else {
    vec2 offset = dir * sin(dist * amplitude - progress * speed);
    return mix(getFromColor( p + offset), getToColor( p), progress);
  }
}

void main()
{
    glFragColor = transition(TextureCoordsVarying);
}
