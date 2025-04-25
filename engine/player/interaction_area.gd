@tool
@icon("uid://bbvd8haxvdmk6")
class_name InteractionArea
extends Area3D

signal current_interactable_changed(current_interactable: HurtBox)
signal available_actions_changed(available_actions: Array[Interaction])

@export var character: Character:
	set(new_character):
		assert(new_character)
		character = new_character
		character.profile.interaction_area_shape.configure_collision_shape(_collision_shape)

@export_group("Configuration")
@export var _collision_shape: CollisionShape3D
@export var _highlight_material: Material

var current_interactable: HurtBox:
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

var _hurt_boxes_in_area: Array[HurtBox] = []
var _hurt_boxes_to_ignore: Array[HurtBox] = []

func nearest_hurt_box_in_area() -> HurtBox:
	var nearest_hurt_box: HurtBox = null
	var distance_to_nearest_hurt_box: float = INF
	for hurt_box: HurtBox in _hurt_boxes_in_area:
		if _is_ignored(hurt_box): continue
		if not nearest_hurt_box or _collision_shape.position.distance_squared_to(hurt_box.position) < distance_to_nearest_hurt_box:
			nearest_hurt_box = hurt_box
	return nearest_hurt_box

func add_hurt_box_to_ignore(hurt_box: HurtBox) -> void:
	assert(not _hurt_boxes_to_ignore.has(hurt_box))
	_hurt_boxes_to_ignore.append(hurt_box)
	if current_interactable == hurt_box: current_interactable = nearest_hurt_box_in_area()

func remove_hurt_box_to_ignore(hurt_box: HurtBox) -> void:
	assert(_hurt_boxes_to_ignore.has(hurt_box))
	_hurt_boxes_to_ignore.erase(hurt_box)
	if not current_interactable: current_interactable = nearest_hurt_box_in_area()

func _is_ignored(hurt_box: HurtBox) -> bool:
	return _hurt_boxes_to_ignore.has(hurt_box)

var _haunt_action: Action = preload("uid://cuoqy5wkfjika")

func _create_interaction(for_hurt_box: HurtBox) -> Interaction:
	if not for_hurt_box: return Interaction.new(character, _haunt_action)
	if for_hurt_box is CharacterHurtBox: return _create_charcter_interaction(for_hurt_box as CharacterHurtBox)
	if for_hurt_box is ThingHurtBox: return _create_thing_interaction(for_hurt_box as ThingHurtBox)
	return null

func _create_charcter_interaction(for_hurt_box: CharacterHurtBox) -> CharacterInteraction:
	return CharacterInteraction.new(character, for_hurt_box, _haunt_action)

func _create_thing_interaction(for_hurt_box: ThingHurtBox) -> ThingInteraction:
	return ThingInteraction.new(character, for_hurt_box, _haunt_action)

func _on_area_entered(area: Area3D) -> void:
	if not area is HurtBox: return
	var hurt_box: HurtBox = area
	if hurt_box.get_body() == character: return
	var index_to_insert: int = 0
	for index: int in _hurt_boxes_in_area.size():
		var hurt_box_in_area: Node3D = _hurt_boxes_in_area[index]
		if _collision_shape.position.distance_squared_to(hurt_box.position) > _collision_shape.position.distance_squared_to(hurt_box_in_area.position):
			index_to_insert = index
			break
	_hurt_boxes_in_area.insert(index_to_insert, hurt_box)
	if _is_ignored(hurt_box): return
	if current_interactable: return
	current_interactable = hurt_box

func _on_area_exited(area: Area3D) -> void:
	if not area is HurtBox: return
	var hurt_box: HurtBox = area
	if hurt_box.get_body() == character: return
	_hurt_boxes_in_area.erase(hurt_box)
	if _is_ignored(hurt_box): return
	if current_interactable == hurt_box: current_interactable = nearest_hurt_box_in_area()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _collision_shape: warnings.append("Missing CollisionShape3D reference.")
	if not _highlight_material: warnings.append("Missing highlight material.")
	return warnings
