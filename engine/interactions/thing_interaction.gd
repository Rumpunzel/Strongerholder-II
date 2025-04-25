@icon("uid://238e7i3250qa")
class_name ThingInteraction
extends Interaction

var target: ThingHurtBox

func _init(
	new_source: Character,
	new_target: ThingHurtBox,
	new_action: Action,
) -> void:
	source = new_source
	target = new_target
	action = new_action
 
func get_target() -> ThingHurtBox:
	return target
