extends Node

export(NodePath) onready var ui_root = get_node( ui_root )

var layers : Array
var layerListContainer : VBoxContainer

# layers
const ui_layer = preload("res://scenes/layer.tscn")


func _ready() -> void:
	layerListContainer = ui_root.find_node("layerListContainer")
	pprint("existing layers:")
	for l in layerListContainer.get_children():
		connect_layer_signals(l)
		pprint("   %s"%l)


func add_layer()->void:
	pprint("add layer")
	var l = ui_layer.instance()
	layerListContainer.add_child(l)
	connect_layer_signals(l)
	

func _on_layer_selected( selected_layer )->void:
	pprint("layer selected %s"%selected_layer)


func _on_layer_deselected( deselected_layer )->void:
	pprint("layer deselected %s"%deselected_layer)


func print_layers() -> void:
	pprint("layers:")
	for l in layers:
		print("  %s"%l)


func connect_layer_signals(layer)->void:
	layer.connect( "selected", self, "_on_layer_selected" )
	layer.connect( "deselected", self, "_on_layer_deselected" )


func pprint(thing) -> void:
	print("[layerManager] %s"%str(thing))
