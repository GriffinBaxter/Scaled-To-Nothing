shader_type canvas_item;

uniform float thickness : hint_range(0.0, 1.0) = 0.25;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform vec3 colour : source_color = vec3(1.0, 1.0, 1.0);

const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1),
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
	float outline = 0.0;
	vec2 size = TEXTURE_PIXEL_SIZE * thickness;

	for (int i = 0; i < OFFSETS.length(); i++) {
		outline += texture(TEXTURE, UV + size * OFFSETS[i]).a;
	}
	outline = min(outline, 1.0);

	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, vec4(colour.r, colour.g, colour.b, alpha), outline - color.a);
}
