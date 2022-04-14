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

vec4 transition (vec2 p) {
    float count = 10.0;
    float smoothness = 0.5;
    float pr = smoothstep(-smoothness, 0.0, p.x - progress * (1.0 + smoothness));
    float s = step(pr, fract(count * p.x));
    return mix(getFromColor(p), getToColor(p), s);
}

void main()
{
    glFragColor = transition(TextureCoordsVarying);
}
