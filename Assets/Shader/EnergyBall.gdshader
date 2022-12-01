// NOTE: Shader automatically converted from Godot Engine 3.5.1.stable's SpatialMaterial.

shader_type spatial;
render_mode async_visible,blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded,shadows_disabled;
uniform vec4 albedo : hint_color;
uniform vec4 albedo2 : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float alpha = 1.0;


float clamp_and_map(float value, float istart, float istop, float ostart, float ostop) {
    value = clamp(value, istart, istop);
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

float clamp_map_pow(float value, float istart, float istop, float ostart, float ostop, float power) {
	float c1 = clamp_and_map(value, istart, istop, 0.0, 1.0);
	c1 = pow(abs(c1), power);
	return clamp_and_map(c1, 0.0, 1.0, ostart, ostop);
}

float inv(float x) {
	return 1.0 - x;
}

void vertex() {
		MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],CAMERA_MATRIX[1],CAMERA_MATRIX[2],WORLD_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(WORLD_MATRIX[0].xyz), 0.0, 0.0, 0.0),vec4(0.0, length(WORLD_MATRIX[1].xyz), 0.0, 0.0),vec4(0.0, 0.0, length(WORLD_MATRIX[2].xyz), 0.0),vec4(0.0, 0.0, 0.0, 1.0));
}

void fragment() {
	vec2 base_uv = UV + vec2(TIME);
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	
	float middle_dist = distance(UV, vec2(.5));
	float ball_mask = clamp_map_pow(middle_dist, .3, .4, 1.0, 0.0, .2);
	
	ALBEDO = mix(albedo.rgb, albedo2.rgb, albedo_tex.r);
	ALPHA = clamp(albedo.a * albedo_tex.a * ball_mask * alpha, 0.0, 1.0);
}
