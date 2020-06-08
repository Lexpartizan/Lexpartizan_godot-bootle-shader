shader_type spatial;
render_mode cull_disabled;
uniform lowp vec2 coeff;
uniform lowp vec4 liquid_color: hint_color;
uniform lowp float rot_scale;
uniform lowp float fill_amount;
uniform lowp float glass_thickness;
uniform lowp sampler2D waves_noise;
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
	lowp float noise = texture(waves_noise, (pos.xz + TIME)).r;
	lowp float wave_height = noise*2.0* length(coeff)*(fill_amount+1.0)*0.5;
	if (pos.y > (liquid_height+wave_height)*rot_scale) discard;
	NORMAL = vec3(0.0,1.0,0.0);
	ALBEDO = mix (texture(SCREEN_TEXTURE,SCREEN_UV - coeff*0.1 - (noise)*0.01,liquid_color.a*2.0).rgb * (1.0 - liquid_color.a),liquid_color.xyz,liquid_color.a);
}