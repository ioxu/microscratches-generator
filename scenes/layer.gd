extends PanelContainer

export var border_colour := Color(0.56, 0.15, 0.89, 0.64)
export var border_colour_hilight := Color(0.56, 0.15, 0.89, 0.64)
export var border_colour_selected := Color(0.56, 0.15, 0.89, 0.64)


var selected = false
var hilighted = false

var style_panel : StyleBox


func _ready() -> void:
	set("custom_styles/panel", get("custom_styles/panel").duplicate() )
	style_panel = get("custom_styles/panel")
	style_panel.border_color = border_colour


func _input(event: InputEvent) -> void:
	if hilighted: # mouse inside
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed:
					selected = !selected
					update_selected()


func update_selected() -> void:
	if selected:
		style_panel.border_color = border_colour_hilight
		style_panel.border_width_left = 3
		style_panel.border_width_right = 3
		style_panel.border_width_top = 3
		style_panel.border_width_bottom = 3
	else:
		style_panel.border_color = border_colour
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

