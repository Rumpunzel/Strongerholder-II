@icon("uid://duyxd2niq7cle")
class_name CharacterInteraction
extends Interaction

var target: CharacterHurtBox

func _init(
	new_source: Character,
	new_target: CharacterHurtBox,
	new_action: Action,
) -> void:
	source = new_source
	target = new_target
	action = new_action

func get_target() -> CharacterHurtBox:
	return target
