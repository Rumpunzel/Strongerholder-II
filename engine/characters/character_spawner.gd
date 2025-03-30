@tool
@icon("uid://c8dtrg5rbcbl5")
class_name CharacterSpawner
extends Spawner

@export_group("Configuration")

func _on_player_ghost_created(player_ghost: PlayerGhost) -> void:
	spawn_node.add_child(player_ghost.character, true)

func _on_agent_created(agent: Agent) -> void:
	spawn_node.add_child(agent.character, true)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
