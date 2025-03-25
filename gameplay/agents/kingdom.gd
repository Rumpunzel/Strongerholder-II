@tool
class_name Kingdom
extends Node

@export_group("Configuration")
@export var _agents_node: Node

var _agents: Dictionary[CharacterController, Agent] = { }

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Gameplay.request_agent_for_character_controller.connect(create_agent)
	Gameplay.character_controller_possessed.connect(_on_character_controller_possessed)
	Gameplay.character_controller_unpossessed.connect(_on_character_controller_unpossessed)

func create_agent(character_controller: CharacterController) -> void:
	assert(character_controller)
	var new_agent: Agent = Agent.create(character_controller)
	_agents_node.add_child(new_agent, true)

func _on_character_controller_possessed(character_controller: CharacterController) -> void:
	var agent_for_character_controller: Agent = _agents.get(character_controller)
	if not agent_for_character_controller: push_warning("Possessed a CharacterController without Agent. If that was a dummy as intended, ignore.")
	agent_for_character_controller.character_controller = null

func _on_character_controller_unpossessed(character_controller: CharacterController) -> void:
	var agent_for_character_controller: Agent = _agents[character_controller]
	agent_for_character_controller.character_controller = character_controller

func _on_agent_entered_tree(agent: Agent) -> void:
	_agents[agent.character_controller] = agent

func _on_agent_exiting_tree(agent: Agent) -> void:
	_agents.erase(agent.character_controller)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _agents_node: warnings.append("Missing agents node reference.")
	return warnings
