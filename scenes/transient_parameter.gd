extends Node

var parameter_name := ""
signal parameter_changed(new_value, this_object)

var line_edit : LineEdit
var check_box : CheckBox

var type : int # https://docs.godotengine.org/en/stable/classes/class_@globalscope.html enum Variant.Type:


func _ready() -> void:
	if type in [TYPE_INT, TYPE_REAL, TYPE_STRING]:
		line_edit = self.get_child(1)
		line_edit.connect( "text_entered", self, "_on_LineEdit_text_entered" )
		line_edit.connect( "focus_exited", self, "_on_LineEdit_focus_exited" )
	elif type in [TYPE_BOOL]:
		check_box = self.get_child(1)
		check_box.connect( "toggled", self, "_on_CheckBox_toggled" )


func _on_LineEdit_text_entered(new_string : String) -> void:
	line_edit.release_focus()
	emit_signal( "parameter_changed", new_string, self )


func _on_LineEdit_focus_exited( ) -> void:
	emit_signal( "parameter_changed", line_edit.text, self )


func _on_CheckBox_toggled(new_value) -> void:
	emit_signal( "parameter_changed", new_value, self )


func pprint(thing) -> void:
	print("[transient parameter] %s"%str(thing))

