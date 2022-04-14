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

void mainImage( out vec4 fragColor, in vec2 fragCoord )//Drag mouse over rendering area
{
    vec2 p = fragCoord.xy / iResolution.x;//normalized coords with some cheat
                                                             //(assume 1:1 prop)
    float prop = iResolution.x / iResolution.y;//screen proroption
    vec2 m = vec2(0.5, 0.5 / prop);//center coords
    vec2 d = p - m;//vector from center to current fragment
    float r = sqrt(dot(d, d)); // distance of pixel from center

    float power = ( 2.0 * 3.141592 / (2.0 * sqrt(dot(m, m))) ) * (iMouse.x / iResolution.x - 0.5);//amount of effect

    float bind;//radius of 1:1 effect
    if (power > 0.0) bind = sqrt(dot(m, m));//stick to corners
    else {if (prop < 1.0) bind = m.x; else bind = m.y;}//stick to borders

    //Weird formulas
    vec2 uv;
//    if (power > 0.0)//fisheye
        uv = m + normalize(d) * tan(r * power) * bind / tan( bind * power);
//    else if (power < 0.0)//antifisheye
//        uv = m + normalize(d) * atan(r * -power * 10.0) * bind / atan(-power * bind * 10.0);
//    else uv = p;//no effect for power = 1.0

    vec3 col = texture(fromTexture, vec2(uv.x, -uv.y * prop)).xyz;//Second part of cheat
                                                      //for round effect, not elliptical
    fragColor = vec4(col, 1.0);
}

//const float radius=2.;
//const float depth=radius/2.;
//// === main loop ===
//void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
//  vec2 uv = fragCoord.xy/iResolution.xy;
//  //vec2 center = iMouse.xy/iResolution.xy;
//  vec2 center = vec2(0.5,0.5);
//  float ax = ((uv.x - center.x) * (uv.x - center.x)) / (0.2*0.2) + ((uv.y - center.y) * (uv.y - center.y)) / (0.2/ (  iResolution.x / iResolution.y )) ;
//  float dx = 0.0 + (-depth/radius)*ax + (depth/(radius*radius))*ax*ax;
//    float f =  (ax + dx );
//  if (ax > radius) f = ax;
//    vec2 magnifierArea = center + (uv-center)*f/ax;
//    fragColor = vec4(texture( fromTexture, vec2(1,-1) * magnifierArea ).rgb, 1.);
//}

void main()
{
    glFragColor.w = 1.0;
    vec2 newFragCoord;
    if (frontCameraValue == 1.0) {
        newFragCoord = gl_FragCoord.xy;
    }
    else{
        newFragCoord = vec2(gl_FragCoord.x,iResolution.y - gl_FragCoord.y);
    }
    mainImage(glFragColor, newFragCoord.xy);
    
//    vec2 center = vec2(0.5,0.5);
//
//    highp vec2 normCoord = 2.0 * TextureCoordsVarying - 1.0;
//    highp vec2 normCenter = 2.0 * center - 1.0;
//
//    normCoord -= normCenter;
//    mediump vec2 s = sign(normCoord);
//    normCoord = abs(normCoord);
//    normCoord = 0.5 * normCoord + 0.5 * smoothstep(0.25, 0.5, normCoord) * normCoord;
//    normCoord = s * normCoord;
//
//    normCoord += normCenter;
//
//    mediump vec2 textureCoordinateToUse = normCoord / 2.0 + 0.5;
//
//
//    glFragColor = texture(fromTexture, textureCoordinateToUse );
}
