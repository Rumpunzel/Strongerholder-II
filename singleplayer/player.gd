class_name Player
extends Node

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		set_process(character_controller != null)

@onready var _camera: TopDownCamera = %TopDownCamera

func _ready() -> void:
	if not character_controller:
		_camera.frame_point(Vector3.ZERO)
		printerr("No character supplied for player %s!" % self.name)
		set_process(false)

func _process(_delta: float) -> void:
	assert(character_controller)
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	character_controller.direction_input = _camera.get_adjusted_movement(input_direction)
	_camera.frame_node(character_controller)
