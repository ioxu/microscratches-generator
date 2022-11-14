extends Node

export(NodePath) onready var viewport = get_node( viewport )
export(NodePath) onready var display = get_node( display )
export(NodePath) onready var display_3d = get_node( display_3d )
export(NodePath) onready var cursor = get_node( cursor )
export(NodePath) onready var custom_draw = get_node( custom_draw )

var zoom_label : Label
var resolution_label : Label
var coords_label : Label
var pixel_red_label : Label
var pixel_green_label : Label
var pixel_blue_label : Label
var pixel_alpha_label : Label
var swatch_rect : ColorRect
var fps_label : Label
var colour_channel_displayed_label : Label
var generation_timing_label : Label

var layerListContainer : VBoxContainer

const COLOUR_CHANNEL_DISPLAY_MODES_NAMES = [
	"RGB",
	"ALPHA",
	"RED",
	"GREEN",
	"BLUE",
	"ROTATION",
	"UV"]

var resolution_menu_button : MenuButton
var RESOLUTIONS = [
	["half (512 x 512)", Vector2(512, 512)],
	["1k (1024 x 1024)", Vector2(1024, 1024)],
	["2k (2048 x 2048)", Vector2(2048, 2048)],
	["4k (4096 x 4096)", Vector2(4096, 4096)]
]
var seed_number : SpinBox

var vector_direction_menu_button : MenuButton
var VECTOR_DIRECTIONS = [
	"tangent",
	"bitangent"
]

var _texture_chooser_chosen_index : int

# viewmode:
# 0: 2d
# 1: 3d
var viewmode : int = 0


func _ready() -> void:
	print("[ui] find labels")
	zoom_label = self.find_node("zoom_label")
	resolution_label = self.find_node("resolution_label")
	resolution_label.text = "resolution : %s"%viewport.get_size()
	coords_label = self.find_node("coords_label")

	colour_channel_displayed_label = self.find_node("colour_channel_displayed_label")
	pixel_red_label = self.find_node("pixelvalues_red_label")
	pixel_green_label = self.find_node("pixelvalues_green_label")
	pixel_blue_label = self.find_node("pixelvalues_blue_label")
	pixel_alpha_label = self.find_node("pixelvalues_alpha_label")

	swatch_rect = self.find_node("swatch_rect")

	fps_label = self.find_node("fps_label")

	# control panel
	resolution_menu_button = self.find_node("resolution_menu_button")
	var resolution_menu_button_popup = resolution_menu_button.get_popup()
	resolution_menu_button_popup.connect("id_pressed", self, "_on_resolution_menu_button_item_pressed")

	seed_number = self.find_node("seed")

	generation_timing_label = self.find_node("generation_timing_label")
	
	vector_direction_menu_button = self.find_node("vector_direction_MenuButton")
	var vector_direction_menu_button_popup = vector_direction_menu_button.get_popup()
	vector_direction_menu_button_popup.connect("id_pressed", self, "_on_vector_direction_menu_button_item_pressed")

	# state
	Global.resolution = RESOLUTIONS[1][1] # TODO : hardcoded
	Global.vector_direction = VECTOR_DIRECTIONS[VECTOR_DIRECTIONS.find(vector_direction_menu_button.get_text())]


func _process(_delta: float) -> void:
	fps_label.text = "%s fps"%Engine.get_frames_per_second()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_2d_to_3d_view_toggle"):
		# see if there is a control that currently owns focus:
		# (a line edit may have focus for editing, inwhich case don't consider
		# the action "ui_2d_to_3d_view_toggle")
		var focused_node = self.find_node("Control").get_focus_owner()
		if focused_node == null:
			if viewmode == 0:
				viewmode = 1
			elif viewmode == 1:
				viewmode = 0
			print("[ui][2d/3d toggle] %s"%viewmode)
			
			if viewmode == 0:
				display.visible = true
				display_3d.visible = false
			elif viewmode == 1:
				display.visible = false
				display_3d.visible = true


func _on_display_zoom_changed(new_zoom) -> void:
	zoom_label.text = "zoom : %0.2f"%new_zoom


func _on_Viewport_size_changed() -> void:
	resolution_label.text = "resolution : %s"%viewport.get_size()


func _on_display_mouse_coords_in_viewport_changed(new_coords) -> void:
	coords_label.text = "x %s  y %s"%[ new_coords.x, new_coords.y ]


func _on_display_colour_under_mouse_changed(new_colour) -> void:
	pixel_red_label.text = "%0.4f"%new_colour.r
	pixel_green_label.text = "%0.4f"%new_colour.g
	pixel_blue_label.text = "%0.4f"%new_colour.b
	pixel_alpha_label.text = "%0.4f"%new_colour.a
	swatch_rect.color = new_colour


func _on_Control_mouse_entered() -> void:
	Input.set_mouse_mode( Input.MOUSE_MODE_HIDDEN )
	cursor.set_visible(true)
	custom_draw.draw_vector_debug = true


func _on_Control_mouse_exited() -> void:
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	cursor.set_visible(false)
	custom_draw.draw_vector_debug = false


func _on_display_colour_channel_display_mode_changed(new_mode) -> void:
	colour_channel_displayed_label.text = COLOUR_CHANNEL_DISPLAY_MODES_NAMES[new_mode]


# control panel ----------------------------------------------------------------
func _on_resolution_menu_button_item_pressed( id_pressed ) -> void:
	print("[ui][control panel] resolution selected: %s"%RESOLUTIONS[id_pressed][0])
	resolution_menu_button.set_text(RESOLUTIONS[id_pressed][0])
	Global.resolution = RESOLUTIONS[id_pressed][1]
	(viewport as Viewport).size = Global.resolution
	viewport_step_update()


func _on_vector_direction_menu_button_item_pressed( id_pressed ) -> void:
	print("[ui][control panel] vector direction selected: %s"%VECTOR_DIRECTIONS[id_pressed])
	vector_direction_menu_button.set_text( VECTOR_DIRECTIONS[id_pressed] )
	Global.vector_direction = VECTOR_DIRECTIONS[id_pressed]


func viewport_step_update() -> void:
	# chain updates down into image datas
	# this order, and frame-waits, are important
	print("[ui][viewport] viewport step update")
	viewport.set_update_mode(Viewport.UPDATE_ALWAYS)
	yield(get_tree(), "idle_frame")
	viewport.set_update_mode(Viewport.UPDATE_ONCE)
	yield(get_tree(), "idle_frame")
	
	#------------------------------
	# what # TODO: what.
	# https://github.com/godotengine/godot/issues/51241
	OS.window_size.y += 1
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	OS.window_size.y -= 1
	#------------------------------
	display.update_image(true)


func _on_generate_button_pressed() -> void:
	# resolution

	Util.set_rng_seed( int(seed_number.get_value()) )
	Global.report()

	var time_now = OS.get_system_time_msecs() 
	
	Util.set_rng_seed( int(seed_number.get_value()) )

	for l in $layerManager.layers:
		l = (l as Layer)
		if l.is_generator():
			l.generate()

	viewport_step_update()
	generation_timing_label.text =  milliseconds_to_pretty_time( OS.get_system_time_msecs()  - time_now )


func _on_file_export_FileDialog_about_to_show() -> void:
	display.accept_input = false


func _on_file_export_FileDialog_popup_hide() -> void:
	display.accept_input = true


func milliseconds_to_pretty_time( ms : float ) -> String :
	var milliseconds = fmod(ms, 1000)
	ms /= 1000
	var minutes = ms / 60
	var seconds = fmod(ms, 60)
	return "%02d' %02d\" %03d" % [minutes, seconds, milliseconds]
	#return str(ms)


# layers -----------------------------------------------------------------------
func _on_addLayer_TextureButton_pressed() -> void:
	print("[ui][layers] add layer")
	var paths = ["res://texture_scenes/"]
	print("[ui][layers]    finding texture scenes (%s)"%paths)
	var scene_paths = Util.get_texture_scenes_list(paths)
	
	var pop = PopupMenu.new()
	var ui = get_node("/root/main/ui")
	ui.add_child(pop)
	pop.set_owner(ui)
	pop.connect("index_pressed", self, "_on_textureLayerChooser_index_pressed")
	for s in scene_paths:
		pop.add_item(s)
	pop.set_exclusive(true)
	pop.popup_centered()
	
	# this WHOLE function's guts needs to be inline because of this yield
	yield(pop, "popup_hide")

	var chosen_path = scene_paths[self._texture_chooser_chosen_index]
	print("[ui][layers] chosen: %s"%chosen_path)
	pop.queue_free()

	var scene = load(chosen_path)
	print("[ui][layers][texture scene] %s"%scene)
	print("[ui][layers][texture scene] %s"%scene.get_name())

	var layer = $layerManager.add_layer( scene.instance() )
	layer.add_meta( "scene", chosen_path )
	viewport_step_update()


func _on_textureLayerChooser_index_pressed(index : int) -> void:
	print("[ui][layers][_on_textureLayerChooser_index_pressed] %s"%index)
	self._texture_chooser_chosen_index = index


func _on_removeLayer_TextureButton_pressed() -> void:
	print("[ui][layers] remove layer")
	$layerManager.remove_selected_layers()
	viewport_step_update()
	

func _on_moveLayerUp_TextureButton_pressed() -> void:
	print("[ui][layers] move layer up")
	$layerManager.move_selected_layers_up()
	viewport_step_update()


func _on_moveLayerDown_TextureButton_pressed() -> void:
	print("[ui][layers] move layer down")
	$layerManager.move_selected_layers_down()
	viewport_step_update()
	

func _on_layer_visibility_toggle(layer : Layer, pressed : bool) -> void:
	print("[ui][layers] layer \"%s\" visiblity %s"%[ layer, pressed ])
	viewport_step_update()


func _on_layersInformation_TextureButton_pressed() -> void:
	$layerManager.print_layers()
