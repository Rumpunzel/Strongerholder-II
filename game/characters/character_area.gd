@tool
class_name CharacterArea
extends Area3D

signal hit_box_entered(hit_box: HitBox)
signal hit_box_exited(hit_box: HitBox)

@export var character: Character:
	set(new_character):
		character = new_character
		if not character:
			collision_shape = null
			return
		_setup_collision_shape()

var collision_shape: CollisionShape3D:
	set(new_collision_shape):
		if collision_shape:
			if get_children().has(collision_shape): remove_child(collision_shape)
			collision_shape.queue_free()
		collision_shape = new_collision_shape
		if not collision_shape: return
		add_child.call_deferred(collision_shape, true)

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
