extends Node

export(NodePath) onready var viewport = get_node( viewport )
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


func _ready() -> void:
	zoom_label = self.find_node("zoom_label")
	resolution_label = self.find_node("resolution_label")
	resolution_label.text = "resolution : %s"%viewport.get_size()
	coords_label = self.find_node("coords_label")

	pixel_red_label = self.find_node("pixelvalues_red_label")
	pixel_green_label = self.find_node("pixelvalues_green_label")
	pixel_blue_label = self.find_node("pixelvalues_blue_label")
	pixel_alpha_label = self.find_node("pixelvalues_alpha_label")

	swatch_rect = self.find_node("swatch_rect")

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
