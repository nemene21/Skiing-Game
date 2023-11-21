shader_type canvas_item;

uniform vec2 sway_force = vec2(1, 1);

void vertex() {
	float offset = VERTEX.x + VERTEX.y;
	vec2 wave = vec2(sin(TIME * 2.0 + offset), cos(TIME * 3.0 + offset));
	VERTEX += sway_force * wave;
}