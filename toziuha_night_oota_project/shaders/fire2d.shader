/*
	Fire Shader by Yui Kinomoto @arlez80
	MIT License
*/
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D noise_tex : hint_white;
uniform vec4 root_color : hint_color = vec4( 1.0, 0.75, 0.3, 1.0 );
uniform vec4 tip_color : hint_color = vec4( 1.0, 0.03, 0.001, 1.0 );

uniform float fire_alpha : hint_range( 0.0, 1.0 ) = 1.0;
uniform float fire_speed = 1.0;
uniform float fire_aperture : hint_range( 0.0, 3.0 ) = 0.22;

/*
	noise_texを使わないパターン

float random( vec2 pos )
{ 
	return fract(sin(dot(pos, vec2(12.9898,78.233))) * 43758.5453);
}

float value_noise( vec2 pos )
{
	vec2 p = floor( pos );
	vec2 f = fract( pos );

	float v00 = random( p + vec2( 0.0, 0.0 ) );
	float v10 = random( p + vec2( 1.0, 0.0 ) );
	float v01 = random( p + vec2( 0.0, 1.0 ) );
	float v11 = random( p + vec2( 1.0, 1.0 ) );

	vec2 u = f * f * ( 3.0 - 2.0 * f );

	return mix( mix( v00, v10, u.x ), mix( v01, v11, u.x ), u.y );
}
*/

void fragment( )
{
	vec2 shifted_uv = UV + vec2( 0.0, TIME * fire_speed );
	/*float fire_noise = (
		value_noise( shifted_uv * 0.984864 ) * 20.0
	+	value_noise( shifted_uv * 2.543 ) * 10.0
	+	value_noise( shifted_uv * 9.543543 ) * 8.0
	+	value_noise( shifted_uv * 21.65436 ) * 5.0
	+	value_noise( shifted_uv * 42.0 ) * 2.0
	+	value_noise( shifted_uv * 87.135148 ) * 2.0
	+	value_noise( shifted_uv * 340.66534654 )
	) / 48.0;*/
	float fire_noise = texture( noise_tex, shifted_uv ).r;
	float noise = UV.y * ( ( ( UV.y + fire_aperture ) * fire_noise - fire_aperture ) * 75.0 );
	vec4 fire_color = mix( tip_color, root_color, noise * 0.05 );

	COLOR = vec4( fire_color.rgb, clamp( noise, 0.0, 1.0 ) * fire_alpha );
}
