extends Node2D

var panning := false
var zoom := 1.0
var _zoom_rate := 1.05 

export var zoom_min := 0.02
export var zoom_max := 1000

var gtime = 0.0

onready var cam_transform := Transform2D()
# https://godotengine.org/qa/25983/camera2d-zoom-position-towards-the-mouse
# https://docs.godotengine.org/en/stable/classes/class_transform2d.html#class-transform2d-method-scaled
# https://docs.godotengine.org/en/stable/tutorials/math/matrices_and_transforms.html


var zoom_centre := Vector2()
var zoom_centre_c0 := Vector2()


func _ready() -> void:
	cam_transform.origin = $display.transform.origin


func _input(event):
	if event.is_action("ui_reset_camera") and event.is_pressed() and not event.is_echo():
		reset_camera()
	
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
			#$TextureRect.set_position( $TextureRect.get_position() + event.relative )
			cam_transform.origin += event.relative
			#print("panning %s"%event.relative)


func zoom_at_point(zoom_change, point):
	var c0 = cam_transform.origin #global_position # camera position
	var v0 = get_viewport().size # vieport size
	print("viewport size %s"%v0)
	var c1 # next camera position
	var z0 = self.zoom # current zoom value
	var z1 = z0 * zoom_change # next zoom value

	#c1 = c0 + (-0.5*v0 + point)*(z0 - z1)
	c1 = c0 + (-0.5*v0 + point) * (z0 - z1)
	
	self.zoom = clamp(z1, zoom_min, zoom_max)
	cam_transform.origin = c1
	cam_transform.x.x = self.zoom
	cam_transform.y.y = self.zoom
	
	zoom_centre = c1
	zoom_centre_c0 = c0


func _draw() -> void:
	draw_circle(zoom_centre, 20, Color(1.0,0.0,0.0,0.25))
	draw_circle(zoom_centre_c0, 10, Color(0.0,1.0,0.0,0.25))


# warning-ignore:unused_argument
func _process(delta: float) -> void:
	$display.transform = cam_transform
	update()

func reset_camera() -> void:
	cam_transform.x = Vector2.RIGHT
	cam_transform.y = Vector2.UP
	cam_transform.origin = Vector2.ZERO
	self.zoom = 1.0
