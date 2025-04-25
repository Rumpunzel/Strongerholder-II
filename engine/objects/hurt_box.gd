@tool
@icon("uid://bv63hb5gynt8d")
class_name HurtBox
extends Area3D

signal haunted(haunting: Character)
signal unhaunted

@export_group("Configuration")
@export var _collision_shape: CollisionShape3D

@rpc("any_peer", "call_local", "reliable")
func haunt(haunting_path: NodePath) -> void:
	var haunting: Character = get_node(haunting_path)
	assert(haunting)
	haunted.emit(haunting)

@rpc("any_peer", "call_local", "reliable")
func unhaunt() -> void:
	unhaunted.emit()

func get_body() -> Node3D:
	assert(false, "HurtBox.get_body is 'virtual' and needs to be overriden!")
	return null

func get_model() -> Model:
	assert(false, "HurtBox.get_model is 'virtual' and needs to be overriden!")
	return null

func get_heads_up_anchor() -> HeadsUpAnchor:
	assert(false, "HurtBox.get_heads_up_anchor is 'virtual' and needs to be overriden!")
	return null

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _collision_shape: warnings.append("Missing CollisionShape3D reference.")
	return warnings
