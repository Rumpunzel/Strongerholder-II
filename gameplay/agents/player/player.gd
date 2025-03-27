@tool
@icon("uid://nl71yast8tsi")
class_name Player
extends Node

signal player_info_changed(player_info: Dictionary[StringName, Variant])

const ID: StringName = "player_id"
const NAME: StringName = "player_name"

const PLAYER_SCENE: PackedScene = preload("uid://ckcrpkujohkql")

@export var player_id: int = PlayerLobby.HOST_ID:
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

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		if not character_controller: return
		if not is_node_ready(): await ready
		camera.frame_node(character_controller, true)

@export_group("Configuration")
@export var camera: TopDownCamera
@export var interaction_area: InteractionArea

var direction_input: Vector2 = Vector2.ZERO
var interaction_input: StringName = ""
var available_action: CharacterInteraction:
	set(new_current_interactable):
		available_action = new_current_interactable
		var available_actions: Array[CharacterInteraction] = [ ]
		if available_action: available_actions.append(available_action)
		Gameplay.update_available_actions(available_actions)

var is_local_player: bool = true:
	set(new_is_local_player):
		is_local_player = new_is_local_player
		camera.current = is_local_player

## This is used for serialization purposes; serves otherwise no purpose
var _character_controller_path: NodePath:
	get: return character_controller.get_path() if character_controller else NodePath()
	set(new_character_controller_path):
		if new_character_controller_path == _character_controller_path: return
		if character_controller or _character_controller_path.is_empty(): return
		await get_tree().process_frame
		character_controller = get_node(_character_controller_path)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	#if multiplayer.multiplayer_peer: is_local_player = player_id == multiplayer.get_unique_id()
	#else:
		#player_id = PlayerLobby.HOST_ID
		#is_local_player = true
	Serializer.mark_all_child_serializers_for(self, PropertiesSerializer.Type.INTANGIBLE)
	#camera.frame_node(character_controller, true)
	_collect_input()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		camera.frame_node(character_controller, true)
		return
	_collect_input()
	if not is_local_player: return
	# Other code

static func read_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

static func create(existing_character_controller: CharacterController = null) -> Player:
	var new_player: Player = PLAYER_SCENE.instantiate()
	if existing_character_controller: new_player.character_controller = existing_character_controller
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

func _setup_character_controller() -> void:
	interaction_area.character_controller = character_controller

func _collect_input() -> void:
	if not is_local_player: return
	# Only collect input if this is the local [Player]
	direction_input = read_movement_input()
	interaction_input = ""
	if Input.is_action_pressed("interact"): interaction_input = "interact"
	elif Input.is_action_pressed("unpossess"): interaction_input = "unpossess"

func _create_character_interaction(for_hit_box: HitBox) -> CharacterInteraction:
	return CharacterInteraction.new(
		character_controller,
		for_hit_box.character_controller,
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
	var warnings: PackedStringArray = [ ]
	if not camera: warnings.append("Missing Camera reference.")
	if not interaction_area: warnings.append("Missing InteractionArea reference.")
	return warnings
