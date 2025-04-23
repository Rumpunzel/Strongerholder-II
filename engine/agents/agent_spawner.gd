@tool
@icon("uid://ne8n58y4wim8")
class_name AgentSpawner
extends Spawner

signal agent_created(agent: Agent)

@export_group("Configuration")

var _agents: Dictionary[Character, Agent] = {}

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return
	spawn_function = _spawn_agent

func spawn_all_from_spawn_spoints() -> Dictionary[Character, Agent]:
	assert(multiplayer.is_server())
	var all_character_spawn_points: Array[Node] = get_tree().get_nodes_in_group("CharacterSpawnPoints")
	for character_spawn_point: CharacterSpawnPoint in all_character_spawn_points:
		var character_data: Dictionary[StringName, Variant] = character_spawn_point.get_character_data()
		spawn_agent(character_data)
	return _agents

func spawn_agent(character_data: Dictionary[StringName, Variant]) -> void:
	assert(multiplayer.is_server())
	var agent_data: Dictionary[StringName, Variant] = {
		Agent.CHARACTER_DATA: character_data,
	}
	Agent.validate_agent_data(agent_data)
	spawn(agent_data)

func remove_all_agent() -> void:
	assert(multiplayer.is_server())
	for character: Character in _agents.keys():
		remove_agent(character)

func remove_agent(character: Character) -> void:
	assert(multiplayer.is_server())
	var agent_to_remove: Agent = _agents[character]
	assert(agent_to_remove.character == character)
	_agents.erase(character)
	agent_to_remove.queue_free()

func _spawn_agent(agent_data: Dictionary[StringName, Variant]) -> Agent:
	Agent.validate_agent_data(agent_data)
	var character_data: Dictionary[StringName, Variant] = agent_data[Agent.CHARACTER_DATA]
	var agent: Agent = Agent.create(character_data)
	_agents[agent.character] = agent
	agent_created.emit(agent)
	return agent

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
