@tool
@icon("uid://nl71yast8tsi")
class_name PlayerGhost
extends Node

signal character_haunted(haunted_character: Character, haunting_character: Character)
signal character_unhaunted(unhaunted_character: Character)

const PLAYER_ID: StringName = "player_id"
const CHARACTER_PATH: StringName = "character_path"

const PLAYER_GHOST_SCENE: PackedScene = preload("uid://ckcrpkujohkql")

const _ACTIVE_CAMERA_PRIORITY: int = 16
const _DEFAULT_CAMERA_PRIORITY: int = 1
const _INACTIVE_CAMERA_PRIORITY: int = 0

@export var player: Player:
	set(new_player):
		assert(new_player)
		player = new_player
		set_multiplayer_authority(player.get_multiplayer_authority())
		name = player.name
		input_reader.player = player
		interaction_area.set_enabled(get_multiplayer_authority())
		_camera.current = player.is_local_player() and character

@export var character: Character:
	set(new_character):
		if character:
			character.set_multiplayer_authority(Multiplayer.HOST_ID)
			haunt_phantom_camera.erase_follow_targets(character)
			haunt_phantom_camera.erase_look_at_targets(character)
			_state_machine.stop()
		character = new_character
		character.set_multiplayer_authority(player.get_multiplayer_authority())
		if not is_node_ready(): await ready
		interaction_area.character = character
		default_phantom_camera.follow_target = character
		default_phantom_camera.look_at_target = character
		_camera.current = player.is_local_player() and character
		if not character:
			haunt_phantom_camera.append_follow_targets(character)
			haunt_phantom_camera.append_look_at_target(character)
			return
		character.name = name
		haunt_phantom_camera.follow_targets = [character]
		haunt_phantom_camera.look_at_targets = [character]
		if not is_multiplayer_authority(): return
		#await get_tree().process_frame
		_state_machine.start()

@export_group("Configuration")
@export var input_reader: InputReader
@export var interaction_area: InteractionArea
@export var default_phantom_camera: PhantomCamera3D
@export var haunt_phantom_camera: PhantomCamera3D
@export var _state_machine: PlayerStateMachine
@export var _camera: Camera3D

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not is_multiplayer_authority(): return
	if not character: return
	_state_machine.update(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not is_multiplayer_authority(): return
	if not character: return
	_state_machine.physics_update(delta)
	interaction_area.transform = character.transform

static func create(for_player: Player, new_character: Character) -> PlayerGhost:
	assert(for_player)
	assert(new_character)
	var new_player_ghost: PlayerGhost = PLAYER_GHOST_SCENE.instantiate()
	new_player_ghost.player = for_player
	new_player_ghost.character = new_character
	return new_player_ghost

static func validate_player_ghost_data(player_ghost_data: Dictionary[StringName, Variant]) -> void:
	assert(player_ghost_data.has_all([PLAYER_ID, CHARACTER_PATH]))
	assert(player_ghost_data.size() == 2)

func get_active_camera_priority() -> int:
	return _ACTIVE_CAMERA_PRIORITY if player.is_local_player() else _INACTIVE_CAMERA_PRIORITY

func get_default_camera_priority() -> int:
	return _DEFAULT_CAMERA_PRIORITY if player.is_local_player() else _INACTIVE_CAMERA_PRIORITY

func _on_interaction_area_available_actions_changed(available_actions: Array[CharacterInteraction]) -> void:
	assert(player.is_local_player())
	if not player.is_local_player(): return
	#HUD.update_available_actions(available_actions)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not interaction_area: warnings.append("Missing InteractionArea reference.")
	if not input_reader: warnings.append("Missing InputReader reference.")
	if not default_phantom_camera: warnings.append("Missing default PhantomCamera3D reference.")
	if not haunt_phantom_camera: warnings.append("Missing haunt PhantomCamera3D reference.")
	if not _state_machine: warnings.append("Missing PlayerStateMachine reference.")
	if not _camera: warnings.append("Missing Camera3D reference.")
	return warnings
