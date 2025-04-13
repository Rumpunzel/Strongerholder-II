@tool
@icon("uid://cscgs7miwut5n")
class_name CharacterSpawnPoint
extends Marker3D

@export var character_profile: CharacterProfile
## Maximum number of [Character]s allowed to be spawned by this [CharacterSpawnPoint]
## When set to [code]<=0[/code], there is no limit
@export var spawn_limit: int = 0
@export var spawn_with_agent: bool = true

@export_group("Configuration")
@export var _editor_material: Material = preload("uid://dilpjt8kd3s4d")

var _characters_spawned: int = 0

func _ready() -> void:
	add_to_group("CharacterSpawnPoints")
	if Engine.is_editor_hint():
		var character_model: CharacterModel = character_profile.create_character_model()
		if _editor_material: character_model.apply_material_override(_editor_material)
		add_child(character_model)

func spawn_character() -> Character:
	if spawn_limit > 0 and _characters_spawned >= spawn_limit:
		push_warning("Trying to spawn a Character but reached spawn limit already!")
		return null
	var character: Character = character_profile.create(transform)
	_characters_spawned += 1
	return character

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
