shader_type canvas_item;
render_mode unshaded;

// display_mode:
// 0 = rgb
// 1 = alpha
uniform int display_mode : hint_range(0, 1);


void fragment(){
	vec4 t = texture(TEXTURE, UV); 
	switch( display_mode )
	{
		case 0:
			COLOR = t;
			break;
		case 1:
			COLOR = vec4(t.a, t.a, t.a, 1.0);
			break;
		default:
			COLOR = t;
			break;
	}
}

