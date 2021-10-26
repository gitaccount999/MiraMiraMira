precision highp float;

attribute vec4 aPosition;
attribute vec2 aTexPosition;
attribute float aUVZ;

varying vec2 vTexPosition;
varying float uvz;

void main() {
    gl_Position = aPosition;
    uvz = aUVZ;
    vTexPosition = aTexPosition * aUVZ;
}