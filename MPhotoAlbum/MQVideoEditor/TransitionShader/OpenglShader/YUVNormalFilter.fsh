#version 300 es
precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D luminanceTexture;
uniform sampler2D chrominanceTexture;

in vec2 TextureCoordsVarying;

out vec4 glFragColor;

uniform float hasFace;
uniform float facePoints[68 * 2];

uniform highp float aspectRatio;

uniform float thinFaceDelta;
uniform float bigEyeDelta;

vec2 enlargeEye(vec2 textureCoord, vec2 originPosition, float radius, float delta) {
    
    float weight = distance(vec2(textureCoord.x, textureCoord.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio)) / radius;
    
    weight = 1.0 - (1.0 - weight * weight) * delta;
    weight = clamp(weight,0.0,1.0);
    textureCoord = originPosition + (textureCoord - originPosition) * weight;
    return textureCoord;
}

vec2 curveWarp(vec2 textureCoord, vec2 originPosition, vec2 targetPosition, float delta) {
    
    vec2 offset = vec2(0.0);
    vec2 result = vec2(0.0);
    vec2 direction = (targetPosition - originPosition) * delta;
    
    float radius = distance(vec2(targetPosition.x, targetPosition.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio));
    float ratio = distance(vec2(textureCoord.x, textureCoord.y / aspectRatio), vec2(originPosition.x, originPosition.y / aspectRatio)) / radius;
    
    ratio = 1.0 - ratio;
    ratio = clamp(ratio, 0.0, 1.0);
    offset = direction * ratio;
    
    result = textureCoord - offset;
    
    return result;
}

vec2 thinFace(vec2 currentCoordinate){
    vec2 faceIndexs[8];
//     faceIndexs[0] = vec2(0., 45.);
//     faceIndexs[1] = vec2(10.,45.);
    faceIndexs[0] = vec2(1., 30.);
    faceIndexs[1] = vec2(15., 30.);
    faceIndexs[2] = vec2(3., 33.);
    faceIndexs[3] = vec2(13., 33.);
    faceIndexs[4] = vec2(5., 33.);
    faceIndexs[5] = vec2(11., 33.);
    faceIndexs[6] = vec2(7., 33.);
    faceIndexs[7] = vec2(9., 33.);
    
    for(int i = 0;i < 10;i++){
        int originIndex = int(faceIndexs[i].x);
        int targetIndex = int(faceIndexs[i].y);
        
        vec2 originPoint = vec2(facePoints[originIndex * 2],
                                facePoints[originIndex *2 + 1]);
        vec2 targetPoint = vec2(facePoints[targetIndex * 2],
                                facePoints[targetIndex *2 + 1]);
        
        currentCoordinate = curveWarp(currentCoordinate,originPoint,targetPoint,thinFaceDelta);
    }
    return currentCoordinate;
}

vec2 bigEye(vec2 currentCoordinate) {
    
//    vec2 faceIndexs[4];
//    faceIndexs[0] = vec2(36., 39.);
//    faceIndexs[1] = vec2(37., 38.);
//
//    faceIndexs[2] = vec2(42., 45.);
//    faceIndexs[3] = vec2(43., 44.);
//
//    vec2 faceValue[2];
//    for (int i = 0; i < 4; i=i+2) {
//        int firstLeftEye = int(faceIndexs[i].x);
//        int firstrightEye = int(faceIndexs[i].y);
//        int secondLeftEye = int(faceIndexs[i+1].x);
//        int secondrightEye = int(faceIndexs[i+1].y);
//
//        vec2 originPoint = vec2((facePoints[firstLeftEye * 2] + facePoints[firstrightEye * 2])/2.0f, (facePoints[firstLeftEye * 2 + 1] + facePoints[firstrightEye * 2 + 1])/2.0f);
//        vec2 targetPoint = vec2((facePoints[secondLeftEye * 2] + facePoints[secondrightEye * 2])/2.0f, (facePoints[secondLeftEye * 2 + 1] + facePoints[secondrightEye * 2 + 1])/2.0f);
//
//        float radius = distance(vec2(targetPoint.x, targetPoint.y / aspectRatio), vec2(originPoint.x, originPoint.y / aspectRatio));
//        radius = radius * 5.;//0.300493006324773
//        currentCoordinate = enlargeEye(currentCoordinate, originPoint, radius, bigEyeDelta);
//    }
    
    vec2 faceIndexs[4];
    faceIndexs[0] = vec2(41., 37.);
    faceIndexs[1] = vec2(40., 38.);

    faceIndexs[2] = vec2(47., 43.);
    faceIndexs[3] = vec2(46., 44.);
    
//    faceIndexs[0] = vec2(41., 37.);
//    faceIndexs[1] = vec2(46., 44.);
    
    for(int i = 0; i < 4; i++)
    {
        int originIndex = int(faceIndexs[i].x);//72
        int targetIndex = int(faceIndexs[i].y);//13

        vec2 originPoint = vec2(facePoints[originIndex * 2], facePoints[originIndex * 2 + 1]);//NSPoint: {0.38518361522073974, 0.32416098202065768},
        vec2 targetPoint = vec2(facePoints[targetIndex * 2], facePoints[targetIndex * 2 + 1]);//NSPoint: {0.38579181530803908, 0.3132528545029345},

        float radius = distance(vec2(targetPoint.x, targetPoint.y / aspectRatio), vec2(originPoint.x, originPoint.y / aspectRatio));
        //0.38579181530803908,0.556893963560772
        //0.38518361522073974,0.496798439878403
        //0.000608200087299 , 0.060095523682369
        //0.000000369907346 , 0.003611471966658
        //0.003611841874004
        //0.060098601264955
        radius = radius * 5.;//0.300493006324773
        currentCoordinate = enlargeEye(currentCoordinate, originPoint, radius, bigEyeDelta);
    }
    return currentCoordinate;
}

const highp vec3 W = vec3(0.299, 0.587, 0.114);
const highp mat3 saturateMatrix = mat3(
        1.1102, -0.0598, -0.061,
        -0.0774, 1.0826, -0.1186,
        -0.0228, -0.0228, 1.1772);

highp vec2 blurCoordinates[24];

highp float hardLight(highp float color) {
    if (color <= 0.5)
        color = color * color * 2.0;
    else
        color = 1.0 - ((1.0 - color)*(1.0 - color) * 2.0);
    return color;
}

vec4 getParams(const float beauty, const float saturate) {
    vec4 value = vec4(1.6 - 1.2 * beauty, 1.3 - 0.6 * beauty, -0.2 + 0.6 * saturate, -0.2 + 0.6 * saturate);
    return value;
}

float getBright(const float bright) {
    return 0.6 * (-0.5 + bright);
}

vec2 getSingleStepOffset(const float width, const float height) {
    vec2 value = vec2(2.0 / width, 2.0 / height);
    return value;
}

void main(void)
{
    mediump vec3 yuv;
    lowp vec3 rgb;

    vec2 positionToUse = TextureCoordsVarying;
   
    if (hasFace == 1.0) {
        positionToUse = thinFace(positionToUse);
        positionToUse = bigEye(positionToUse);
    }
    
    yuv.x = texture(luminanceTexture, positionToUse).r - (16.0/255.0);
    yuv.yz = texture(chrominanceTexture, positionToUse).ra - vec2(0.5, 0.5);
   
    rgb = mat3( 1.164,    1.164,   1.164,
                0.0,     -0.213,   2.112,
               1.793,    -0.533,     0.0) * yuv;
    
    glFragColor = vec4(rgb, 1.0);
}
