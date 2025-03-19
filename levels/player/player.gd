class_name Player
extends Node

@export var character: CharacterController
@export var camera: TopDownCamera

func _process(_delta: float) -> void:
	if not character:
		printerr("No character supplied for player %s!" % self.name)
		return
	if not camera:
		printerr("No camera supplied for player %s!" % self.name)
		return
	
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	character.direction_input = camera.get_adjusted_movement(input_vector)
	camera.frame_node(character)
