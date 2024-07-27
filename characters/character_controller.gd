class_name CharacterController
extends CharacterBody3D

@export var controlled_by: String = ""

@export var _move_speed := 8.0
@export var _jump_velocity := 8.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#region Player controls.
	if not controlled_by.is_empty():
		var player := get_controlling_player()
		# Handle jump.
		if player.get_jump_input() and is_on_floor():
			velocity.y = _jump_velocity
		# Reset jump state.
		player.set_jump_input(false)
		
		var direction := (transform.basis * player.get_movement_input()).normalized()
		if direction:
			velocity.x = direction.x * _move_speed
			velocity.z = direction.z * _move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, _move_speed)
			velocity.z = move_toward(velocity.z, 0, _move_speed)
	#endregion
	
	move_and_slide()

func get_controlling_player() -> Player:
	return get_node(controlled_by)

@rpc("any_peer", "reliable")
func set_controlling_player(new_player: String) -> void:
	controlled_by = new_player
	print_debug("Setting controlling player for %s to %s" % [ self.name, new_player ])

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void :
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.is_pressed() and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			EventsGameplay.node_clicked.emit(self, mouse_event)
