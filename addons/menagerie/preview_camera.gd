@tool
extends Camera3D

@export var _character: Character

func _ready() -> void:
	_look_at_character()

func _look_at_character() -> void:
	var character_position: Vector3 = _character.position
	var heads_up_anchor: Vector3 = _character.get_heads_up_anchor()
	var look_position: Vector3 = (character_position + heads_up_anchor) / 2.0
	look_at(look_position)
