@tool
extends Button

signal sky_box_pressed(sky_box: PanoramaSkyMaterial)

@export var sky_box: PanoramaSkyMaterial

func _on_pressed() -> void:
	sky_box_pressed.emit(sky_box)
