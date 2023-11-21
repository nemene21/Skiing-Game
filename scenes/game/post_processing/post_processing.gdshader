shader_type canvas_item;

uniform sampler2D SCREEN: hint_screen_texture;

void fragment() {

	vec4 pixel = texture(SCREEN, SCREEN_UV);
	COLOR = pixel;
}
