@tool
@icon("uid://bv63hb5gynt8d")
class_name HitBox
extends CharacterArea

const DEBUG_COLOR: Color = Color("fd003f6b")

func _setup_collision_shape() -> void:
	collision_shape = character.hit_box_shape.create_collision_shape()
	collision_shape.debug_color = DEBUG_COLOR
