@tool
extends Button

signal sky_box_pressed(sky_box: PanoramaSkyMaterial)

@export var sky_box: PanoramaSkyMaterial

func _ready() -> void: button_pressed = get_parent().get_children().find(self) == 0

func _on_pressed() -> void:
	sky_box_pressed.emit(sky_box)
