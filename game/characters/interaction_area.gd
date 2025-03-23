@tool
@icon("uid://bbvd8haxvdmk6")
class_name InteractionArea
extends CharacterArea

func _setup_collision_shape() -> void:
	_collision_shape.shape = character.interaction_area_shape
