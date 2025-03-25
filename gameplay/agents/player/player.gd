@tool
@icon("uid://nl71yast8tsi")
class_name Player
extends Agent

const PLAYER_SCENE: PackedScene = preload("uid://ckcrpkujohkql")

@export_group("Configuration")
@export var _camera: TopDownCamera
@export var _interaction_area: InteractionArea

var is_local_player: bool = true:
	set(new_is_local_player):
		is_local_player = new_is_local_player
		if _camera: _camera.current = is_local_player

var direction_input: Vector2 = Vector2.ZERO
var interaction_input: StringName = ""
var available_action: CharacterInteraction:
	set(new_current_interactable):
		available_action = new_current_interactable
		var available_actions: Array[CharacterInteraction] = [ ]
		if available_action: available_actions.append(available_action)
		Gameplay.available_action_changed.emit(available_actions)

func _ready() -> void:
	_setup_player()
	super._ready()

func _process(delta: float) -> void:
	_update_player(delta)
	super._process(delta)

static func create(existing_character_controller: CharacterController) -> Player:
	var new_player: Player = PLAYER_SCENE.instantiate()
	new_player.character_controller = existing_character_controller
	return new_player

static func read_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func update_character_controller(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if is_disabled: return
	_apply_input_direction_to_character_controller(delta)
	# TODO: Pathfinding
	# else: super._update_character_controller(delta)
	if not is_local_player: return
	# Other code

func haunt_character_controller(haunted_character_controller: CharacterController) -> void:
	character_controller = haunted_character_controller

func unhaunt_character_controller(haunting_character_controller: CharacterController) -> void:
	character_controller = haunting_character_controller

func _setup_player() -> void:
	if Engine.is_editor_hint(): return
	_collect_input()

func _update_player(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	_collect_input()
	if is_disabled: return
	_camera.frame_node(character_controller)
	_interaction_area.follow_node(character_controller)
	if not is_local_player: return
	# Other code

func _setup_character_controller() -> void:
	_interaction_area.character_controller = character_controller
	super._setup_character_controller()

func _collect_input() -> void:
	if not is_local_player: return
	# Only collect input if this is the local [Player]
	direction_input = read_movement_input()
	interaction_input = ""
	if Input.is_action_pressed("interact"): interaction_input = "interact"
	elif Input.is_action_pressed("unpossess"): interaction_input = "unpossess"

func _apply_input_direction_to_character_controller(delta: float) -> void:
	assert(character_controller)
	var move_speed: float = character_controller.character.move_speed
	var acceleration: float = character_controller.character.acceleration * delta
	var velocity: Vector3 = character_controller.velocity
	if direction_input:
		var adjusted_direction_input: Vector2 = _camera.get_adjusted_movement(direction_input)
		velocity.x = move_toward(velocity.x, adjusted_direction_input.x * move_speed, acceleration)
		velocity.z = move_toward(velocity.z, adjusted_direction_input.y * move_speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration)
		velocity.z = move_toward(velocity.z, 0.0, acceleration)
	character_controller.velocity = velocity

func _create_character_interaction(for_hit_box: HitBox) -> CharacterInteraction:
	return CharacterInteraction.new(
		character_controller,
		for_hit_box.character_controller,
		preload("uid://cuoqy5wkfjika"),
	)

func _check_disabled() -> void:
	if Engine.is_editor_hint(): return
	is_disabled = not character_controller

func _on_interaction_area_current_interactable_changed(current_interactable: HitBox) -> void:
	if not current_interactable:
		available_action = null
		return
	available_action = _create_character_interaction(current_interactable)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _camera: warnings.append("Missing Camera reference.")
	if not _interaction_area: warnings.append("Missing InteractionArea reference.")
	return warnings + super._get_configuration_warnings()
