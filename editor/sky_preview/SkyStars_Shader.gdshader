shader_type spatial;
render_mode blend_mix, unshaded;

uniform sampler2D texture_albedo : source_color, repeat_enable, filter_nearest;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float opacity = 1.0f;
uniform mat3 tex_matrix = mat3(1.0);

varying float pos_influence;

void vertex() {
	pos_influence = (VERTEX.y + 0.05f) * 16.0f;
	UV = vec2(UV.x * tex_matrix[0][0] + UV.y * tex_matrix[0][1] + tex_matrix[0][2], UV.x * tex_matrix[1][0] + UV.y * tex_matrix[1][1] + tex_matrix[1][2]);
}

void fragment() {
	vec4 stars_color = texture(texture_albedo, UV);
	stars_color.rgb = stars_color.rgb * opacity;
	stars_color.rgb = stars_color.rgb * pos_influence;
	stars_color.a = 1.0f;
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	vec4 inv_screen_color = 1.0f - screen_color;
	// this is actually an additive blend,
	// but I couldn't find a good way to replicate D3DRS_DESTBLEND equal to D3DBLEND_INVDESTCOLOR using blend_add
	// http://www.directxtutorial.com/Lesson.aspx?lessonid=9-4-10 scroll down to "Set the Source and Destination Factors"
	// https://learn.microsoft.com/en-us/windows/win32/direct3d9/alpha-texture-blending is the really basic formula for the blending
	vec4 color = min(stars_color+(screen_color * inv_screen_color),vec4(1.0));
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
