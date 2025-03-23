@tool
@icon("uid://bv63hb5gynt8d")
class_name HitBox
extends CharacterArea

const DEBUG_COLOR: Color = Color("fd003f6b")

func _setup_collision_shape() -> void:
	_collision_shape.shape = character.hit_box_shape
	_collision_shape.position.y = Character.y_offset_from_shape(_collision_shape.shape)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super._get_configuration_warnings()
	if _collision_shape and _collision_shape.position.y != 0.0: warnings.append("Y position of CollisionShape will be overriden.")
	return warnings
