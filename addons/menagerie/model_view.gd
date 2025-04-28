@tool
@icon("uid://c7i6a86quqfp7")
extends TextureRect

signal turned_right
signal turned_left

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_mouse_button: InputEventMouseButton = event
		match event_mouse_button.button_index:
			MOUSE_BUTTON_WHEEL_DOWN: turned_right.emit()
			MOUSE_BUTTON_WHEEL_UP: turned_left.emit()
		accept_event()
