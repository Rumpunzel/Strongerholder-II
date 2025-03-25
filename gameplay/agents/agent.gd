@tool
@icon("uid://dv6mpdxcuq5j5")
class_name Agent
extends Node

const AGENT_SCENE: PackedScene = preload("uid://bbjgxgkshjet6")

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		_setup_character_controller()

@export_group("Configuration")
@export var _state_machine: StateMachine

var is_disabled: bool = false

## This is used for serialization purposes; serves otherwise no purpose
var _character_controller_path: NodePath:
	get: return character_controller.get_path() if character_controller else NodePath()
	set(new_character_controller_path):
		_character_controller_path = new_character_controller_path
		if character_controller or _character_controller_path.is_empty(): return
		await get_tree().process_frame
		character_controller = get_node(_character_controller_path)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_check_disabled()

func _process(delta: float) -> void:
	_udpate_agent(delta)

func _physics_process(delta: float) -> void:
	_update_character_controller(delta)

static func create(existing_character_controller: CharacterController) -> Agent:
	var new_agent: Agent = AGENT_SCENE.instantiate()
	new_agent.character_controller = existing_character_controller
	new_agent.name = existing_character_controller.name
	return new_agent

func _setup_character_controller() -> void:
	_check_disabled()

func _udpate_agent(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if is_disabled: return
	assert(character_controller)

func _update_character_controller(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if is_disabled: return
	assert(character_controller)
	# TODO: Pathfinding

func _check_disabled() -> void:
	if Engine.is_editor_hint(): return
	is_disabled = not character_controller

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _state_machine: warnings.append("Missing StateMachine reference.")
	return warnings
