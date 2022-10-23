extends PanelContainer

export var border_colour := Color(0.56, 0.15, 0.89, 0.64)
export var border_colour_hilight := Color(0.56, 0.15, 0.89, 0.64)
export var border_colour_selected := Color(0.56, 0.15, 0.89, 0.64)

export var background_colour := Color(0.435294, 0.211765, 0.505882, 0.109804)
export var background_colour_hilight := Color(0.435294, 0.211765, 0.505882, 0.109804)

var selected = false
var hilighted = false

var style_panel : StyleBox

signal selected( selected_layer )
signal deselected( deselected_layer )


func _ready() -> void:
	set("custom_styles/panel", get("custom_styles/panel").duplicate() )
	style_panel = get("custom_styles/panel")
	style_panel.border_color = border_colour
	style_panel.bg_color = background_colour


func _input(event: InputEvent) -> void:
	if hilighted: # mouse inside
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed:
					selected = !selected
					update_selected()
					if selected:
						emit_signal("selected", self)
					else:
						emit_signal("deselected", self)


func update_selected() -> void:
	if selected:
		style_panel.border_color = border_colour_hilight
		style_panel.bg_color = background_colour_hilight
		style_panel.border_width_left = 1.5
		style_panel.border_width_right = 1.5
		style_panel.border_width_top = 1.5
		style_panel.border_width_bottom = 1.5
	else:
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

