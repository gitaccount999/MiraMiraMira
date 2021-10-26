precision highp float;

const float sz = 40.0;

void main() {
    bool b1 = mod(gl_FragCoord.x, sz) < (sz * 0.5);
    bool b2 = mod(gl_FragCoord.y, sz) < (sz * 0.5);
    
    if((b1 && b2) || (!b1 && !b2)) {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    } else {
        gl_FragColor = vec4(0.9, 0.9, 0.9, 0.9);
    }
}