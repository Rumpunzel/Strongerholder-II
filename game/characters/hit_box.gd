@tool
@icon("uid://bv63hb5gynt8d")
class_name HitBox
extends CharacterArea

const DEBUG_COLOR: Color = Color("fd003f6b")

func _setup_collision_shape() -> void:
	_collision_shape.shape = character.hit_box_shape
	_collision_shape_offset = Vector3(0.0, Character.y_offset_from_shape(_collision_shape.shape), 0.0)
