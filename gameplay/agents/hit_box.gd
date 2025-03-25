@tool
@icon("uid://bv63hb5gynt8d")
class_name HitBox
extends CharacterArea

func _setup_collision_shape() -> void:
	_collision_shape = _character.hit_box_shape.create_collision_shape()
	super._setup_collision_shape()
