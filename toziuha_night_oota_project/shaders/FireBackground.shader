// Fire shader

shader_type canvas_item;

uniform vec2 fireMovement = vec2(-0.01, -0.5);
uniform vec2 distortionMovement = vec2(-0.01, -0.3);
uniform float normalStrength = 40.0;
uniform float distortionStrength=0.1;


/** NOISE **/
float rand(vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 hash( vec2 p ) {
	p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(269.5,183.3)) );

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p ) {
   float K1 = 0.366025404; // (sqrt(3)-1)/2;
   float K2 = 0.211324865; // (3-sqrt(3))/6;

	vec2 i = floor( p + (p.x+p.y)*K1 );
	
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = step(a.yx,a.xy);    
    vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;

    vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );

	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));

    return dot( n, vec3(70.0) );
}

float fbm ( in vec2 p ) {
    float f = 0.0;
    mat2 m = mat2(vec2(1.6,  1.2), vec2(-1.2,  1.6 ));
    f  = 0.5000*noise(p); p = m*p;
    f += 0.2500*noise(p); p = m*p;
    f += 0.1250*noise(p); p = m*p;
    f += 0.0625*noise(p); p = m*p;
    f = 0.5 + 0.5 * f;
    return f;
}

/** DISTORTION **/
vec3 bumpMap(vec2 uv) { 
	vec2 iResolution = vec2(1024,600);
    vec2 s = 1. / iResolution.xy;
    float p =  fbm(uv);
    float h1 = fbm(uv + s * vec2(1., 0));
    float v1 = fbm(uv + s * vec2(0, 1.));
       
   	vec2 xy = (p - vec2(h1, v1)) * normalStrength;
    return vec3(xy + .5, 1.);
}

/** MAIN **/
void fragment() {
	float timeScale = TIME * 0.2;//1.0;
	vec2 iResolution = vec2(1024,600);
    vec2 uv = FRAGCOORD.xy/iResolution.xy;

    vec3 normal = bumpMap(uv * vec2(1.0, 0.3) + distortionMovement * timeScale);
    
    vec2 displacement = clamp((normal.xy - .5) * distortionStrength, -1., 1.);
    uv += displacement; 
    
    vec2 uvT = (uv * vec2(1.0, 0.5)) + timeScale * fireMovement;
    float n = pow(fbm(8.0 * uvT), 1.0);    
    
    float gradient = pow(1.0 - uv.y, 2.0) * 5.;
    float finalNoise = n * gradient;
    
    vec3 color = finalNoise * vec3(2.*n, 2.*n*n*n, n*n*n*n);
    COLOR = vec4(color, 1.);
}