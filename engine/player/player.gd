@tool
@icon("uid://nl71yast8tsi")
class_name Player
extends Node

signal player_info_changed(player_info: Dictionary[StringName, Variant])

const ID: StringName = "player_id"
const NAME: StringName = "player_name"
const GHOST_SPRITE_FRAME: StringName = "ghost_sprite_frame"

const PLAYER_SCENE: PackedScene = preload("uid://ckcrpkujohkql")

const _ACTIVE_CAMERA_PRIORITY: int = 16
const _DEFAULT_CAMERA_PRIORITY: int = 1
const _INACTIVE_CAMERA_PRIORITY: int = 0

@export var player_id: int = Multiplayer.HOST_ID:
	set(new_player_id):
		if not Engine.is_editor_hint(): name = "%d" % new_player_id
		if new_player_id == player_id: return
		player_id = new_player_id
		player_info_changed.emit(get_player_info())

@export var player_name: String:
	set(new_player_name):
		if new_player_name == player_name: return
		player_name = new_player_name
		player_info_changed.emit(get_player_info())

@export var ghost_sprite_frame: int = 0:
	set(new_ghost_sprite_frame):
		if new_ghost_sprite_frame == ghost_sprite_frame: return
		ghost_sprite_frame = new_ghost_sprite_frame
		player_info_changed.emit(get_player_info())

@export var character: Character:
	set(new_character):
		if character:
			_state_machine.stop()
		character = new_character
		if not is_node_ready(): await ready
		interaction_area.character = character
		default_phantom_camera.follow_target = character
		default_phantom_camera.look_at_target = character
		haunt_phantom_camera.follow_targets = [character]
		haunt_phantom_camera.look_at_targets = [character]
		if character:
			Serializer.mark_all_child_serializers_for(character, PropertiesSerializer.Type.INTANGIBLE)
			_state_machine.start()

@export_group("Configuration")
@export var interaction_area: InteractionArea
@export var default_phantom_camera: PhantomCamera3D
@export var haunt_phantom_camera: PhantomCamera3D
@export var _state_machine: PlayerStateMachine
@export var _camera: Camera3D
@export var _default_character_profile: CharacterProfile

var direction_input: Vector2 = Vector2.ZERO
var interaction_input: StringName = ""
var available_action: CharacterInteraction:
	set(new_current_interactable):
		available_action = new_current_interactable
		var available_actions: Array[CharacterInteraction] = []
		if available_action: available_actions.append(available_action)
		HUD.update_available_actions(available_actions)

var is_local_player: bool = true:
	set(new_is_local_player):
		is_local_player = new_is_local_player
		interaction_area.set_enabled(is_local_player)
		_camera.current = is_local_player

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

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Serializer.mark_all_child_serializers_for(self, PropertiesSerializer.Type.INTANGIBLE)
	if not is_local_player: return
	# Only collect input if this is the local [Player]
	_collect_input()
	if not character:
		await get_tree().process_frame
		character = Game.create_character(_default_character_profile, Transform3D())
	else:
		_state_machine.start()

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not is_local_player: return
	_collect_input()
	if not character: return
	_state_machine.update(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not is_local_player: return
	if not character: return
	_state_machine.physics_update(delta)
	interaction_area.transform = character.transform

static func read_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

static func create(new_player_id: int, new_player_name: String, existing_character: Character = null) -> Player:
	var new_player: Player = PLAYER_SCENE.instantiate()
	new_player.player_id = new_player_id
	new_player.player_name = new_player_name
	if existing_character: new_player.character = existing_character
	return new_player

static func from_player_info(player_info: Dictionary[StringName, Variant]) -> Player:
	validate_player_info(player_info)
	var new_player_id: int = player_info[ID]
	var new_player_name: String = player_info[NAME]
	var new_player: Player = Player.create(new_player_id, new_player_name)
	return new_player

static func validate_player_info(player_info: Dictionary[StringName, Variant]) -> void:
	assert(player_info.has_all([ID, NAME, GHOST_SPRITE_FRAME]))
	assert(player_info.size() == 3)

func get_player_info() -> Dictionary[StringName, Variant]:
	var player_info: Dictionary[StringName, Variant] = {
		ID: player_id,
		NAME: player_name if not player_name.is_empty() else "Player %d" % player_id,
		GHOST_SPRITE_FRAME: ghost_sprite_frame,
	}
	validate_player_info(player_info)
	return player_info

func get_camera_adjusted_direction_input() -> Vector2:
	var camera_forward: Vector3 = _camera.transform.basis.z
	camera_forward.y = 0.0
	var camera_right: Vector3 = _camera.transform.basis.x
	camera_right.y = 0.0
	var adjusted_input_vector: Vector3 = camera_forward.normalized() * direction_input.y + camera_right.normalized() * direction_input.x
	return Vector2(adjusted_input_vector.x, adjusted_input_vector.z)

func get_active_camera_priority() -> int:
	return _ACTIVE_CAMERA_PRIORITY if is_local_player else _INACTIVE_CAMERA_PRIORITY

func get_default_camera_priority() -> int:
	return _DEFAULT_CAMERA_PRIORITY if is_local_player else _INACTIVE_CAMERA_PRIORITY

func _collect_input() -> void:
	direction_input = read_movement_input()
	interaction_input = ""
	if Input.is_action_pressed("interact"): interaction_input = "interact"
	elif Input.is_action_pressed("unpossess"): interaction_input = "unpossess"

func _create_character_interaction(for_hit_box: HitBox) -> CharacterInteraction:
	return CharacterInteraction.new(
		character,
		for_hit_box.character,
		preload("uid://cuoqy5wkfjika"),
	)

func _on_interaction_area_current_interactable_changed(current_interactable: HitBox) -> void:
	if not current_interactable:
		available_action = null
		return
	available_action = _create_character_interaction(current_interactable)

func _on_player_name_changed(new_player_name: String) -> void:
	player_name = new_player_name

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not interaction_area: warnings.append("Missing InteractionArea reference.")
	if not default_phantom_camera: warnings.append("Missing default PhantomCamera3D reference.")
	if not haunt_phantom_camera: warnings.append("Missing haunt PhantomCamera3D reference.")
	if not _state_machine: warnings.append("Missing PlayerStateMachine reference.")
	if not _camera: warnings.append("Missing Camera3D reference.")
	if not _default_character_profile: warnings.append("Missing default CharacterProfile.")
	return warnings
