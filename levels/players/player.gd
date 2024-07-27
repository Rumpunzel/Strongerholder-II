class_name Player
extends Node

# Set by the authority, synchronized on spawn.
var player_id := 1 :
	set(new_player_id):
		player_id = new_player_id
		name = str(player_id)
		# Give authority over the player input to the appropriate peer.
		$InputSynchronizer.set_multiplayer_authority(player_id)

# Character controlled by this player.
var _character_path: String = "" :
	set(new_character_path):
		_character_path = new_character_path
		if multiplayer.is_server():
			_camera.set_follow_node_path(_character_path)
		else:
			_camera.set_follow_node_path.rpc(_character_path)

@onready var _input_synchronizer: InputSynchronizer = %InputSynchronizer
@onready var _camera: TopDownCamera = %Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the camera as current if we are this player.
	_camera.current = is_local()
	if is_local():
		EventsGameplay.node_clicked.connect(_on_node_clicked)

func _exit_tree() -> void:
	if is_local():
		EventsGameplay.node_clicked.disconnect(_on_node_clicked)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func is_local() -> bool:
	return player_id == multiplayer.get_unique_id()

func get_character() -> CharacterController:
	return get_node_or_null(_character_path)

func get_movement_input() -> Vector3:
	return _camera.get_adjusted_movement(_input_synchronizer.input_vector).normalized()

func get_jump_input() -> bool:
	return _input_synchronizer.jump_input

func set_jump_input(new_status: bool) -> void:
	_input_synchronizer.jump_input = new_status

func _on_node_clicked(node: Node3D, _event: InputEvent) -> void:
	if node is CharacterController:
		var new_character := node as CharacterController
		if not new_character.controlled_by.is_empty(): return
		if get_character():
			get_character().controlled_by = ""
		_character_path = node.get_path()
		print_debug("Trying to set controlling player for %s to %s" % [ node.name, self.name ])
		if multiplayer.is_server():
			get_character().set_controlling_player(get_path())
		else:
			get_character().set_controlling_player.rpc(get_path())
		get_viewport().set_input_as_handled()
