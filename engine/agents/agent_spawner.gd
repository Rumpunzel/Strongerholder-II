@tool
@icon("uid://ne8n58y4wim8")
class_name AgentSpawner
extends Spawner

@export_group("Configuration")

var _agents: Dictionary[Character, Agent] = {}

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Game.character_created.connect(create_agent)

func create_agent(character: Character) -> void:
	assert(character)
	var new_agent: Agent = Agent.create(character)
	spawn_node.add_child(new_agent, true)
	_agents[character] = new_agent

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
