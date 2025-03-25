@tool
class_name Kingdom
extends Node

@export_group("Configuration")
@export var _agents: Node

func _ready() -> void:
	Gameplay.request_agent_for_character_controller.connect(create_agent)

func create_agent(character_controller: CharacterController) -> void:
	assert(character_controller)
	var new_agent: Agent = Agent.create(character_controller)
	_agents.add_child(new_agent, true)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _agents: warnings.append("Missing Agents reference.")
	return warnings
