@tool
@icon("uid://cscgs7miwut5n")
class_name CharacterSpawnPoint
extends Marker3D

@export var character: Character
## Maximum number of [CharacterController]s allowed to be spawned by this [CharacterSpawnPoint]
## When set to [code]<=0[/code], there is no limit
@export var spawn_limit: int = 0
@export var spawn_with_agent: bool = true

@export_group("Configuration")
@export var _editor_material: Material = preload("uid://dilpjt8kd3s4d")

var _character_controllers_spawned: int = 0

func spawn_character_controller(spawn_parent: Node) -> CharacterController:
	if spawn_limit > 0 and _character_controllers_spawned >= spawn_limit:
		push_warning("Trying to spawn a CharacterController but reached spawn limit already!")
		return
	var character_controller: CharacterController
	if spawn_with_agent and not Engine.is_editor_hint():
		character_controller = character.create(transform)
	else: character_controller= character.create_dummy(transform)
	spawn_parent.add_child(character_controller, true)
	if Engine.is_editor_hint():
		if _editor_material: character_controller.world_character.apply_material_override(_editor_material)
		return character_controller
	_character_controllers_spawned += 1
	return character_controller
