// NOTE: Shader automatically converted from Godot Engine 3.5.1.stable's SpatialMaterial.

shader_type spatial;
render_mode unshaded, async_visible,blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D noise: hint_albedo;

uniform float speed : hint_range(0.0, 1.0);
uniform float activation : hint_range(0.0, 1.0);

float clamp_and_map(float value, float istart, float istop, float ostart, float ostop) {
    value = clamp(value, istart, istop);
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

float clamp_map_pow(float value, float istart, float istop, float ostart, float ostop, float power) {
	float c1 = clamp_and_map(value, istart, istop, 0.0, 1.0);
	c1 = pow(c1, power);
	return clamp_and_map(c1, 0.0 , 1.0, ostart, ostop);
}

float inv(float x) {
	return 1.0 - x;
}

void fragment() {
	vec2 timed_uv = vec2(UV.x * .1 + mod(TIME * .9 * speed, 1.0), UV.y);
	ALBEDO = albedo.rgb;
	float noise_mask = texture(noise,timed_uv).r + clamp_map_pow(abs(UV.y - .5), 0.0, .2, .9, 0.0, .5);
	noise_mask = clamp_map_pow(noise_mask, inv(activation), 1.5, 0.0, 1.0, 1.0);
	float y_mask = clamp_map_pow(abs(UV.y - .5), 0.2, .35, 1.0, 0.0, .5);
	float all_mask = clamp_map_pow(activation, 0.0, .1, 0.0, 1.0, 1.0);
	ALPHA = noise_mask * y_mask * all_mask;
}
