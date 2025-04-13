@tool
@icon("uid://ne8n58y4wim8")
class_name AgentSpawner
extends Spawner

signal agent_created(agent: Agent)

@export_group("Configuration")
@export var _character_spawner: CharacterSpawner

var _agents: Dictionary[Character, Agent] = {}

func spawn_all_from_spawn_spoints() -> Dictionary[Character, Agent]:
	var all_character_spawn_points: Array[Node] = get_tree().get_nodes_in_group("CharacterSpawnPoints")
	for character_spawn_point: CharacterSpawnPoint in all_character_spawn_points:
		var new_character: Character = character_spawn_point.spawn_character()
		if not new_character: continue
		create_agent(new_character)
	return _agents

func create_agent(character: Character) -> void:
	assert(character)
	var new_agent: Agent = Agent.create(character)
	spawn_node.add_child(new_agent, true)
	_agents[character] = new_agent
	_character_spawner.spawn_character(character)
	agent_created.emit(new_agent)

func remove_player_ghost(character: Character) -> void:
	var agent_to_remove: Agent = _agents[character]
	_agents.erase(character)
	agent_to_remove.character.queue_free()
	agent_to_remove.queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _character_spawner: warnings.append("Missing CharacterSpawner reference.")
	return warnings
