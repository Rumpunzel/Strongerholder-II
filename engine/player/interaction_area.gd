@tool
@icon("uid://bbvd8haxvdmk6")
class_name InteractionArea
extends Area3D

signal current_interactable_changed(current_interactable: HitBox)
signal available_actions_changed(available_actions: Array[Interaction])

@export var character: Character:
	set(new_character):
		assert(new_character)
		character = new_character
		character.profile.interaction_area_shape.configure_collision_shape(_collision_shape)

@export_group("Configuration")
@export var _collision_shape: CollisionShape3D
@export var _highlight_material: Material

var current_interactable: HitBox:
	set(new_current_interactable):
		if new_current_interactable == current_interactable: return
		if current_interactable: current_interactable.get_model().apply_material_overlay(null)
		current_interactable = new_current_interactable
		current_interactable_changed.emit(current_interactable)
		if not current_interactable:
			available_action = null
			return
		available_action = _create_interaction(current_interactable)
		current_interactable.get_model().apply_material_overlay(_highlight_material)

var available_action: Interaction:
	set(new_current_interactable):
		available_action = new_current_interactable
		var available_actions: Array[Interaction] = []
		if available_action: available_actions.append(available_action)
		available_actions_changed.emit(available_actions)

var _hit_boxes_in_area: Array[HitBox] = []
var _hit_boxes_to_ignore: Array[HitBox] = []

func nearest_hit_box_in_area() -> HitBox:
	var nearest_hit_box: HitBox = null
	var distance_to_nearest_hit_box: float = INF
	for hit_box: HitBox in _hit_boxes_in_area:
		if _is_ignored(hit_box): continue
		if not nearest_hit_box or _collision_shape.position.distance_squared_to(hit_box.position) < distance_to_nearest_hit_box:
			nearest_hit_box = hit_box
	return nearest_hit_box

func add_hit_box_to_ignore(hit_box: HitBox) -> void:
	assert(not _hit_boxes_to_ignore.has(hit_box))
	_hit_boxes_to_ignore.append(hit_box)
	if current_interactable == hit_box: current_interactable = nearest_hit_box_in_area()

func remove_hit_box_to_ignore(hit_box: HitBox) -> void:
	assert(_hit_boxes_to_ignore.has(hit_box))
	_hit_boxes_to_ignore.erase(hit_box)
	if not current_interactable: current_interactable = nearest_hit_box_in_area()

func _is_ignored(hit_box: HitBox) -> bool:
	return _hit_boxes_to_ignore.has(hit_box)

var _haunt_action: Action = preload("uid://cuoqy5wkfjika")

func _create_interaction(for_hit_box: HitBox) -> Interaction:
	if not for_hit_box: return Interaction.new(character, _haunt_action)
	if for_hit_box is CharacterHitBox: return _create_charcter_interaction(for_hit_box as CharacterHitBox)
	if for_hit_box is ThingHitBox: return _create_thing_interaction(for_hit_box as ThingHitBox)
	return null

func _create_charcter_interaction(for_hit_box: CharacterHitBox) -> CharacterInteraction:
	return CharacterInteraction.new(character, for_hit_box, _haunt_action)

func _create_thing_interaction(for_hit_box: ThingHitBox) -> ThingInteraction:
	return ThingInteraction.new(character, for_hit_box, _haunt_action)

func _on_area_entered(area: Area3D) -> void:
	if not area is HitBox: return
	var hit_box: HitBox = area
	if hit_box.get_body() == character: return
	var index_to_insert: int = 0
	for index: int in _hit_boxes_in_area.size():
		var hit_box_in_area: Node3D = _hit_boxes_in_area[index]
		if _collision_shape.position.distance_squared_to(hit_box.position) > _collision_shape.position.distance_squared_to(hit_box_in_area.position):
			index_to_insert = index
			break
	_hit_boxes_in_area.insert(index_to_insert, hit_box)
	if _is_ignored(hit_box): return
	if current_interactable: return
	current_interactable = hit_box

func _on_area_exited(area: Area3D) -> void:
	if not area is HitBox: return
	var hit_box: HitBox = area
	if hit_box.get_body() == character: return
	_hit_boxes_in_area.erase(hit_box)
	if _is_ignored(hit_box): return
	if current_interactable == hit_box: current_interactable = nearest_hit_box_in_area()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _collision_shape: warnings.append("Missing CollisionShape3D reference.")
	if not _highlight_material: warnings.append("Missing highlight material.")
	return warnings
