extends Node

var parameter_name := ""
signal parameter_changed(new_value, this_object)

var line_edit : LineEdit

func _ready() -> void:
	for c in self.get_children():
		if c.get_class() == "SpinBox":
			line_edit = c.get_line_edit()
			var err = line_edit.connect( "text_entered", self, "_on_LineEdit_text_entered" )


func _on_LineEdit_text_entered(new_string : String) -> void:
	line_edit.release_focus()
	emit_signal( "parameter_changed", new_string, self )


func pprint(thing) -> void:
	print("[transient parameter] %s"%str(thing))
