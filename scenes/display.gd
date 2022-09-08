extends Node2D
# controls the "camera" transform, and display of the RTT

var panning := false
var zoom := 1.0
var _zoom_rate := 1.05 #1.05 

export(NodePath) onready var viewport = get_node( viewport )

var viewport_image : Image

export var zoom_min := 0.1
export var zoom_max := 30.0

var gtime = 0.0

onready var cam_transform := Transform2D()
# https://godotengine.org/qa/25983/camera2d-zoom-position-towards-the-mouse
# https://docs.godotengine.org/en/stable/classes/class_transform2d.html#class-transform2d-method-scaled
# https://docs.godotengine.org/en/stable/tutorials/math/matrices_and_transforms.html

var coord_in_viewport : Vector2
var colour_under_cursor : Color

signal zoom_changed(new_zoom)
signal mouse_coords_in_viewport_changed(new_coords)
signal colour_under_mouse_changed( new_colour )


func _ready() -> void:
	cam_transform.origin = $display.transform.origin
	yield(get_tree().create_timer(.05), "timeout")
	emit_signal("zoom_changed", self.zoom)

	print("[display] viewport dimensions %s"%viewport.get_size())


func _input(event):
	if event.is_action("ui_reset_camera") and event.is_pressed() and not event.is_echo():
		reset_camera()
	
	if event is InputEventMouseMotion:
		self.coord_in_viewport = window_to_viewport(event.position)
		update_image()
		var _vs = viewport.get_size()
		if self.coord_in_viewport.x < _vs.x and self.coord_in_viewport.x > 0 and\
			self.coord_in_viewport.y < _vs.y and self.coord_in_viewport.y > 0:
			self.viewport_image.lock()
			self.colour_under_cursor = viewport_image.get_pixelv( self.coord_in_viewport )
			self.viewport_image.unlock()
		emit_signal( "mouse_coords_in_viewport_changed" , self.coord_in_viewport )
		emit_signal( "colour_under_mouse_changed", self.colour_under_cursor )

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE:
			if event.pressed:
				panning = true
			else:
				panning = false

		if event.button_index == BUTTON_WHEEL_UP:
			zoom_at_point(_zoom_rate, event.position)

		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom_at_point(1/_zoom_rate, event.position)

	if event is InputEventMouseMotion:
		if panning:
			cam_transform.origin += event.relative
			#print("panning %s"%event.relative)


func zoom_at_point(zoom_change, point):

	var zz = zoom_change #2 - zoom_change
	self.zoom = self.zoom * zz
	if self.zoom < zoom_min or self.zoom > zoom_max:
		zz = 1.0


	var offset_t = Transform2D().translated( -point)
	var scaled_t = Transform2D().scaled( Vector2.ONE * zz ) #Vector2(zz, zz) )
	var reoffset_t = Transform2D().translated( point)

	cam_transform = reoffset_t * scaled_t * offset_t * cam_transform

	emit_signal("zoom_changed", self.zoom)

	self.zoom = clamp(self.zoom, zoom_min, zoom_max)


func _draw() -> void:
	var vp_size = viewport.get_size()
	var cc = Color(0.984314, 0.223529, 0.901961, 0.607843)
	var br = cam_transform.xform(Vector2(vp_size.x/2, -vp_size.y/2))
	var tr = cam_transform.xform(Vector2(vp_size.x/2, vp_size.y/2))
	var tl = cam_transform.xform(Vector2(-vp_size.x/2, vp_size.y/2))
	var bl = cam_transform.xform(Vector2(-vp_size.x/2, -vp_size.y/2))
	draw_line( tr, br, cc, 3)
	draw_line( tl, tr, cc, 3)
	draw_line( tl, bl, cc, 3)
	draw_line( bl, br, cc, 3)


# warning-ignore:unused_argument
func _process(delta: float) -> void:
	$display.transform = cam_transform
	update()


func reset_camera() -> void:
	cam_transform.x = Vector2.RIGHT
	cam_transform.y = Vector2.DOWN
	cam_transform.origin = get_viewport().size * 0.5
	self.zoom = 1.0


func window_to_viewport( coords : Vector2 ) -> Vector2:
	var _ai = cam_transform.affine_inverse()
	var _vs = viewport.get_size()
	var new_coords = (_vs / 2.0) + _ai * coords#event.position
	new_coords = new_coords.floor()
	return Vector2( clamp(new_coords.x, 0, _vs.x), clamp(new_coords.y, 0, _vs.y) )


func update_image() -> void:
	viewport_image = $display.texture.get_data()
