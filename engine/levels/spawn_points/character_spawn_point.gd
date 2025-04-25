@tool
@icon("uid://cscgs7miwut5n")
class_name CharacterSpawnPoint
extends Marker3D

@export var character_profile: CharacterProfile
## Determines the varation of the [Model]
## If [code]<0[/code] a random [Model] will be used
@export var variation: int = -1
## Maximum number of [Character]s allowed to be spawned by this [CharacterSpawnPoint]
## When set to [code]<=0[/code], there is no limit
@export var spawn_limit: int = 0
@export_enum("CharacterSpawnPoints", "PlayerSpawnPoints") var role: String = "CharacterSpawnPoints"

@export_group("Configuration")
@export var _editor_material: Material = preload("uid://dilpjt8kd3s4d")

var _characters_spawned: int = 0

func _enter_tree() -> void:
	add_to_group(role)

func _ready() -> void:
	if Engine.is_editor_hint():
		var character_model: Model = character_profile.create_model(variation)
		if _editor_material: character_model.apply_material_override(_editor_material)
		add_child(character_model)

func spawn_character() -> Character:
	if spawn_limit > 0 and _characters_spawned >= spawn_limit:
		push_warning("Trying to spawn a Character but reached spawn limit already!")
		return null
	var character: Character = character_profile.create(variation, transform)
	_characters_spawned += 1
	return character

func get_character_data() -> Dictionary[StringName, Variant]:
	var character_data: Dictionary[StringName, Variant] = {
		Character.VARIATION: variation,
		Character.CHARACTER_PROFILE_PATH: character_profile.resource_path,
		Character.SPAWN_TRANSFORM: transform,
	}
	Character.validate_character_data(character_data)
	return character_data

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
