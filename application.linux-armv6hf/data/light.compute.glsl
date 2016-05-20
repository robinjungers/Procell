/**
*
* These shaders were written thanks to :
* https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows
*
**/

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER
#define PI 3.14

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform vec3 resolution;
uniform float sharpness;

//alpha threshold for our occlusion map
const float THRESHOLD = 0.75;

void main(void) {
  float distance = 1.0;

  for (float y=0.0; y<resolution.y; y+=sharpness) {
        //rectangular to polar filter
        vec2 norm = vec2(vertTexCoord.s, y/resolution.y) * 2.0 - 1.0;
        float theta = PI*1.5 + norm.x * PI; 
        float r = (1.0 + norm.y) * 0.5;

        //coord which we will sample from occlude map
        vec2 coord = vec2(-r * sin(theta), r * cos(theta))/2.0 + 0.5;

        //sample the occlusion map
        vec4 data = texture2D(texture, coord);

        //the current distance is how far from the top we've come
        float dst = y/resolution.y;

        //if we've hit an opaque fragment (occluder), then get new distance
        //if the new distance is below the current, then we'll use that for our ray
        float caster = data.a;
        if (caster > THRESHOLD) {
            distance = min(distance, dst);
            //NOTE: we could probably use "break" or "return" here
        }
  } 
  gl_FragColor = vec4(vec3(distance), 1.0);
}