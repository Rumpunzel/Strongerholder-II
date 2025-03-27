class_name DefaultAgentState
extends AgentState

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	Gameplay.character_haunted.connect(_on_character_haunted)
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	Gameplay.character_haunted.disconnect(_on_character_haunted)

func _on_character_haunted(haunted_character: Character, haunting_character: Character) -> void:
	if haunted_character != agent.character: return
	finished.emit(HauntedAgentState.new(haunted_character, haunting_character))
