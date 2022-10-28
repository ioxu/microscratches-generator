extends Node
class_name LayerManager

export(NodePath) onready var ui_root = get_node( ui_root )
export(NodePath) onready var render_scene_root = get_node( render_scene_root )

var layers : Array
var selected_layers : Array
var layerListContainer : VBoxContainer
var layerParametersListContainer : VBoxContainer
var layerNameParameter : LineEdit
var texture_scene_name_parameter : Label
var texture_scene_name_parameter_colour : Color

var parameter_text_font : Font

var _layers_count : int = 0

# layers
const ui_layer : PackedScene = preload("res://scenes/layer.tscn")

# parameters
const transient_parameter_script = preload("res://scenes/transient_parameter.gd")
signal changed_transient_parameter (new_value, transient_parameter)


func _ready() -> void:
	layerListContainer = ui_root.find_node("layerListContainer")
	layerParametersListContainer = ui_root.find_node("layerParametersListContainer")
	layerNameParameter = layerParametersListContainer.find_node("layerName_LineEdit")
	texture_scene_name_parameter = layerParametersListContainer.find_node("texture_scene_name_Label")
	texture_scene_name_parameter_colour = texture_scene_name_parameter.get_modulate()

	parameter_text_font = texture_scene_name_parameter.get("custom_fonts/font").duplicate()


func add_layer(new_texture_node : Node = null, select_new : bool = true)->void:
	# adds a new layer to the GUI,
	# and a node heirarchy (with a Node2D root) to the rendering viewport
	# (it is intended that new_texture_node is an instanced PackedScene loaded from a .tcsn)
	# but concievably a hierarchy could be scripted and passed in instead.
	var l : Layer = ui_layer.instance()
	layerListContainer.add_child(l)
	# move to top
	l.get_parent().move_child(l, 0)
	_layers_count +=1
	l.layer_name = "Layer%s"%str(_layers_count)
	layers.append( l )

	if new_texture_node != null:
		render_scene_root.add_child( new_texture_node )
		new_texture_node.set_owner( render_scene_root )
		l.texture_scene = new_texture_node

	if select_new:
		# select only the new layer
		selected_layers.clear()
		selected_layers.append(l)
	connect_layer_signals(l)
	sync_layers_from_ui()
	refresh_layers()


func remove_selected_layers() -> void:
	var layers_to_free = []
	var scenes_to_free = []
	if layerListContainer.get_child_count() > 0:
		for l in layerListContainer.get_children():
			if selected_layers.find(l) != -1:
				layers_to_free.append(l)
				if l.texture_scene != null:
					scenes_to_free.append( l.texture_scene )
	
	for l in layers_to_free:
		selected_layers.remove( selected_layers.find(l) )
		layers.remove( layers.find(l) )
		pprint("[remove layers] removing layer: %s"%l)
		l.queue_free()
	
	for s in scenes_to_free:
		pprint("[remove layers] removing texture scene: %s (%s)"%[s, s.get_path()])
		s.queue_free()

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
	# then synchronises the node order under render_scene_root
	pprint("sync layers from ui")
	var redordered_layers = []
	for l in layerListContainer.get_children():
		redordered_layers.append(l)
	layers = redordered_layers

	for l in layers:
		render_scene_root.move_child( (l as Layer).texture_scene, 0 )


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
	
	# clear existing parameterss
	if len(selected_layers) == 0:
		remove_transient_parameters()
	
	display_layer_parameters()


func connect_layer_signals(layer)->void:
	layer.connect( "selected", self, "_on_layer_selected" )
	layer.connect( "deselected", self, "_on_layer_deselected" )


# parameters -------------------------------------------------------------------

func remove_transient_parameters() -> void:
	for child in layerParametersListContainer.get_children():
		if not child.name.begins_with("base_"):
			child.queue_free()


func display_layer_parameters() -> void:
	if len(selected_layers) == 0:
		# clear parameter pane
		layerNameParameter.text = ""
		texture_scene_name_parameter.text = ""
	else:
		# display 1st selected layer
		var l : Layer = selected_layers[0]
		pprint("displaying parameters for %s"%l)
		layerNameParameter.text = l.layer_name
		var scene_name : String = ""
		if not l.texture_scene:
			texture_scene_name_parameter.set_modulate(Color(0.90625, 0.441067, 0.392944, 0.854902))
			scene_name = "NULL"
		else:
			texture_scene_name_parameter.set_modulate(texture_scene_name_parameter_colour)
			scene_name = l.texture_scene.get_name()

			
			# list exported vars:
			# https://godotengine.org/qa/38526/how-to-list-the-export-vars-of-a-node
			# 8199 is PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_DEFAULT 
			var exported_vars = []
			for p in l.texture_scene.get_property_list():
				if p["usage"] == PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_DEFAULT:
					exported_vars.append( p )
					
			if len(exported_vars) > 0:
				pprint("    exposed parameters:")
				for p in exported_vars:
					pprint("      \"%s\":%s (%s) .. %s"%[p.name, l.texture_scene.get(p.name) ,  Util.PROPERTY_TYPE_STRINGS[int(p.type)], str(p)])

			# list methods on object
			var method_list = l.texture_scene.get_method_list()
			var is_generator = false
			for m in method_list:
				if m.name == "generate":
					is_generator = true
			
			if is_generator:
				pprint("    is generator.")

			# clear existing parameters
			remove_transient_parameters()

			# build transient parameters
			for p in exported_vars:
				var new_hbox = HBoxContainer.new()
				new_hbox.set_name("transient_parameter_%s"%p["name"] )
				var new_label = Label.new()
				new_label.set("custom_fonts/font", parameter_text_font)
				new_label.text = p.name
				var new_parm = SpinBox.new()
				new_parm.set("custom_fonts/font", parameter_text_font)
#				new_parm.min_value = -100000
#				new_parm.max_value =  100000
				new_parm.set_allow_greater(true)
				new_parm.set_allow_lesser(true)
				new_parm.align = 2
				new_parm.size_flags_horizontal = Control.SIZE_FILL + Control.SIZE_EXPAND
				new_parm.get_line_edit().set("custom_fonts/font", parameter_text_font)
#				for c in new_parm.get_children():
#					if c.get_class() == "LineEdit":
#						c.set("custom_fonts/font", parameter_text_font)
				new_hbox.add_child(new_label)
				new_hbox.add_child(new_parm)
				new_hbox.set_script( transient_parameter_script )
				new_hbox.parameter_name = p["name"]
				new_hbox.connect("parameter_changed", self, "_on_transient_parameter_changed" )
				
				layerParametersListContainer.add_child( new_hbox )

			# ✓ connect parammeter signals to a single edit handler
			# ❌❌✖ set values on textue_scene instance
			# ✓ copy fonts to transient parameters 

		texture_scene_name_parameter.text = scene_name


func _on_transient_parameter_changed(new_value, on_object):
	pprint("TRANSIENT PARAMETER VALUE CHANGED: %s on %s (%s)"%[new_value, on_object.parameter_name, on_object])


func _on_layerName_LineEdit_text_entered(new_text: String) -> void:
	var l = selected_layers[0]
	l.set_layer_name( new_text )
	layerNameParameter.release_focus()


# ------------------------------------------------------------------------------

func print_layers() -> void:
	pprint("layers: (n:%s, %s selected)"%[len(layers), len(selected_layers)])
	for l in layers:
		var ss = ""
		if selected_layers.find(l) != -1:
			ss = "(selected)" 
		print("  %s %s"%[l, ss])


func pprint(thing) -> void:
	print("[layerManager] %s"%str(thing))


