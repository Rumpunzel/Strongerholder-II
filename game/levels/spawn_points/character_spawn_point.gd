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

func spawn_character(spawn_parent: Node) -> Character:
	if spawn_limit > 0 and _characters_spawned >= spawn_limit:
		push_warning("Trying to spawn a Character but reached spawn limit already!")
		return
	var character: Character
	if spawn_with_agent and not Engine.is_editor_hint():
		character = character_profile.create(transform)
	else: character = character_profile.create_dummy(transform)
	spawn_parent.add_child(character, true)
	if Engine.is_editor_hint():
		if _editor_material: character.character_model.apply_material_override(_editor_material)
		return character
	_characters_spawned += 1
	return character
