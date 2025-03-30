@tool
@icon("uid://nl71yast8tsi")
class_name PlayerGhost
extends Node

const PLAYER_GHOST_SCENE: PackedScene = preload("uid://ckcrpkujohkql")

const _ACTIVE_CAMERA_PRIORITY: int = 16
const _DEFAULT_CAMERA_PRIORITY: int = 1
const _INACTIVE_CAMERA_PRIORITY: int = 0

@export var player: Player:
	set(new_player):
		player = new_player
		if not player:
			input_reader.set_multiplayer_authority(Multiplayer.HOST_ID)
		name = player.name
		input_reader.player = player
		interaction_area.set_enabled(player.is_local_player)
		_camera.current = player.is_local_player and character

@export var character: Character:
	set(new_character):
		if character:
			haunt_phantom_camera.erase_follow_targets(character)
			haunt_phantom_camera.erase_look_at_targets(character)
			_state_machine.stop()
		character = new_character
		if not is_node_ready(): await ready
		interaction_area.character = character
		default_phantom_camera.follow_target = character
		default_phantom_camera.look_at_target = character
		_camera.current = player.is_local_player and character
		if not character:
			haunt_phantom_camera.append_follow_targets(character)
			haunt_phantom_camera.append_look_at_target(character)
			return
		haunt_phantom_camera.follow_targets = [character]
		haunt_phantom_camera.look_at_targets = [character]
		_state_machine.start()

@export_group("Configuration")
@export var input_reader: InputReader
@export var interaction_area: InteractionArea
@export var default_phantom_camera: PhantomCamera3D
@export var haunt_phantom_camera: PhantomCamera3D
@export var _state_machine: PlayerStateMachine
@export var _camera: Camera3D

## This is used for serialization purposes; serves otherwise no purpose
var _character_path: NodePath:
	get: return character.get_path() if character and character.is_inside_tree() else NodePath()
	set(new_character_path):
		if new_character_path == _character_path: return
		if _character_path.is_empty():
			character = null
			return
		await get_tree().process_frame
		character = get_node(_character_path)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not Multiplayer.is_server(): return
	if not character: return
	_state_machine.update(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not Multiplayer.is_server(): return
	if not character: return
	_state_machine.physics_update(delta)
	interaction_area.transform = character.transform

static func create(for_player: Player, new_character: Character) -> PlayerGhost:
	var new_player_ghost: PlayerGhost = PLAYER_GHOST_SCENE.instantiate()
	new_player_ghost.player = for_player
	new_player_ghost.character = new_character
	return new_player_ghost

func get_active_camera_priority() -> int:
	return _ACTIVE_CAMERA_PRIORITY if player.is_local_player else _INACTIVE_CAMERA_PRIORITY

func get_default_camera_priority() -> int:
	return _DEFAULT_CAMERA_PRIORITY if player.is_local_player else _INACTIVE_CAMERA_PRIORITY

func _on_interaction_area_available_actions_changed(available_actions: Array[CharacterInteraction]) -> void:
	assert(player.is_local_player)
	if not player.is_local_player: return
	HUD.update_available_actions(available_actions)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not interaction_area: warnings.append("Missing InteractionArea reference.")
	if not input_reader: warnings.append("Missing InputReader reference.")
	if not default_phantom_camera: warnings.append("Missing default PhantomCamera3D reference.")
	if not haunt_phantom_camera: warnings.append("Missing haunt PhantomCamera3D reference.")
	if not _state_machine: warnings.append("Missing PlayerStateMachine reference.")
	if not _camera: warnings.append("Missing Camera3D reference.")
	return warnings
