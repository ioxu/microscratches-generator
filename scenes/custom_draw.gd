extends Node2D


var vector_debug : Vector2
export var vector_debug_length := 40.0
export var draw_vector_debug := true setget _set_draw_vector_debug

var mouse_location : Vector2


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_location = event.position


func _on_display_colour_under_mouse_changed(new_colour) -> void:
	if draw_vector_debug:
		vector_debug = Vector2(new_colour.r, new_colour.g)
		update()


func _set_draw_vector_debug( new_value ) -> void:
	draw_vector_debug = new_value
	update()


func _draw() -> void:
	if draw_vector_debug:
		var _to = vector2_to_signed_vector2( vector_debug ).normalized() * vector_debug_length
		draw_polyline_colors( PoolVector2Array([mouse_location, mouse_location + _to]),\
			PoolColorArray([Color(0.25,0.25,0.25,0.5), Color(0.25,0.25,0.25,0.15)] ), 5 )
		draw_polyline_colors( PoolVector2Array([mouse_location, mouse_location + _to]),\
			PoolColorArray([Color.white, Color(1.0,1.0,1.0,0.25)] ), 2 )


func vector2_to_signed_vector2( vec : Vector2 ) -> Vector2:
	return (vec - Vector2(0.5, 0.5) ) * Vector2(2.0, -2.0)


