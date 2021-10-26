precision highp float;
uniform sampler2D uTexture;

varying vec2 vTexPosition;
varying float uvz;

uniform float uBounds[4];

uniform float uHeight;
uniform float uWidth;

uniform vec4 uFrameColor;

void main() {
    float left = (uBounds[0] + 1.0) / 2.0 * uWidth;
    float right = (uBounds[1] + 1.0) / 2.0 * uWidth;
    float bottom = (uBounds[2] + 1.0) / 2.0 * uHeight;
    float top = (uBounds[3] + 1.0) / 2.0 * uHeight;
    
    vec2 pos = vTexPosition / uvz;
    vec4 col = texture2D(uTexture, pos);
    if( (gl_FragCoord.x < left) || (gl_FragCoord.x > right) ||
        (gl_FragCoord.y < bottom) || (gl_FragCoord.y > top) ) {

        col.a = 0.1;
    }
    
    if((gl_FragCoord.x >= left - 3.0) && (gl_FragCoord.x <= right + 2.0)) {
        if((gl_FragCoord.y <= bottom + 2.0) && (gl_FragCoord.y >= bottom - 2.0)) {
            col = uFrameColor;
        }
        if((gl_FragCoord.y <= top + 2.0) && (gl_FragCoord.y >= top - 2.0)) {
            col = uFrameColor;
        }
    }
    if((gl_FragCoord.y >= bottom - 2.0) && (gl_FragCoord.y <= top + 2.0)) {
        if((gl_FragCoord.x <= left + 1.0) && (gl_FragCoord.x >= left - 3.0)) {
            col = uFrameColor;
        }
        if((gl_FragCoord.x <= right + 2.0) && (gl_FragCoord.x >= right - 2.0)) {
            col = uFrameColor;
        }
    }

    gl_FragColor = col;
}