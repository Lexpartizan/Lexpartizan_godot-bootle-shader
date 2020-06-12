shader_type spatial;
render_mode cull_disabled,shadows_disabled;
uniform vec2 coeff; // Coefficients of the linear function for the surface.
uniform float vel; // Rate of change of the coefficients.
uniform float fill_amount;
uniform vec2 size;
uniform float glass_thickness;
uniform float scale;
uniform float wave_intensity = 0.05f;
uniform vec4 liquid_color : hint_color;
uniform sampler2D waves_noise;
uniform sampler2D bubbles_tex;
varying lowp vec3 pos;
varying lowp float rot_scale;
varying lowp vec3 world_vec_up_to_model;
varying lowp vec3 weights;
varying lowp float bubles_apha;
void vertex() {
	/* Move vertices inwards to simulate glass thickness. */
	VERTEX -= glass_thickness * NORMAL;
	/* Position inside container rotated to world. */
	pos = mat3(WORLD_MATRIX)*VERTEX;
	/* Lerp between height and width depending on world orientation of z axis. */
	//rot_scale = mix(size.x, size.y, abs(dot(vec3(WORLD_MATRIX[0][1], WORLD_MATRIX[1][1], WORLD_MATRIX[2][1]), vec3(0.0f, 1.0f, 0.0f))));
	world_vec_up_to_model = vec3(0.0f, 1.0f, 0.0f)* mat3(WORLD_MATRIX);
	rot_scale = mix(size.x, size.y, abs(dot(world_vec_up_to_model, vec3(0.0f, 1.0f, 0.0f))));
	weights = mat3(WORLD_MATRIX)*NORMAL; weights*=weights;
}

void fragment() {
	/* Set liquid line to fill amount, add noise waves and incline. */
	lowp float wave_noise_1 = texture(waves_noise, (2.0*pos.xz + 0.5*TIME * vec2(1.0, 1.0))*scale).r;
	lowp float wave_noise_2 = texture(waves_noise, (2.0*pos.xz - 0.5*TIME * vec2(1.0, 1.0))*scale).g;
	lowp float wave = wave_intensity * length(coeff) * (wave_noise_1 - 0.5f + wave_noise_2 - 0.5f) + dot(pos.xz, coeff);
	wave *= smoothstep(0.05,0.25,fill_amount);
	lowp float liquid_line = (fill_amount*2.0-1.0+wave)*rot_scale;
	if (pos.y > liquid_line) discard;// Discard all vertices above the liquid line. */
	if (FRONT_FACING)
		{
			vec2 distortion = vec2(wave_noise_1,wave_noise_2)*0.01;
			lowp vec2 bubbles;
			bubbles.x = smoothstep(0.9,1.0,texture(bubbles_tex, scale*3.0*pos.yx+distortion - TIME * vec2(2.0f, 0.0f)).r);
			bubbles.y = smoothstep(0.9,1.0,texture(bubbles_tex, scale*3.0*pos.yz+distortion - TIME * vec2(2.0f, 0.0f)).r);
			bubbles*=weights.zx*1.0*vel;
			TRANSMISSION.z = bubbles.x+bubbles.y;
			float foam =smoothstep(liquid_line-0.1*scale*rot_scale, liquid_line,pos.y);
			vec3 normal_foam = mix (NORMAL,vec3(coeff.x,1.0,coeff.y),foam);
			vec3 color_foam = mix(liquid_color.xyz,vec3(1.0),foam);
			ALBEDO = mix(liquid_color.xyz,color_foam,vel);//+bubbles.a;
			NORMAL = mix(NORMAL,normal_foam,vel);
		}
	else
		{
		ALBEDO = mix(liquid_color.xyz,vec3(1.0),vel);
		NORMAL = vec3(coeff.x, 1.0f, coeff.y);
		}
}

void light() 
{
	// Liquid "glow" when held against light. 
	lowp float d = dot(-VIEW, LIGHT);
	lowp float dd = smoothstep(0.0,1.0,d);
	//dd+=1.0;
	dd*=dd;
	DIFFUSE_LIGHT = (dd -TRANSMISSION.z*d)*liquid_color.rgb;
}