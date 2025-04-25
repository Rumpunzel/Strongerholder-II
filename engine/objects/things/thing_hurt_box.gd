@tool
@icon("uid://bv63hb5gynt8d")
class_name ThingHurtBox
extends HurtBox

@export var thing: Thing

@export_group("Configuration")

func update_hitbox() -> void:
	assert(thing)
	thing.profile.hit_box_shape.configure_collision_shape(_collision_shape)

func get_body() -> Thing:
	return thing

func get_model() -> Model:
	return thing.model

func get_heads_up_anchor() -> HeadsUpAnchor:
	return thing.heads_up_anchor

func _on_profile_changed() -> void:
	update_hitbox()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not thing: warnings.append("Missing Thing reference.")
	return warnings + super._get_configuration_warnings()
