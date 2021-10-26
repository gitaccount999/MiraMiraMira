precision highp float;

uniform int uCorners[8];
uniform int uActive[4];

uniform vec4 uColor;

const float d = 10.0;
const float dout = 1.0;
const float din = 1.0;

bool checkPoint(vec2 point) {
    float dist = distance(gl_FragCoord.xy, point);
    if(dist <= d + dout) {
        vec4 col = vec4(uColor.rgb, 1.0 - smoothstep(d - din, d + dout, dist));
        gl_FragColor = col;
        return true;
    }
    return false;
}

void main() {
    if((uActive[0] == 1) && checkPoint(vec2(uCorners[0], uCorners[1]))) {
        return;
    }
    if((uActive[1] == 1) && checkPoint(vec2(uCorners[2], uCorners[3]))) {
        return;
    }
    if((uActive[2] == 1) && checkPoint(vec2(uCorners[4], uCorners[5]))) {
        return;
    }
    if((uActive[3] == 1) && checkPoint(vec2(uCorners[6], uCorners[7]))) {
        return;
    }

    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
}
