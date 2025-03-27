@tool
@icon("uid://c8dtrg5rbcbl5")
class_name CharacterSpawner
extends Spawner

@export_group("Configuration")
@export var _character_spawn_points: CharacterSpawnPoints

func _ready() -> void:
	assert(_character_spawn_points)
	_character_spawn_points.spawn_all_characters(spawn_node)
	super._ready()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _character_spawn_points: warnings.append("Missing CharacterSpawnPoints reference.")
	return warnings + super._get_configuration_warnings()
