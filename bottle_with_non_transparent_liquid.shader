shader_type spatial;
render_mode cull_disabled;
uniform lowp vec2 coeff;
uniform lowp vec4 liquid_color: hint_color;
uniform lowp float fill_amount;
//uniform lowp float foam_tint;
uniform lowp float rot_scale;
uniform lowp float glass_thickness;
uniform lowp sampler2D waves_noise;
uniform lowp sampler2D waves_normal;

varying lowp vec3 pos;
varying lowp float liquid_height;

void vertex() 
{
	VERTEX -= glass_thickness * NORMAL;
	pos = mat3(WORLD_MATRIX)*VERTEX;
	liquid_height = fill_amount + pos.x * coeff.x + pos.z * coeff.y;
}

void fragment() 
{
	float noise = texture(waves_noise, pos.xz + TIME).r;
	float wave_height = noise*1.5 * length(coeff)*(fill_amount+1.0)*0.5;
	if (pos.y > (liquid_height+wave_height)*rot_scale) discard;
	if (!FRONT_FACING) 
		{
		mat4 view_space_to_model_space_without_rotation = mat4(mat3(WORLD_MATRIX)) * inverse(WORLD_MATRIX) * CAMERA_MATRIX;
		vec4 view_orig = view_space_to_model_space_without_rotation * vec4(0.0f, 0.0f, 0.0f, 1.0f);
		vec4 view_vec = vec4(pos,1.0) - view_orig;
		float r = (fill_amount + dot(vec3(coeff.x, -1.0f, coeff.y), view_orig.xyz)) / (-dot(vec3(coeff.x, -1.0f, coeff.y), view_vec.xyz));
		vec2 surf_pos = (view_orig + r * view_vec).xz;
		NORMAL = texture(waves_normal,surf_pos*5.0+0.5).xyz*vec3 (length(coeff),0.0,length(coeff));
		ROUGHNESS = 0.4;
		//ALBEDO = texture(waves_normal,surf_pos*5.0).xyz;
		
		ALBEDO = mix (liquid_color.xyz,vec3(1.0),0.1);
		}
		else ALBEDO = liquid_color.xyz;
		//
		
		
}