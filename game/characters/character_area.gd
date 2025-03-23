@tool
class_name CharacterArea
extends Area3D

signal hit_box_entered(hit_box: HitBox)
signal hit_box_exited(hit_box: HitBox)

@export var character: Character:
	set(new_character):
		character = new_character
		if not character:
			_collision_shape.shape = null
			return
		_setup_collision_shape()

@export_group("Configuration")
@export var _collision_shape: CollisionShape3D

var hit_boxes_in_area: Array[HitBox] = [ ]

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func follow_node(node: Node3D) -> void:
	transform = node.transform

func _setup_collision_shape() -> void:
	assert(false, "CharacterArea._setup_collision_shape is 'abstract' and needs to be overriden!")

func _on_area_entered(area: Area3D) -> void:
	if not area is HitBox: return
	hit_boxes_in_area.append(area)
	hit_box_entered.emit(area)

func _on_area_exited(area: Area3D) -> void:
	if not area is HitBox: return
	hit_boxes_in_area.erase(area)
	hit_box_exited.emit(area)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _collision_shape: warnings.append("Missing CollisionShape reference.")
	return warnings
