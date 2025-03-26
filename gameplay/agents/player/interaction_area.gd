@tool
@icon("uid://bbvd8haxvdmk6")
class_name InteractionArea
extends Area3D

signal hit_box_entered(hit_box: HitBox)
signal hit_box_exited(hit_box: HitBox)

signal current_interactable_changed(current_interactable: HitBox)

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		_check_enabled()
		_clean_hit_boxes_in_area()
		if not character_controller: return
		if not character_controller.character:
			_collision_shape.shape = null
			_collision_shape.position = Vector3.ZERO
			return
		character_controller.character.interaction_area_shape.configure_collision_shape(_collision_shape)

@export var _ignore_areas_from_same_character_controller: bool = true

@export_group("Configuration")
@export var _collision_shape: CollisionShape3D
@export var _highlight_material: Material

var current_interactable: HitBox:
	set(new_current_interactable):
		if current_interactable: current_interactable.apply_material_overlay(null)
		current_interactable = new_current_interactable
		current_interactable_changed.emit(current_interactable)
		if not current_interactable: return
		current_interactable.apply_material_overlay(_highlight_material)

var _hit_boxes_in_area: Array[HitBox] = [ ]

func nearest_hit_box_in_area() -> HitBox:
	var nearest_hit_box: HitBox = null
	var distance_to_nearest_hit_box: float = INF
	for near_hit_box: HitBox in _hit_boxes_in_area:
		if not nearest_hit_box_in_area or _collision_shape.position.distance_squared_to(near_hit_box.position) < distance_to_nearest_hit_box:
			nearest_hit_box = near_hit_box
	return nearest_hit_box

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

func _check_enabled() -> void:
	if Engine.is_editor_hint(): return
	var is_enabled: bool = character_controller != null
	monitoring = is_enabled
	monitorable = is_enabled
	_collision_shape.disabled = not is_enabled

func _is_ignored(hit_box: HitBox) -> bool:
	return _ignore_areas_from_same_character_controller and hit_box.character_controller == character_controller

func _on_hit_box_entered(hit_box: HitBox) -> void:
	if current_interactable: return
	current_interactable = hit_box

func _on_hit_box_exited(hit_box: HitBox) -> void:
	if hit_box != current_interactable: return
	current_interactable = nearest_hit_box_in_area()

func _on_area_entered(area: Area3D) -> void:
	if not area is HitBox: return
	var hit_box: HitBox = area
	if _is_ignored(hit_box): return
	var index_to_insert: int = 0
	for index: int in _hit_boxes_in_area.size():
		var hit_box_in_are: HitBox = _hit_boxes_in_area[index]
		if _collision_shape.position.distance_squared_to(hit_box.position) > _collision_shape.position.distance_squared_to(hit_box_in_are.position):
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

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _collision_shape: warnings.append("Missing CollisionShape3D reference.")
	if not _highlight_material: warnings.append("Missing highlight material.")
	return warnings
