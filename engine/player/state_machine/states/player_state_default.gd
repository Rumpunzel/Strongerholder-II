class_name DefaultPlayerState
extends PlayerState

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	default_phantom_camera.priority = get_active_camera_priority()
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	var available_action: CharacterInteraction = get_available_action()
	if not available_action: return
	if available_action.is_action_just_pressed():
		_on_haunt_timer_timeout()
		#_haunt_timer.start(available_action.type.charge_time)
	#if available_action.is_action_just_released():
		#_haunt_timer.stop()

func physics_update(delta: float) -> void:
	apply_input_direction(delta)

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	default_phantom_camera.priority = get_default_camera_priority()

func _on_haunt_timer_timeout() -> void:
	var available_action: CharacterInteraction = get_available_action()
	assert(available_action)
	finished.emit(HauntingPlayerState.new(available_action.target, get_character()))
