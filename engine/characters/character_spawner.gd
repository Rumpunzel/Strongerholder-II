@tool
@icon("uid://c8dtrg5rbcbl5")
class_name CharacterSpawner
extends Spawner

@export_group("Configuration")
@export var _character_spawn_points: CharacterSpawnPoints

func _ready() -> void:
	assert(_character_spawn_points)
	Game.character_created.connect(_on_character_created)
	_character_spawn_points.spawn_all_characters(spawn_node)
	super._ready()

func _on_character_created(character: Character) -> void:
	spawn_node.add_child(character, true)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _character_spawn_points: warnings.append("Missing CharacterSpawnPoints reference.")
	return warnings
