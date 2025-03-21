class_name Character
extends Resource

@export var name: String
@export_color_no_alpha var color: Color
@export var movement_attributes: MovementAttributes
@export var character_model: PackedScene

var _character_scene: PackedScene = preload("res://characters/character.tscn")

func create() -> CharacterController:
	assert(movement_attributes)
	assert(character_model)
	var character_controller: CharacterController = _character_scene.instantiate()
	character_controller.character = self
	return character_controller
