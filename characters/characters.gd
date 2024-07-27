extends Node3D

@export var _character_scene: PackedScene = null
@export var _spawn_radius := 10.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_spawn_character"):
		if multiplayer.is_server():
			_spawn_character()
		else:
			_spawn_character.rpc()
		get_viewport().set_input_as_handled()

#@rpc("any_peer", "reliable")
func _spawn_character() -> void:
	if not _character_scene:
		printerr("No character scene specified!")
		return
	var character: Node3D = _character_scene.instantiate()
	var spawn_position := Vector2.from_angle(randf() * TAU)
	character.position = Vector3(spawn_position.x * _spawn_radius * randf(), 0, spawn_position.y * _spawn_radius * randf())
	add_child(character, true)
