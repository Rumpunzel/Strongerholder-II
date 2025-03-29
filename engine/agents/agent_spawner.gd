@tool
@icon("uid://ne8n58y4wim8")
class_name AgentSpawner
extends Spawner

signal agent_created

@export_group("Configuration")

var _agents: Dictionary[Character, Agent] = {}

func _ready() -> void:
	super._ready()
	await get_tree().process_frame
	spawn_all_from_spawn_spoints()

func spawn_all_from_spawn_spoints() -> Dictionary[Character, Agent]:
	print("here")
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
	agent_created.emit(new_agent)

func remove_player_ghost(character: Character) -> void:
	var agent_to_remove: Agent = _agents[character]
	_agents.erase(character)
	agent_to_remove.character.queue_free()
	agent_to_remove.queue_free()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
