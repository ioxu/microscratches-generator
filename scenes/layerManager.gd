extends Node

export(NodePath) onready var ui_root = get_node( ui_root )

var layers : Array
var selected_layers : Array
var layerListContainer : VBoxContainer

var _layers_count = 0

# layers
const ui_layer = preload("res://scenes/layer.tscn")


func _ready() -> void:
	layerListContainer = ui_root.find_node("layerListContainer")
	pprint("existing layers:")
	for l in layerListContainer.get_children():
		connect_layer_signals(l)
		pprint("   %s"%l)
		layers.append( l )
		_layers_count += 1


func add_layer()->void:
	pprint("add layer")
	var l = ui_layer.instance()
	layerListContainer.add_child(l)
	_layers_count +=1
	l.layer_name = "Layer%s"%_layers_count
	layers.append( l )
	connect_layer_signals(l)


func remove_selected_layers() -> void:
	var layers_to_free = []
	if layerListContainer.get_child_count() > 0:
		for l in layerListContainer.get_children():
			if selected_layers.find(l) != -1:
				layers_to_free.append(l)
	
	for l in layers_to_free:
		selected_layers.remove( selected_layers.find(l) )
		layers.remove( layers.find(l) )
		pprint("removing layer: %s"%l)
		l.queue_free()


func move_selected_layers_up() -> void:
	for l in selected_layers:
		var new_position = l.get_index() -1
		if new_position != -1:
			l.get_parent().move_child( l, l.get_index() -1 )


func move_selected_layers_down() -> void:
	for l in selected_layers:
		l.get_parent().move_child( l, l.get_index() +1 )


func _on_layer_selected( selected_layer )->void:
	pprint("layer selected %s"%selected_layer)
	selected_layers.append(selected_layer)


func _on_layer_deselected( deselected_layer )->void:
	pprint("layer deselected %s"%deselected_layer)
	selected_layers.remove( selected_layers.find(deselected_layer) )


func print_layers() -> void:
	pprint("layers: (n:%s, %s selected)"%[len(layers), len(selected_layers)])
	for l in layers:
		var ss = ""
		if selected_layers.find(l) != -1:
			ss = "(selected)" 
		print("  %s %s"%[l, ss])



func connect_layer_signals(layer)->void:
	layer.connect( "selected", self, "_on_layer_selected" )
	layer.connect( "deselected", self, "_on_layer_deselected" )


func pprint(thing) -> void:
	print("[layerManager] %s"%str(thing))
