@tool
@icon("uid://c8dtrg5rbcbl5")
class_name CharacterSpawner
extends Spawner

@export_group("Configuration")

func _ready() -> void:
	Game.character_created.connect(_on_character_created)
	super._ready()

func _on_character_created(character: Character) -> void:
	spawn_node.add_child(character, true)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
