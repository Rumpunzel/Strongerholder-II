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

@export_group("Configuration")
@export var _areas_to_ignore: Array[Area3D]
@export var _debub_color: Color = Color("0099b36b")

var collision_shape: CollisionShape3D:
	set(new_collision_shape):
		if collision_shape:
			if get_children().has(collision_shape): remove_child(collision_shape)
			collision_shape.queue_free()
		collision_shape = new_collision_shape
		if not collision_shape: return
		add_child.call_deferred(collision_shape, true)

var hit_boxes_in_area: Array[HitBox] = [ ]

func follow_node(node: Node3D) -> void:
	transform = node.transform

func _setup_collision_shape() -> void:
	collision_shape.debug_color = _debub_color

func _on_area_entered(area: Area3D) -> void:
	if not area is HitBox or _areas_to_ignore.has(area): return
	var index_to_insert: int = 0
	if not hit_boxes_in_area.is_empty():
		hit_boxes_in_area.find_custom(func(hit_box: HitBox) -> bool: return position.distance_squared_to(hit_box.position) < position.distance_squared_to(area.position))
	hit_boxes_in_area.insert(index_to_insert, area)
	hit_boxes_in_area.append(area)
	hit_box_entered.emit(area)

func _on_area_exited(area: Area3D) -> void:
	if not area is HitBox or _areas_to_ignore.has(area): return
	hit_boxes_in_area.erase(area)
	hit_box_exited.emit(area)
