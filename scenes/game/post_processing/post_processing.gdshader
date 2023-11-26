shader_type canvas_item;

uniform sampler2D SCREEN: hint_screen_texture, filter_linear_mipmap;

uniform float saturation = 1.0;
uniform float brightness = 1.0;
uniform float bloom_strength = .0;
uniform float bloom_exponent = 1.0;
uniform float bloom_blur = .0;

void fragment() {
	vec3 pixel = texture(SCREEN, SCREEN_UV).rgb;
	vec3 bloom = textureLod(SCREEN, SCREEN_UV, bloom_blur).rgb;
	
	bloom = pow(bloom, vec3(bloom_exponent, bloom_exponent, bloom_exponent));
	pixel += bloom * bloom_strength;
	
	float grayscale = (pixel.r + pixel.g + pixel.b) * 0.3333; 
	
	pixel = mix(vec3(grayscale, grayscale, grayscale), pixel.rgb, saturation);
	pixel *= brightness;
	
	COLOR = vec4(pixel, 1.0);
}
