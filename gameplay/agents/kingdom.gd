@tool
class_name Kingdom
extends Node

@export_group("Configuration")
@export var _agents_node: Node

var _agents: Dictionary[Character, Agent] = {}

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Gameplay.request_agent_for_character.connect(create_agent)

func create_agent(character: Character) -> void:
	assert(character)
	var new_agent: Agent = Agent.create(character)
	_agents_node.add_child(new_agent, true)

func _on_agent_entered_tree(agent: Agent) -> void:
	_agents[agent.character] = agent

func _on_agent_exiting_tree(agent: Agent) -> void:
	_agents.erase(agent.character)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _agents_node: warnings.append("Missing agents node reference.")
	return warnings
