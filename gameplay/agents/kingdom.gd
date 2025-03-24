@tool
class_name Kingdom
extends Node

const KINGDOM_SCENE: PackedScene = preload("uid://dromtcmsedm3r")

@export_group("Configuration")
@export var _agents: Node

static func create() -> Kingdom:
	return KINGDOM_SCENE.instantiate()

func create_agent(character_controller: CharacterController) -> void:
	assert(character_controller)
	var new_agent: Agent = Agent.create(character_controller)
	_agents.add_child(new_agent, true)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _agents: warnings.append("Missing Agents reference.")
	return warnings
