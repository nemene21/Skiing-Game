shader_type canvas_item;

uniform sampler2D SCREEN: hint_screen_texture, filter_linear_mipmap;

uniform float saturation = 1.0;
uniform float brightness = 1.0;
uniform float vignette_size = .0;
uniform float vignette_exponent = 1.0;
uniform vec4 vignette_color: source_color;

const vec2 MID = vec2(.5, .5);

void fragment() {
	float dist = distance(MID, UV) * 2.0;
	
	vec3 pixel = texture(SCREEN, SCREEN_UV).rgb;
	
	float grayscale = (pixel.r + pixel.g + pixel.b) * 0.3333; 
	
	pixel = mix(vec3(grayscale, grayscale, grayscale), pixel.rgb, saturation);
	pixel *= brightness;
	
	float vignette = pow((1.0 - vignette_size * 2.0) - dist, vignette_exponent);
	vignette = max(min(vignette, 1.0), .0);
	pixel *= vignette;
	
	COLOR = vec4(pixel, 1.0);
}
