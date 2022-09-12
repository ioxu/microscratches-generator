extends Node2D

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
	p.add_separator("textures")

	var dir = Directory.new()
	var fnames = []
	var tex_dir = "res://textures/"
	dir.open(tex_dir)
	dir.list_dir_begin()
	var f = dir.get_next()
	while f!= "":
		if dir.current_is_dir():
			print("  found directory %s"%f)
		else:
			print("  found file %s"%f)
			if not f.ends_with(".import"):
				fnames.append(f)
		f = dir.get_next()
		
	dir.list_dir_end()

	for fn in fnames:
		p.add_item( fn )

	p.add_separator()
	p.add_item("Load .. ", 200)
	p.add_item("Export .. ", 300)
	p.add_separator()
	p.add_item("Quit", 400)

	# warning-ignore:return_value_discarded
	p.connect("id_pressed", self, "on_id_pressed", [menu_id])

	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


	#$scene/ViewportContainer/Viewport.render_target_update_mode = Viewport.UPDATE_ONCE

func _input(event):
	if event.is_action("ui_cancel") and event.is_pressed() and not event.is_echo():
		self.quit()

	if event is InputEventMouseMotion:
		$cursor.set_position( event.position )

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				picked_window_position = event.position
				print("pick : window position: %s"%[picked_window_position])

			else:
				print("left mouse up")
				picked_window_position = null

	if event.is_action_pressed("ui_fullscreen"):
		go_fullscreen()
		get_tree().set_input_as_handled()


func on_id_pressed( id, _ignored ) -> void:
	
	# Quit
	if id == 400:
		self.quit()

	# Export
	# https://godotengine.org/qa/13967/need-to-generate-and-save-textures-to-disk
	# https://docs.godotengine.org/en/stable/classes/class_file.html
	# https://godotforums.org/d/26767-16bit-vertex-displacement/9
	if id == 300:
		print("exporting texture ..")
		var tex_data = $display/display.texture.get_data()
		var image : Image = tex_data
		# warning-ignore:return_value_discarded
		image.save_png( "exports/export.png" )
		image.lock()
		print("image data %s"%image.data)
		var width = image.data["width"]
		var height = image.data["height"]
		print("w %s h %s"%[width, height])
		var image_exr : Image = Image.new()
		image_exr.create( width, height, false, Image.FORMAT_RGBAH )
		image_exr.lock()
		for x in range(width):
			for y in range(height):
				var c = image.get_pixel( x, y )
				# A R G B
				image_exr.set_pixel( x, y, Color( c.g, c.b, c.a, c.r ))
		image_exr.unlock()
		image.unlock()
		print("image_exr data %s"%image_exr.data)
		# warning-ignore:return_value_discarded
		image_exr.save_exr( "exports/export.exr", false )


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
