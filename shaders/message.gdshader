shader_type canvas_item;

void fragment() {
	if (COLOR.a < 0.8) discard;
	COLOR.a = 1.0;
}