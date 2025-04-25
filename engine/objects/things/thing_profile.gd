@tool
@icon("uid://c4udocqr7qeyj")
class_name ThingProfile
extends Profile

enum Groups {
	ITEMS,
}
@export var group: Groups = Groups.ITEMS

@export_category("Attributes")
@export_custom(PROPERTY_HINT_RANGE, "0.001,1000.0,exp,suffix:kg") var mass: float = 1.0

@export_category("")
@export_group("Configuration")

func create(variation: int, spawn_transform: Transform3D) -> Thing:
	return Thing.create(variation, self, spawn_transform)

func get_group_name() -> StringName:
	var group_name: StringName = Groups.keys()[group]
	return group_name.capitalize()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if _model_variations.is_empty(): warnings.append("Missing model variations scene.")
	return warnings + super._get_configuration_warnings()
