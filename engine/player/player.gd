@tool
@icon("uid://nl71yast8tsi")
class_name Player
extends Node

signal player_info_changed(player_info: Dictionary[StringName, Variant])

const ID: StringName = "player_id"
const NAME: StringName = "player_name"

const PLAYER_SCENE: PackedScene = preload("uid://ckcrpkujohkql")

@export var player_id: int = Multiplayer.HOST_ID:
	set(new_player_id):
		if new_player_id == player_id: return
		player_id = new_player_id
		name = "%d" % player_id
		player_info_changed.emit(get_player_info())

@export var player_name: String:
	set(new_player_name):
		if new_player_name == player_name: return
		player_name = new_player_name
		player_info_changed.emit(get_player_info())

@export var character: Character:
	set(new_character):
		character = new_character
		if not is_node_ready(): await ready
		default_phantom_camera.follow_target = character
		default_phantom_camera.look_at_target = character
		haunt_phantom_camera.follow_targets = [character]
		haunt_phantom_camera.look_at_targets = [character]

@export_group("Configuration")
@export var default_phantom_camera: PhantomCamera3D
@export var haunt_phantom_camera: PhantomCamera3D
@export var interaction_area: InteractionArea
@export var _camera: Camera3D

var direction_input: Vector2 = Vector2.ZERO
var interaction_input: StringName = ""
var available_action: CharacterInteraction:
	set(new_current_interactable):
		available_action = new_current_interactable
		var available_actions: Array[CharacterInteraction] = []
		if available_action: available_actions.append(available_action)
		Game.update_available_actions(available_actions)

var is_local_player: bool = true:
	set(new_is_local_player):
		is_local_player = new_is_local_player
		_camera.current = is_local_player

## This is used for serialization purposes; serves otherwise no purpose
var _character_path: NodePath:
	get: return character.get_path() if character else NodePath()
	set(new_character_path):
		if new_character_path == _character_path: return
		if character or _character_path.is_empty(): return
		await get_tree().process_frame
		character = get_node(_character_path)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	#if multiplayer.multiplayer_peer: is_local_player = player_id == multiplayer.get_unique_id()
	#else:
		#player_id = Multiplayer.HOST_ID
		#is_local_player = true
	Serializer.mark_all_child_serializers_for(self, PropertiesSerializer.Type.INTANGIBLE)
	_collect_input()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	_collect_input()

static func read_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

static func create(existing_character: Character = null) -> Player:
	var new_player: Player = PLAYER_SCENE.instantiate()
	if existing_character: new_player.character = existing_character
	return new_player

static func from_player_info(player_info: Dictionary[StringName, Variant]) -> Player:
	validate_player_info(player_info)
	var new_player_id: int = player_info[ID]
	var new_player_name: String = player_info[NAME]
	var new_player: Player = Player.create()
	new_player.player_id = new_player_id
	new_player.player_name = new_player_name
	return new_player

static func validate_player_info(player_info: Dictionary[StringName, Variant]) -> void:
	assert(player_info.has_all([ID, NAME]))
	assert(player_info.size() == 2)

func get_player_info() -> Dictionary[StringName, Variant]:
	var player_info: Dictionary[StringName, Variant] = {
		ID: player_id,
		NAME: player_name if not player_name.is_empty() else "Player %d" % player_id,
	}
	validate_player_info(player_info)
	return player_info

func get_camera_adjusted_direction_input() -> Vector2:
	var viewport_camera: Camera3D = get_viewport().get_camera_3d()
	var camera_forward: Vector3 = viewport_camera.transform.basis.z
	camera_forward.y = 0.0
	var camera_right: Vector3 = viewport_camera.transform.basis.x
	camera_right.y = 0.0
	var adjusted_input_vector: Vector3 = camera_forward.normalized() * direction_input.y + camera_right.normalized() * direction_input.x
	return Vector2(adjusted_input_vector.x, adjusted_input_vector.z)

func _setup_character() -> void:
	interaction_area.character = character

func _collect_input() -> void:
	if not is_local_player: return
	# Only collect input if this is the local [Player]
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
	if not default_phantom_camera: warnings.append("Missing default PhantomCamera3D reference.")
	if not haunt_phantom_camera: warnings.append("Missing haunt PhantomCamera3D reference.")
	if not interaction_area: warnings.append("Missing InteractionArea reference.")
	if not _camera: warnings.append("Missing Camera3D reference.")
	return warnings
