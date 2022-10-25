extends PanelContainer
class_name Layer

export var layer_name : String = "Layer" setget set_layer_name

export var border_colour := Color(0.56, 0.15, 0.89, 0.64)
export var border_colour_hilight := Color(0.56, 0.15, 0.89, 0.64)
export var border_colour_selected := Color(0.56, 0.15, 0.89, 0.64)

export var background_colour := Color(0.435294, 0.211765, 0.505882, 0.109804)
export var background_colour_hilight := Color(0.435294, 0.211765, 0.505882, 0.109804)

var selected = false
var hilighted = false

var layer_name_label : Label setget set_layer_name
var style_panel : StyleBox

var scene_name : String = "" # stores an identifier for the texture scene name

# select-action:
#	'append_select' : Bool - add to selection or replace selection
signal selected( selected_layer, append_select )
signal deselected( deselected_layer, append_select )


func _ready() -> void:
	set("custom_styles/panel", get("custom_styles/panel").duplicate() )
	style_panel = get("custom_styles/panel")
	style_panel.border_color = border_colour
	style_panel.bg_color = background_colour
	layer_name_label = find_node("layerName_Label")


func set_layer_name(new_name) -> void:
	layer_name = new_name
	layer_name_label.text = layer_name


func _input(event: InputEvent) -> void:
	if hilighted: # mouse inside
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed:
					if !selected:
						emit_signal("selected", self, Input.is_key_pressed(KEY_SHIFT))
					elif selected:
						emit_signal("deselected", self, Input.is_key_pressed(KEY_SHIFT))


func set_selected() -> void:
	if !selected:
		selected = true
		style_panel.border_color = border_colour_hilight
		style_panel.bg_color = background_colour_hilight
		style_panel.border_width_left = 1.5
		style_panel.border_width_right = 1.5
		style_panel.border_width_top = 1.5
		style_panel.border_width_bottom = 1.5


func set_deselected() -> void:
	if selected:
		selected = false
		style_panel.border_color = border_colour
		style_panel.bg_color = background_colour
		style_panel.border_width_left = 1
		style_panel.border_width_right = 1
		style_panel.border_width_top = 1
		style_panel.border_width_bottom = 1


func _on_layer_PanelContainer_mouse_entered() -> void:
	hilighted = true
	if not selected:
		style_panel.border_color = border_colour_hilight


func _on_layer_PanelContainer_mouse_exited() -> void:
	hilighted = false
	if not selected:
		style_panel.border_color = border_colour

func _to_string() -> String:
	# "[ClassName:RID]"
	# "[%s:%s]"%[self.get_class(), self.get_instance_id()]
	#return "Layer [%s:%s] (%s)"%[self.get_class(), self.get_instance_id(), self.layer_name]
	return "Layer \"%s\" (%s)"%[self.layer_name, "test_lines.tcsn"]



