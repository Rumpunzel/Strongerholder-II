class_name DefaultAgentState
extends AgentState

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	Gameplay.character_controller_haunted.connect(_on_character_controller_haunted)
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	Gameplay.character_controller_haunted.disconnect(_on_character_controller_haunted)

func _on_character_controller_haunted(haunted_character_controller: CharacterController, haunting_character_controller: CharacterController) -> void:
	if haunted_character_controller != agent.character_controller: return
	finished.emit(HauntedAgentState.new(haunted_character_controller, haunting_character_controller))
