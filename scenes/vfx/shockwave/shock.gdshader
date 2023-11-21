shader_type canvas_item;

uniform float anim = .0;
uniform vec4 color: source_color;

const vec4 BLANK = vec4(0, 0, 0, 0);

void fragment() {
	float dist = distance(vec2(.5, .5), UV);
	float mask = float(dist < .5 && dist > anim*.5);
	COLOR *= mix(BLANK, color, mask);
}
