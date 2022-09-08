extends Node

export(NodePath) onready var viewport = get_node( viewport )

var zoom_label : Label
var resolution_label : Label

func _ready() -> void:
	zoom_label = self.find_node("zoom_label")
	resolution_label = self.find_node("resolution_label")
	resolution_label.text = "resolution : %s"%viewport.get_size()


func _on_display_zoom_changed(new_zoom) -> void:
	zoom_label.text = "zoom : %0.2f"%new_zoom


func _on_Viewport_size_changed() -> void:
	resolution_label.text = "resolution : %s"%viewport.get_size()
