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

vec4 transition(vec2 p) {
  float x = progress;
  x=smoothstep(.0,1.0,(x*2.0+p.x-1.0));
  return mix(getFromColor((p-.5)*(1.-x)+.5), getToColor((p-.5)*x+.5), x);
}

void main()
{
    glFragColor = transition(TextureCoordsVarying);
}
