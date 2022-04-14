#version 300 es

precision highp float;

uniform sampler2D fromTexture;
uniform sampler2D toTexture;

in vec2 TextureCoordsVarying;
out vec4 glFragColor;

vec4 blendColor(in highp vec4 dstColor, in highp vec4 srcColor)
{
   vec3 vOne = vec3(1.0, 1.0, 1.0);
   vec3 vZero = vec3(0.0, 0.0, 0.0);
   vec3 resultFore = srcColor.rgb + dstColor.rgb * (1.0 - srcColor.a);
   return vec4(resultFore.rgb, 1.0);
}

void main()
 {
     vec2 rightTextureCoordinate = vec2(TextureCoordsVarying.x * 0.5 + 0.5 , TextureCoordsVarying.y);
     vec4 rightTextureColor = texture(fromTexture, rightTextureCoordinate);
     vec2 leftTextureCoordinate = vec2(TextureCoordsVarying.x * 0.5 , TextureCoordsVarying.y);;
     vec4 leftTextureColor = texture(fromTexture, leftTextureCoordinate);
     vec4 mask = vec4(rightTextureColor.rgb, leftTextureColor.r);
     vec4 background = texture(toTexture, vec2(TextureCoordsVarying.x, TextureCoordsVarying.y));

     if (mask.a == 0.0) {
         glFragColor = background;
     }
     else{
         vec3 resultFore = mask.rgb + background.rgb *(1.0 - mask.a);
         glFragColor = vec4(resultFore.rgb,1.0);
     }
}
