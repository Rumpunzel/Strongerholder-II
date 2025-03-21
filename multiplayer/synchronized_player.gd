class_name SynchronizedPlayer
extends Node

@export var character: CharacterController:
	set(new_character):
		character = new_character
		set_process(new_character != null)

@export var player_id := 1:
	set(new_player_id):
		player_id = new_player_id
		name = "%d" % new_player_id
		%InputSynchronizer.set_multiplayer_authority(new_player_id)

@onready var _input_synchronizer: InputSynchronizer = %InputSynchronizer
@onready var _camera: TopDownCamera = %TopDownCamera

func _ready() -> void:
	_camera.current = multiplayer.get_unique_id() == player_id
	if not character:
		_camera.frame_point(Vector3.ZERO)
		printerr("No character supplied for player %s!" % self.name)
		set_process(false)

func _process(_delta: float) -> void:
	assert(character)
	character.direction_input = _camera.get_adjusted_movement(_input_synchronizer.input_direction)
	_camera.frame_node(character)
