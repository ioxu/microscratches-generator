extends Node

export(NodePath) onready var ui_root = get_node( ui_root )

var layers : Array
var selected_layers : Array
var layerListContainer : VBoxContainer
var layerParametersListContainer : VBoxContainer
var layerNameParameter : LineEdit

var _layers_count = 0

# layers
const ui_layer = preload("res://scenes/layer.tscn")


func _ready() -> void:
	layerListContainer = ui_root.find_node("layerListContainer")
	layerParametersListContainer = ui_root.find_node("layerParametersListContainer")
	layerNameParameter = layerParametersListContainer.find_node("layerName_LineEdit")

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
	refresh_layers()

func move_selected_layers_up() -> void:
	if len(selected_layers) > 0:
		for l in selected_layers:
			var new_position = l.get_index() -1
			if new_position != -1:
				l.get_parent().move_child( l, l.get_index() -1 )
		sync_layers_from_ui()


func move_selected_layers_down() -> void:
	if len(selected_layers) > 0:
		for l in selected_layers:
			l.get_parent().move_child( l, l.get_index() +1 )
		sync_layers_from_ui()


func sync_layers_from_ui() -> void:
	# rebuilds internal layer list from the layer list in the UI
	# (moving layers in UI list needs sycing back to layers list)
	pprint("sync layers from ui")
	var redordered_layers = []
	for l in layerListContainer.get_children():
		redordered_layers.append(l)
	layers = redordered_layers


func _on_layer_selected( selected_layer : Object, append_select : bool )->void:
	pprint("layer selected %s"%selected_layer)
	if !append_select:
		selected_layers.clear()
	selected_layers.append(selected_layer)
	refresh_layers()


func _on_layer_deselected( deselected_layer : Object, append_select : bool )->void:
	pprint("layer deselected %s"%deselected_layer)
	if !append_select:
		if len(selected_layers) > 1:
			# if not SHIFT-deselecting a layer,
			# leave the single layer that was clicked, selected, 
			# and de-select others
			selected_layers.clear()
			selected_layers.append(deselected_layer)
		else:
			selected_layers.clear()
	else:
		selected_layers.remove( selected_layers.find(deselected_layer) )
	refresh_layers()


func refresh_layers() -> void:
	# refresh all layer things
	pprint("refresh layers")
	for l in layers:
		if selected_layers.find(l) != -1:
			l.set_selected()
		else:
			l.set_deselected()
	display_layer_parameters()


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


# parameters -------------------------------------------------------------------


func display_layer_parameters() -> void:
	if len(selected_layers) == 0:
		# clear parameter pane
		layerNameParameter.text = ""
	
	else:
		# display 1st selected layer
		var l = selected_layers[0]
		pprint("displaying parameters for %s"%l)
		layerNameParameter.text = l.layer_name


func _on_layerName_LineEdit_text_entered(new_text: String) -> void:
	var l = selected_layers[0]
	l.set_layer_name( new_text )
	layerNameParameter.release_focus()


# ------------------------------------------------------------------------------


func pprint(thing) -> void:
	print("[layerManager] %s"%str(thing))


