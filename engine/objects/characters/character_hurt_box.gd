@tool
@icon("uid://bykpbpoxx72ox")
class_name CharacterHurtBox
extends HurtBox

@export var character: Character

@export_group("Configuration")

func update_hitbox() -> void:
	assert(character)
	character.profile.hit_box_shape.configure_collision_shape(_collision_shape)

func get_body() -> Character:
	return character

func get_model() -> Model:
	return character.model

func get_heads_up_anchor() -> HeadsUpAnchor:
	return character.heads_up_anchor

func _on_character_profile_changed() -> void:
	update_hitbox()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not character: warnings.append("Missing Character reference.")
	return warnings + super._get_configuration_warnings()
