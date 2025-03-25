@tool
class_name CharacterArea
extends Area3D

signal hit_box_entered(hit_box: HitBox)
signal hit_box_exited(hit_box: HitBox)

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		_check_enabled()
		_clean_hit_boxes_in_area()
		if not character_controller:
			_character = null
			_world_character = null
			return
		_character = character_controller.character
		_world_character = character_controller.world_character

@export var _ignore_areas_from_same_character_controller: bool = true

@export_group("Configuration")
@export var _debub_color: Color = Color("0099b36b")

var _character: Character:
	set(new_character):
		_character = new_character
		if not _character:
			_collision_shape = null
			return
		_setup_collision_shape()

var _world_character: WorldCharacter

var _collision_shape: CollisionShape3D:
	set(new_collision_shape):
		if _collision_shape: _collision_shape.queue_free()
		_collision_shape = new_collision_shape
		if not _collision_shape: return
		add_child(_collision_shape, true)

var _hit_boxes_in_area: Array[HitBox] = [ ]

func follow_node(node: Node3D) -> void:
	transform = node.transform

func apply_material_override(material: Material) -> void:
	if not _world_character: return
	_world_character.apply_material_override(material)

func apply_material_overlay(material: Material) -> void:
	if not _world_character: return
	_world_character.apply_material_overlay(material)

func _check_enabled() -> void:
	if Engine.is_editor_hint(): return
	var is_enabled: bool = character_controller != null
	monitoring = is_enabled
	monitorable = is_enabled

func _clean_hit_boxes_in_area() -> void:
	if _hit_boxes_in_area.is_empty(): return
	var cleaned_hit_boxes_in_area: Array[HitBox] = [ ]
	var removed_hit_boxes_in_area: Array[HitBox] = [ ]
	for hit_box: HitBox in _hit_boxes_in_area:
		if _is_ignored(hit_box): removed_hit_boxes_in_area.append(hit_box)
		else: cleaned_hit_boxes_in_area.append(hit_box)
	_hit_boxes_in_area = cleaned_hit_boxes_in_area
	for hit_box: HitBox in removed_hit_boxes_in_area:
		hit_box_exited.emit(hit_box)

func _setup_collision_shape() -> void:
	_collision_shape.debug_color = _debub_color

func _is_ignored(hit_box: HitBox) -> bool:
	return _ignore_areas_from_same_character_controller and hit_box.character_controller == character_controller

func _on_area_entered(area: Area3D) -> void:
	if not area is HitBox: return
	var hit_box: HitBox = area
	if _is_ignored(hit_box): return
	var index_to_insert: int = 0
	for index: int in _hit_boxes_in_area.size():
		var hit_box_in_are: HitBox = _hit_boxes_in_area[index]
		if position.distance_squared_to(hit_box.position) > position.distance_squared_to(hit_box_in_are.position):
			index_to_insert = index
			break
	_hit_boxes_in_area.insert(index_to_insert, area)
	hit_box_entered.emit(area)

func _on_area_exited(area: Area3D) -> void:
	if not area is HitBox: return
	var hit_box: HitBox = area
	if _is_ignored(hit_box): return
	_hit_boxes_in_area.erase(hit_box)
	hit_box_exited.emit(hit_box)
