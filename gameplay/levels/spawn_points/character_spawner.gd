@tool
@icon("uid://c8dtrg5rbcbl5")
class_name CharacterSpawner
extends BetterMultiplayerSpawner

@export_group("Configuration")
@export var _character_spawn_points: CharacterSpawnPoints

func _ready() -> void:
	assert(_character_spawn_points)
	_character_spawn_points.spawn_all_character_controllers(spawn_node)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _character_spawn_points: warnings.append("Missing CharacterSpawnPoints reference.")
	return warnings
