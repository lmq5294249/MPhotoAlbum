precision highp float;

uniform sampler2D fromTexture;
uniform sampler2D toTexture;

uniform float progress;
uniform float mixedModel;
varying vec2 TextureCoordsVarying;

float offset;

vec4 getFromColor(vec2 uv)
{
    return texture2D(fromTexture, uv);
}

vec4 getToColor(vec2 uv)
{
    return texture2D(toTexture, uv);
}

const float OFFSET_LEVEL = 0.4;
const float SCALE_LEVEL  = 4.0;

vec2 rotate(float radius, float angle, vec2 texSize, vec2 texCoord)
{
    vec2 newTexCoord = texCoord;
    vec2 center = vec2(texSize.x / 2.0, texSize.y / 2.0);
    vec2 tc = texCoord * texSize;
    tc -= center;
    float dist = length(tc) / (texSize.x / 2.0);
    if (dist < radius) {
        float percent = (radius - dist) / radius;
        float theta = percent * percent * angle * 8.0;
        float s = sin(theta);
        float c = cos(theta);
        tc = vec2(dot(tc, vec2(c, -s)), dot(tc, vec2(s, c)));
        tc += center;

        newTexCoord = tc / texSize;
    }
    return newTexCoord;
}

const float scale = 0.4;

float value;
vec2 texSize;

void main()
{
    //Embedding landscape video into portrait
    texSize = vec2(1920.0,1080.0);
    
    float x = (texSize.x * texSize.x - texSize.y * texSize.y) / (2.0 * texSize.x);
    
    float picH = texSize.x - 2.0 * x;
    
    float picW = texSize.y;
    
    float percentageX = x / texSize.x;
    
    float percentageH = picH / texSize.x;
    
    vec2 posotionCoord = vec2(0.0,percentageX);
    
    if (TextureCoordsVarying.y > posotionCoord.y && TextureCoordsVarying.y < posotionCoord.y + percentageH) {
        
        vec2 newTexCoord = vec2((TextureCoordsVarying.x - posotionCoord.x), (TextureCoordsVarying.y - posotionCoord.y)/percentageH);
        gl_FragColor = getToColor(newTexCoord);
        
    }
    else{
        
        if (mixedModel > 0.0) {
            vec4 color = vec4(0.0);
            float seg = 5.0;
            float i = -seg;
            float j = 0.0;
            float f = 0.0;
            float dv = 2.0/512.0;
            float tot = 0.0;

            for(; i <= seg; ++i)
            {
                for(j = -seg; j <= seg; ++j)
                {
                    f = (1.1 - sqrt(i*i + j*j)/8.0);
                    f *= f;
                    tot += f;
                    color += texture2D( fromTexture, vec2(TextureCoordsVarying.x + j * dv, TextureCoordsVarying.y + i * dv) ).rgba * f;
                }
             }
            color /= tot;

            gl_FragColor = color;
        }
        else{
            gl_FragColor = vec4(0.0,0.0,0.0,1.0);
        }
        
//        gl_FragColor = texture2D(fromTexture, texCoord);
    }
    
}

