extends Node2D

export(NodePath) onready var line = get_node( line )

var ca = []
var colours


func _ready() -> void:
	if self.visible:
		# TODO: a better algo would be to take a weighted difference of current point and two points either side divided by distance to current point
		var ni = 0
		for i in range(line.get_point_count()):
			if i+1 == line.get_point_count():
				ni = i
			else:
				ni = i + 1

			var v1 = line.get_point_position( i ) - line.get_point_position( ni )
			v1 = v1.normalized() * Vector2(1.0, -1.0)
			ca.append( vec2_to_encoded_colour( v1 ) )

		colours = PoolColorArray( ca )
		self.set_position( line.get_position() )
		line.set_visible(false)


func _draw() -> void:
	if self.visible:
		draw_polyline_colors( line.get_points(), colours, 10.0, false)


func vec2_to_encoded_colour( vec : Vector2 ) -> Color:
	var ev = ( vec + Vector2(1.0, 1.0) ) / Vector2(2.0, 2.0)
	return Color(ev.x, ev.y, 0.0, 1.0)

