extends Node

var zoom_label : Label


func _ready() -> void:
	zoom_label = self.find_node("zoom_label")


func _on_display_zoom_changed(new_zoom) -> void:
	zoom_label.text = "zoom : %0.2f"%new_zoom
