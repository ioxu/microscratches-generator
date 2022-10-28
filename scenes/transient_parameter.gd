extends Node

var parameter_name := ""
signal parameter_changed(new_value, this_object)

var line_edit : LineEdit

func _ready() -> void:
	line_edit = self.get_child(1)
	line_edit.connect( "text_entered", self, "_on_LineEdit_text_entered" )
	line_edit.connect( "focus_exited", self, "_on_LineEdit_focus_exited" )


func _on_LineEdit_text_entered(new_string : String) -> void:
	line_edit.release_focus()
	emit_signal( "parameter_changed", new_string, self )


func _on_LineEdit_focus_exited( ) -> void:
	emit_signal( "parameter_changed", line_edit.text, self )


func pprint(thing) -> void:
	print("[transient parameter] %s"%str(thing))

