class_name AgentStateDefault
extends AgentState

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	get_character().haunted.connect(_on_character_haunted)
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	get_character().haunted.disconnect(_on_character_haunted)

func _on_character_haunted(haunted_character: Character, haunting_character: Character) -> void:
	if haunted_character != agent.character: return
	finished.emit(AgentStateHaunted.new(haunted_character, haunting_character))
