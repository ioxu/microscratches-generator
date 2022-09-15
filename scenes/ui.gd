extends Node

export(NodePath) onready var viewport = get_node( viewport )
export(NodePath) onready var display = get_node( display )
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

const COLOUR_CHANNEL_DISPLAY_MODES_NAMES = ["RGB", "ALPHA", "RED", "GREEN", "BLUE", "ROTATION"]

var resolution_menu_button : MenuButton
var RESOLUTIONS = [
	["half (512 x 512)", Vector2(512, 512)],
	["1k (1024 x 1024)", Vector2(1024, 1024)],
	["2k (2048 x 2048)", Vector2(2048, 2048)],
	["4k (4096 x 4096)", Vector2(4096, 4096)]
]
var seed_number : SpinBox


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


func _process(_delta: float) -> void:
	fps_label.text = "%s fps"%Engine.get_frames_per_second()


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
	#print("_on_Control_mouse_entered")
	Input.set_mouse_mode( Input.MOUSE_MODE_HIDDEN )
	cursor.set_visible(true)
	custom_draw.draw_vector_debug = true


func _on_Control_mouse_exited() -> void:
	#print("_on_Control_mouse_exited")
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	cursor.set_visible(false)
	custom_draw.draw_vector_debug = false


func _on_display_colour_channel_display_mode_changed(new_mode) -> void:
	colour_channel_displayed_label.text = COLOUR_CHANNEL_DISPLAY_MODES_NAMES[new_mode]


# control panel ----------------------------------------------------------------
func _on_resolution_menu_button_item_pressed( id_pressed ) -> void:
	print("[ui][control panel] resolution selected: %s"%RESOLUTIONS[id_pressed][0])
	resolution_menu_button.set_text(RESOLUTIONS[id_pressed][0])


func _on_generate_button_pressed() -> void:
	
	################################
	Util.set_rng_seed( int(seed_number.get_value()) )
	var test_lines = viewport.find_node("test_lines")
	test_lines.generate_lines()

	# chain updates down into image datas
	# this order, and frame-waits, are important
	viewport.set_update_mode(Viewport.UPDATE_ALWAYS)
	yield(get_tree(), "idle_frame")
	viewport.set_update_mode(Viewport.UPDATE_ONCE)
	yield(get_tree(), "idle_frame")
	display.update_image(true)
	################################
	
	
	
