#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D fromTexture;
uniform sampler2D toTexture;

uniform float     iTime;

in vec2 TextureCoordsVarying;
out vec4 glFragColor;

uniform float textureWidth;
uniform float textureHeight;

uniform float progress;
uniform float brightValue;
highp vec2 singleStepOffset;
highp vec4 params;
highp float brightness;

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

vec3 faceBeauty(vec2 currentCoordinate){
    vec2 vTexCoord = currentCoordinate;
    
    singleStepOffset = getSingleStepOffset(textureWidth, textureHeight);
    float brautyValue = progress + 0.3;
    params = getParams(brautyValue, 0.5);
    brightness = getBright(brightValue);
    
    highp vec3 centralColor = texture(fromTexture, vTexCoord).rgb;
    blurCoordinates[0] = vTexCoord.xy + singleStepOffset * vec2(0.0, -10.0);
    blurCoordinates[1] = vTexCoord.xy + singleStepOffset * vec2(0.0, 10.0);
    blurCoordinates[2] = vTexCoord.xy + singleStepOffset * vec2(-10.0, 0.0);
    blurCoordinates[3] = vTexCoord.xy + singleStepOffset * vec2(10.0, 0.0);
    blurCoordinates[4] = vTexCoord.xy + singleStepOffset * vec2(5.0, -8.0);
    blurCoordinates[5] = vTexCoord.xy + singleStepOffset * vec2(5.0, 8.0);
    blurCoordinates[6] = vTexCoord.xy + singleStepOffset * vec2(-5.0, 8.0);
    blurCoordinates[7] = vTexCoord.xy + singleStepOffset * vec2(-5.0, -8.0);
    blurCoordinates[8] = vTexCoord.xy + singleStepOffset * vec2(8.0, -5.0);
    blurCoordinates[9] = vTexCoord.xy + singleStepOffset * vec2(8.0, 5.0);
    blurCoordinates[10] = vTexCoord.xy + singleStepOffset * vec2(-8.0, 5.0);
    blurCoordinates[11] = vTexCoord.xy + singleStepOffset * vec2(-8.0, -5.0);
    blurCoordinates[12] = vTexCoord.xy + singleStepOffset * vec2(0.0, -6.0);
    blurCoordinates[13] = vTexCoord.xy + singleStepOffset * vec2(0.0, 6.0);
    blurCoordinates[14] = vTexCoord.xy + singleStepOffset * vec2(6.0, 0.0);
    blurCoordinates[15] = vTexCoord.xy + singleStepOffset * vec2(-6.0, 0.0);
    blurCoordinates[16] = vTexCoord.xy + singleStepOffset * vec2(-4.0, -4.0);
    blurCoordinates[17] = vTexCoord.xy + singleStepOffset * vec2(-4.0, 4.0);
    blurCoordinates[18] = vTexCoord.xy + singleStepOffset * vec2(4.0, -4.0);
    blurCoordinates[19] = vTexCoord.xy + singleStepOffset * vec2(4.0, 4.0);
    blurCoordinates[20] = vTexCoord.xy + singleStepOffset * vec2(-2.0, -2.0);
    blurCoordinates[21] = vTexCoord.xy + singleStepOffset * vec2(-2.0, 2.0);
    blurCoordinates[22] = vTexCoord.xy + singleStepOffset * vec2(2.0, -2.0);
    blurCoordinates[23] = vTexCoord.xy + singleStepOffset * vec2(2.0, 2.0);

    highp float sampleColor = centralColor.g * 22.0;
    sampleColor += texture(fromTexture, blurCoordinates[0]).g;
    sampleColor += texture(fromTexture, blurCoordinates[1]).g;
    sampleColor += texture(fromTexture, blurCoordinates[2]).g;
    sampleColor += texture(fromTexture, blurCoordinates[3]).g;
    sampleColor += texture(fromTexture, blurCoordinates[4]).g;
    sampleColor += texture(fromTexture, blurCoordinates[5]).g;
    sampleColor += texture(fromTexture, blurCoordinates[6]).g;
    sampleColor += texture(fromTexture, blurCoordinates[7]).g;
    sampleColor += texture(fromTexture, blurCoordinates[8]).g;
    sampleColor += texture(fromTexture, blurCoordinates[9]).g;
    sampleColor += texture(fromTexture, blurCoordinates[10]).g;
    sampleColor += texture(fromTexture, blurCoordinates[11]).g;
    sampleColor += texture(fromTexture, blurCoordinates[12]).g * 2.0;
    sampleColor += texture(fromTexture, blurCoordinates[13]).g * 2.0;
    sampleColor += texture(fromTexture, blurCoordinates[14]).g * 2.0;
    sampleColor += texture(fromTexture, blurCoordinates[15]).g * 2.0;
    sampleColor += texture(fromTexture, blurCoordinates[16]).g * 2.0;
    sampleColor += texture(fromTexture, blurCoordinates[17]).g * 2.0;
    sampleColor += texture(fromTexture, blurCoordinates[18]).g * 2.0;
    sampleColor += texture(fromTexture, blurCoordinates[19]).g * 2.0;
    sampleColor += texture(fromTexture, blurCoordinates[20]).g * 3.0;
    sampleColor += texture(fromTexture, blurCoordinates[21]).g * 3.0;
    sampleColor += texture(fromTexture, blurCoordinates[22]).g * 3.0;
    sampleColor += texture(fromTexture, blurCoordinates[23]).g * 3.0;

    sampleColor = sampleColor / 62.0;

    highp float highPass = centralColor.g - sampleColor + 0.5;

    for (int i = 0; i < 5; i++) {
        highPass = hardLight(highPass);
    }
    highp float lumance = dot(centralColor, W);

    highp float alpha = pow(lumance, params.r);

    highp vec3 smoothColor = centralColor + (centralColor-vec3(highPass))*alpha*0.1;

    smoothColor.r = clamp(pow(smoothColor.r, params.g), 0.0, 1.0);
    smoothColor.g = clamp(pow(smoothColor.g, params.g), 0.0, 1.0);
    smoothColor.b = clamp(pow(smoothColor.b, params.g), 0.0, 1.0);

    highp vec3 lvse = vec3(1.0)-(vec3(1.0)-smoothColor)*(vec3(1.0)-centralColor);
    highp vec3 bianliang = max(smoothColor, centralColor);
    highp vec3 rouguang = 2.0*centralColor*smoothColor + centralColor*centralColor - 2.0*centralColor*centralColor*smoothColor;

    vec4 fragColor = vec4(mix(centralColor, lvse, alpha), 1.0);
    fragColor.rgb = mix(fragColor.rgb, bianliang, alpha);
    fragColor.rgb = mix(fragColor.rgb, rouguang, params.b);

    highp vec3 satcolor = fragColor.rgb * saturateMatrix;
    fragColor.rgb = mix(fragColor.rgb, satcolor, params.a);
    fragColor.rgb = vec3(fragColor.rgb + vec3(brightness));
    
    return fragColor.rgb;
}

void main(){

    glFragColor.w = 1.0;
    //vec2 newFragCoord = vec2(gl_FragCoord.x,iResolution.y - gl_FragCoord.y);

    vec2 positionToUse = TextureCoordsVarying;
    
    glFragColor = vec4(faceBeauty(positionToUse),1.0);
}
