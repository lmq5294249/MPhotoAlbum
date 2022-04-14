#version 300 es

precision highp float;
precision highp int;
precision highp sampler2D;

uniform sampler2D fromTexture;
in vec2 TextureCoordsVarying;
uniform vec3      iResolution; 
out vec4 glFragColor;
vec2      ifFragCoordOffsetUniform;
vec4      iMouse;
uniform float frontCameraValue;

void mainImage(out vec4 O, vec2 u) {
    vec2 R = iResolution.xy,
         U = .55*abs(u+u - R)/R.y;
    O = texture(fromTexture, (U.x>U.y ? U : U.yx) + iMouse.xy/R );
    
}

void main(){
    ifFragCoordOffsetUniform = vec2(0.0,0.0);
    iMouse = vec4(0.0,0.2,0.0,0.0);
    glFragColor.w = 1.0;
    vec2 newFragCoord;
    if (frontCameraValue == 1.0) {
        newFragCoord = gl_FragCoord.xy;
    }
    else{
        newFragCoord = vec2(gl_FragCoord.x,iResolution.y - gl_FragCoord.y);
    }
    mainImage(glFragColor, (newFragCoord.xy+ifFragCoordOffsetUniform) );
}
