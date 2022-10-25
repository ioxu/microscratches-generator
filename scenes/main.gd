extends Node2D

# export hints
# https://godotengine.org/qa/13967/need-to-generate-and-save-textures-to-disk
# https://docs.godotengine.org/en/stable/classes/class_file.html
# https://godotforums.org/d/26767-16bit-vertex-displacement/9

# anisotropic reflection
# https://www.youtube.com/watch?v=M6tY53LlzSo&ab_channel=Christopher3D

export(NodePath) onready var layer_manager = (get_node( layer_manager ) as LayerManager)

onready var file_menu_button : MenuButton

var picked_window_position
var menu_id := -1

var BORDERLESS_FULLSCREEN = false
var minimum_size : Vector2 = Vector2(1024,600)
var window_position := Vector2.ZERO
var fullscreen : = false
signal fullscreen(value)


func _ready() -> void:
	var _vi = Engine.get_version_info()
	assert(_vi.major == 3 and _vi.minor == 2, "This project must only be developed in engine versions 3.2.3 and earlier")
	
	
	file_menu_button = self.find_node("file_menu_button")
	var p := file_menu_button.get_popup()
	p.rect_min_size = Vector2(200, 0)

	p.add_item("Load .. ", 200)
	p.add_item("Export .. ", 300)
	p.add_separator()
	p.add_item("Quit", 400)

	# warning-ignore:return_value_discarded
	p.connect("id_pressed", self, "on_id_pressed", [menu_id])

	pprint("create default texture layer:")
	var default_texture_layer_resource : PackedScene = load("res://texture_scenes/test_lines.tscn")
	var default_texture_layer_instance = default_texture_layer_resource.instance()
	pprint("   %s (%s)"%[default_texture_layer_instance, default_texture_layer_instance.get_name()])
	layer_manager.add_layer( default_texture_layer_instance )
	

func _input(event):
	if event.is_action("ui_cancel") and event.is_pressed() and not event.is_echo():
		self.quit()

	if event is InputEventMouseMotion:
		$cursor.set_position( event.position )

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				picked_window_position = event.position
				#print("pick : window position: %s"%[picked_window_position])

			else:
				#print("left mouse up")
				picked_window_position = null

	if event.is_action_pressed("ui_fullscreen"):
		go_fullscreen()
		get_tree().set_input_as_handled()


func on_id_pressed( id, _ignored ) -> void:
	
	# Quit
	if id == 400:
		self.quit()

	# Export
	if id == 300:
		print("[main] exporting texture ..")

		var fd = $ui.find_node("file_export_FileDialog")
		fd.popup_centered()


# export
func _on_file_export_FileDialog_file_selected(path: String) -> void:
	Util.export_texture( $display/display.texture, path )


func quit()->void:
	print(".. quitting")
	get_tree().quit()


func go_fullscreen():
	if not BORDERLESS_FULLSCREEN:
		OS.window_fullscreen = !OS.window_fullscreen
		fullscreen = !fullscreen
		if not OS.window_fullscreen:
			OS.set_window_size(minimum_size)
			OS.set_borderless_window(false)
		else:
			OS.set_window_position(window_position)
	else:
		fullscreen = !fullscreen
		if fullscreen:
			OS.set_window_size(OS.get_screen_size())
			OS.set_borderless_window(true)
			OS.set_window_position(Vector2(0.0, 0.0))
		else:
			OS.set_borderless_window(false)
			OS.set_window_size(minimum_size)
			OS.set_window_position(window_position)
	emit_signal("fullscreen", fullscreen)


func pprint(thing) -> void:
	print("[main] %s"%str(thing))
