#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D fromTexture;
in vec2 TextureCoordsVarying;
out vec4 glFragColor;

uniform vec3 iResolution;
uniform vec2 iMouse;
uniform float frontCameraValue;

//float normpdf(in float x, in float sigma)
//{
//    return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
//}
//
//
//void mainImage( out vec4 fragColor, in vec2 fragCoord )
//{
//    vec3 c = texture(fromTexture, fragCoord.xy / iResolution.xy).rgb;
//    if (fragCoord.x < iMouse.x)
//    {
//        fragColor = vec4(c, 1.0);
//    } else {
//
//        //declare stuff
//        const int mSize = 11;
//        const int kSize = (mSize-1)/2;
//        float kernel[mSize];
//        vec3 final_colour = vec3(0.0);
//
//        //create the 1-D kernel
//        float sigma = 7.0;
//        float Z = 0.0;
//        for (int j = 0; j <= kSize; ++j)
//        {
//            kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
//        }
//
//        //get the normalization factor (as the gaussian has been clamped)
//        for (int j = 0; j < mSize; ++j)
//        {
//            Z += kernel[j];
//        }
//
//        //read out the texels
//        for (int i=-kSize; i <= kSize; ++i)
//        {
//            for (int j=-kSize; j <= kSize; ++j)
//            {
//                final_colour += kernel[kSize+j]*kernel[kSize+i]*texture(fromTexture, (fragCoord.xy+vec2(float(i),float(j))) / iResolution.xy).rgb;
//
//            }
//        }
//
//
//        fragColor = vec4(final_colour/(Z*Z), 1.0);
//    }
//}

const int samples = 25, //samples = 35
          LOD = 2,         // gaussian done on MIPmap at scale LOD
          sLOD = 1 << LOD; // tile size = 2^LOD
const float sigma = float(samples) * .25;

float gaussian(vec2 i) {
    return exp( -.5* dot(i/=sigma,i) ) / ( 6.28 * sigma*sigma );
}

vec4 blur(sampler2D sp, vec2 U, vec2 scale) {
    vec4 O = vec4(0);
    int s = samples/sLOD;
    
    for ( int i = 0; i < s*s; i++ ) {
        vec2 d = vec2(i%s, i/s)*float(sLOD) - float(samples)/2.;
        O += gaussian(d) * textureLod( sp, U + scale * d , float(LOD) );
    }
    
    return O / O.a;
}

void mainImage(out vec4 O, vec2 U) {
    O = blur( fromTexture, U/iResolution.xy, 1./iResolution.xy );
}

void main()
{
    glFragColor.w = 1.0;
    vec2 newFragCoord;
    if (frontCameraValue == 1.0) {
        newFragCoord = vec2(gl_FragCoord.x,iResolution.y - gl_FragCoord.y);
    }
    else{
        newFragCoord = gl_FragCoord.xy;
    }
    mainImage(glFragColor, newFragCoord.xy);
}
