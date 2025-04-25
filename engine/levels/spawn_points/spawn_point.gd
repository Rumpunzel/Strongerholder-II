@tool
@icon("uid://cscgs7miwut5n")
class_name SpawnPoint
extends Marker3D

## Determines the varation of the [Model]
## If [code]<0[/code] a random [Model] will be used
@export var variation: int = -1

@export_group("Configuration")
@export var _editor_material: Material = preload("uid://dilpjt8kd3s4d")

func _ready() -> void:
	if Engine.is_editor_hint():
		var model: Model = get_profile().create_model(variation)
		if _editor_material: model.apply_material_override(_editor_material)
		add_child(model)

func get_profile() -> Profile:
	assert(false, "SpawnPoint.get_model is 'virtual' and needs to be overriden!")
	return null

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
