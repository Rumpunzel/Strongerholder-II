extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		Game.game_started.connect(_on_game_started)

func _exit_tree() -> void:
	if multiplayer.is_server():
		Game.game_started.disconnect(_on_game_started)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Call this function deferred and only on the main authority (server).
func change_level(new_level: PackedScene) -> void:
	# Remove old level if any.
	for level in get_children():
		remove_child(level)
		level.queue_free()
	# Add new level.
	add_child(new_level.instantiate())

func _on_game_started() -> void:
	change_level.call_deferred(load("res://levels/test_level.tscn"))
