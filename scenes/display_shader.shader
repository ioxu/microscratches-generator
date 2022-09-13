shader_type canvas_item;
render_mode unshaded;

// display_mode:
// 0 = rgb
// 1 = alpha
uniform int display_mode : hint_range(0, 4);


void fragment(){
	vec4 t = texture(TEXTURE, UV); 
	switch( display_mode )
	{
		case 0: // rgb
			COLOR = t;
			break;
		case 1: // alpha
			COLOR = vec4(t.a, t.a, t.a, 1.0);
			break;
		case 2: // red
			COLOR = vec4(t.r, t.r, t.r, 1.0);
			break;
		case 3: // green
			COLOR = vec4(t.g, t.g, t.g, 1.0);
			break;
		case 4: // blue
			COLOR = vec4(t.b, t.b, t.b, 1.0);
			break;

		default:
			COLOR = t;
			break;
	}
}

