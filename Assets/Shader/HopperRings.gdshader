// NOTE: Shader automatically converted from Godot Engine 3.5.1.stable's SpatialMaterial.

shader_type spatial;
render_mode unshaded,async_visible,blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform float time_offset;
uniform float alpha;

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
	float width = .003;
	float border = .009;
	
	float t = -TIME * .45 + time_offset;
	
	ALBEDO = albedo.rgb;
	float y = mod(t, 1.0) - .2;
	float ring_mask = clamp_map_pow(abs(UV.y - y), width, width + border, 1.0, 0.0, 1.0);
	ALPHA = ring_mask * float(UV.y < .5) * clamp_map_pow(UV.y, .05, .2, 0.0, 1.0, 2.0) * .6 * alpha;
}
