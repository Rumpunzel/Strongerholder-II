@tool
@icon("uid://bbvd8haxvdmk6")
class_name InteractionArea
extends CharacterArea

const DEBUG_COLOR: Color = Color("d95f006b")

func _setup_collision_shape() -> void:
	collision_shape = character.interaction_area_shape.create_collision_shape()
	collision_shape.debug_color = DEBUG_COLOR
