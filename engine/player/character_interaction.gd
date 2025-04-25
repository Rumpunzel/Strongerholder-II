@icon("uid://duyxd2niq7cle")
class_name CharacterInteraction

var source: Character
var target: HurtBox
var type: CharacterInteraction2

func _init(
	new_source: Character,
	new_target: HurtBox,
	new_type: CharacterInteraction2,
) -> void:
	source = new_source
	target = new_target
	type = new_type

func is_action_pressed() -> bool:
	return Input.is_action_pressed(type.input_action)

func is_action_just_pressed() -> bool:
	return Input.is_action_just_pressed(type.input_action)

func is_action_just_released() -> bool:
	return Input.is_action_just_released(type.input_action)
 
func get_heads_up_anchor() -> Vector3:
	return target.get_heads_up_anchor()

func get_input_events() -> Array[InputEvent]:
	return InputMap.action_get_events(type.input_action)
