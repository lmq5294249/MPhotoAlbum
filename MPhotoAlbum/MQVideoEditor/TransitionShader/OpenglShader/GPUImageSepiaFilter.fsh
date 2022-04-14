#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D fromTexture;
in vec2 TextureCoordsVarying;
out vec4 glFragColor;

mat4 colorMatrix;
float intensity;

void main()
{
    intensity = 1.0;
    
    colorMatrix = mat4(0.3588, 0.7044, 0.1368, 0.0,
                       0.2990, 0.5870, 0.1140, 0.0,
                       0.2392, 0.4696, 0.0912 ,0.0,
                       0,0,0,1.0);
    
    vec4 textureColor = texture(fromTexture, vec2(TextureCoordsVarying.x, TextureCoordsVarying.y));
    vec4 outputColor = textureColor * colorMatrix;
    
    glFragColor = (intensity * outputColor) + ((1.0 - intensity) * textureColor);
}
