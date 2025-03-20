class_name InputSynchronizer
extends MultiplayerSynchronizer

var input_direction := Vector2.ZERO

func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		return
	_collect_input()

func _process(_delta: float) -> void:
	_collect_input()

func _collect_input() -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
