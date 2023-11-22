shader_type canvas_item;

uniform sampler2D noise;

const vec2 MID = vec2(.5, .5);

void fragment() {
	float dist = distance(UV, MID);
	COLOR.a = float(texture(noise, UV).r > dist * 2.0);
}
