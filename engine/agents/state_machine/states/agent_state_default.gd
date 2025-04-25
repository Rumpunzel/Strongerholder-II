class_name AgentStateDefault
extends AgentState

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	hurt_box.haunted.connect(_on_haunted)
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	hurt_box.haunted.disconnect(_on_haunted)

func _on_haunted(haunting: Character) -> void:
	finished.emit(AgentStateHaunted.new(haunting.get_path()))
