shader_type canvas_item;

uniform vec2 offset;
uniform sampler2D noise: repeat_enable;

void fragment() {
	float noise_value = texture(noise, UV + offset).r;
	COLOR = texture(TEXTURE, vec2(UV.y * (noise_value*.5 + .5), .0));
}
