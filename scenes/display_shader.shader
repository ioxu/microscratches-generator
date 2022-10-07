shader_type canvas_item;
render_mode unshaded;

// display_mode:
// 0 = rgb
// 1 = alpha
// 2 = red
// 3 = green
// 4 = blue
// 5 = colour-to-rotation (atan)
// 6 = UV mode (red and green channels only)
uniform int display_mode : hint_range(0, 6);

const float PI = 3.1415926535897932384626433832795;

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
		case 5: // rotation (atan)
			float v;
			t = vec4( vec2(2.0, 2.0) * (vec2(t.r, t.g) - vec2(0.5, 0.5)), t.b, t.a );
			v =  ((atan( t.g, t.r )  / PI ) + 1.0 ) * 0.5   ; // for encoded colour vectors (0.0 to 1.0)
			COLOR = vec4(v, v, v, 1.0);
			break;
		case 6: // UV (red and green channels only)
			COLOR = vec4( t.r, t.g, 0.0, 1.0  );
			break;

		default:
			COLOR = t;
			break;
	}
}

