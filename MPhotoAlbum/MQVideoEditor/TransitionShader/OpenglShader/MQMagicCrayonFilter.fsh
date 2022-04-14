#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D fromTexture;
in vec2 TextureCoordsVarying;
out vec4 glFragColor;

uniform vec3 iResolution;
uniform float texelWidthOffset;
uniform float texelHeightOffset;
vec2 singleStepOffset;
float strength;

const highp vec3 W = vec3(0.299,0.587,0.114);

const mat3 rgb2yiqMatrix = mat3(
        0.299, 0.587, 0.114,
        0.596,-0.275,-0.321,
        0.212,-0.523, 0.311);

const mat3 yiq2rgbMatrix = mat3(
        1.0, 0.956, 0.621,
        1.0,-0.272,-1.703,
        1.0,-1.106, 0.0);

void main()
{
    singleStepOffset = vec2(1.0/iResolution.x, 1.0/iResolution.y);
    
    strength = 2.0;
    
    vec4 oralColor = texture(fromTexture, TextureCoordsVarying);

    vec3 maxValue = vec3(0.,0.,0.);
    
    for(int i = -2; i<=2; i++)
    {
        for(int j = -2; j<=2; j++)
        {
            vec4 tempColor = texture(fromTexture, TextureCoordsVarying+singleStepOffset*vec2(i,j));
            maxValue.r = max(maxValue.r,tempColor.r);
            maxValue.g = max(maxValue.g,tempColor.g);
            maxValue.b = max(maxValue.b,tempColor.b);
        }
    }
    
    vec3 textureColor = oralColor.rgb / maxValue;
    
    float gray = dot(textureColor, W);
    float k = 0.223529;
    float alpha = min(gray,k)/k;
    
    textureColor = textureColor * alpha + (1.-alpha)*oralColor.rgb;
    
    vec3 yiqColor = textureColor * rgb2yiqMatrix;
    
    yiqColor.r = max(0.0,min(1.0,pow(gray,strength)));
    
    textureColor = yiqColor * yiq2rgbMatrix;
    
    glFragColor = vec4(textureColor, oralColor.w);
}
