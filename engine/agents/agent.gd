@tool
@icon("uid://dv6mpdxcuq5j5")
class_name Agent
extends Node

const CHARACTER_DATA: StringName = "character_data"

const AGENT_SCENE: PackedScene = preload("uid://bbjgxgkshjet6")

@export var character: Character

@export_group("Configuration")
@export var _state_machine: AgentStateMachine

static func create(character_data: Dictionary[StringName, Variant]) -> Agent:
	var new_agent: Agent = AGENT_SCENE.instantiate()
	new_agent.character.apply_character_data(character_data)
	return new_agent

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_state_machine.start()

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_state_machine.update(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_state_machine.physics_update(delta)

static func validate_agent_data(agent_data: Dictionary[StringName, Variant]) -> void:
	assert(agent_data.has_all([CHARACTER_DATA]))
	assert(agent_data.size() == 1)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _state_machine: warnings.append("Missing AgentStateMachine reference.")
	return warnings
