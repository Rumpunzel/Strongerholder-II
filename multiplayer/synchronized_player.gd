class_name SynchronizedPlayer
extends Node

@export var player_id := 1:
	set(new_player_id):
		player_id = new_player_id
		name = "%d" % player_id
		%InputSynchronizer.set_multiplayer_authority(player_id)

@export var player_name: String

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		set_process(character_controller != null)
		if not character_controller:
			_character_controller_path = NodePath()
			return
		_character_controller_path = character_controller.get_path()

# This is used for multiplayer purposes to synchronize over network
#  serves otherwise no purpose 
var _character_controller_path: NodePath:
	set(new_character_controller_path):
		_character_controller_path = new_character_controller_path
		if character_controller or _character_controller_path.is_empty(): return
		await get_tree().process_frame
		character_controller = get_node(_character_controller_path)

var _player_scene: PackedScene = load("uid://ckcrpkujohkql")

@onready var _input_synchronizer: InputSynchronizer = %InputSynchronizer
@onready var _camera: TopDownCamera = %TopDownCamera

func _ready() -> void:
	_camera.current = multiplayer.get_unique_id() == player_id
	if not character_controller:
		_camera.frame_point(Vector3.ZERO)
		set_process(false)

func _process(_delta: float) -> void:
	assert(character_controller)
	character_controller.direction_input = _camera.get_adjusted_movement(_input_synchronizer.input_direction)
	_camera.frame_node(character_controller)

static func from_player_info(player_info: Dictionary) -> SynchronizedPlayer:
	var synchronized_player_scene: PackedScene = load("uid://cuclrr5bep4gn")
	var new_player: SynchronizedPlayer = synchronized_player_scene.instantiate()
	new_player.player_name = player_info.name
	assert(new_player.player_name == player_info.name)
	new_player.player_id = player_info.id
	assert(new_player.player_id == player_info.id)
	return new_player

func to_player_info() -> Dictionary:
	return { "id": player_id, "name": player_name, }

func to_player() -> Player:
	var new_player: Player = _player_scene.instantiate()
	new_player.character_controller = character_controller
	return new_player
