@tool
@icon("uid://c7i6a86quqfp7")
extends TextureRect

signal zoomed_out
signal zoomed_in

signal turned_right
signal turned_left

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_mouse_button: InputEventMouseButton = event
		match event_mouse_button.button_index:
			MOUSE_BUTTON_WHEEL_DOWN:
				if Input.is_key_pressed(KEY_CTRL): zoomed_out.emit()
				else: turned_right.emit()
			MOUSE_BUTTON_WHEEL_UP:
				if Input.is_key_pressed(KEY_CTRL): zoomed_in.emit()
				else: turned_left.emit()
		accept_event()
