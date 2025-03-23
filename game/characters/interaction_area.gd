@tool
@icon("uid://bbvd8haxvdmk6")
class_name InteractionArea
extends CharacterArea

const DEBUG_COLOR: Color = Color("d95f006b")

func _setup_collision_shape() -> void:
	_collision_shape.shape = character.interaction_area_shape
