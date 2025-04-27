@tool
@icon("uid://c7i6a86quqfp7")
extends TextureRect

@export var _preview: Node3D
@export_custom(PROPERTY_HINT_RANGE, "0.0,360.0,suffix:°") var _turn_rate: float = 8.0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_mouse_button: InputEventMouseButton = event
		match event_mouse_button.button_index:
			MOUSE_BUTTON_WHEEL_DOWN: _preview.rotate_y(deg_to_rad(_turn_rate))
			MOUSE_BUTTON_WHEEL_UP: _preview.rotate_y(deg_to_rad(-_turn_rate))
		accept_event()
