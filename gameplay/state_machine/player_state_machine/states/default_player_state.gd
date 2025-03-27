class_name DefaultPlayerState
extends PlayerState

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	print("enter")
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	if not available_action: return
	if available_action.is_action_just_pressed():
		print("here")
		_on_haunt_timer_timeout()
		#_haunt_timer.start(available_action.type.charge_time)
	#if available_action.is_action_just_released():
		#_haunt_timer.stop()

func physics_update(delta: float) -> void:
	apply_input_direction(delta)
	camera.frame_node(character_controller)

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	pass

func _on_haunt_timer_timeout() -> void:
	assert(available_action)
	print("there")
	finished.emit(HauntingPlayerState.new(available_action.target, character_controller))
