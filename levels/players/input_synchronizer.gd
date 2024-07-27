class_name InputSynchronizer
extends MultiplayerSynchronizer

# Synchronized property.
@export var input_vector := Vector2.ZERO
# Set via RPC to simulate is_action_just_pressed.
@export var jump_input := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var is_local := is_multiplayer_authority()
	# Only process for the local player.
	set_process_input(is_local)
	set_physics_process(is_local)
	set_process(is_local)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var horizonal_input := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var vertical_input := Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = Vector2(horizonal_input, vertical_input)
	if Input.is_action_pressed("ui_accept"):
		_jump.rpc()

@rpc("call_local", "reliable")
func _jump() -> void:
	jump_input = true
