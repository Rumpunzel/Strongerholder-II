@tool
@icon("uid://ne8n58y4wim8")
class_name AgentSpawner
extends Spawner

signal agent_created(agent: Agent)

@export_group("Configuration")
@export var _character_spawner: CharacterSpawner

var _agents: Dictionary[Character, Agent] = {}

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return
	spawn_function = _spawn_agent

func spawn_all_from_spawn_spoints() -> Dictionary[Character, Agent]:
	var all_character_spawn_points: Array[Node] = get_tree().get_nodes_in_group("CharacterSpawnPoints")
	for character_spawn_point: CharacterSpawnPoint in all_character_spawn_points:
		var character_data: Dictionary[StringName, Variant] = character_spawn_point.get_character_data()
		spawn_agent(character_data)
	return _agents

func spawn_agent(character_data: Dictionary[StringName, Variant]) -> void:
	var character: Character = _character_spawner.spawn(character_data)
	var agent_data: Dictionary[StringName, Variant] = {
		Agent.CHARACTER_PATH: character.get_path(),
	}
	Agent.validate_agent_data(agent_data)
	spawn(agent_data)

func remove_agent(character: Character) -> void:
	var agent_to_remove: Agent = _agents[character]
	assert(agent_to_remove.character == character)
	_agents.erase(character)
	agent_to_remove.queue_free()
	character.queue_free()

func _spawn_agent(agent_data: Dictionary[StringName, Variant]) -> Agent:
	Agent.validate_agent_data(agent_data)
	var character_path: NodePath = agent_data[Agent.CHARACTER_PATH]
	var character: Character = get_node(character_path)
	var agent: Agent = Agent.create(character)
	agent_created.emit(agent)
	return agent

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _character_spawner: warnings.append("Missing CharacterSpawner reference.")
	return warnings
