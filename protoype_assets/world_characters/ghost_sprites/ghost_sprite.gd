@tool
@icon("uid://c8lah4qxw5f0v")
class_name GhostSprite
extends WorldCharacter

@onready var _animated_sprite: AnimatedSprite3D = %AnimatedSprite3D
@onready var _random_frame: int = -1:
	set(new_random_frame):
		if new_random_frame < 0: return
		_random_frame = new_random_frame
		_animated_sprite.frame = _random_frame

func _ready() -> void:
	if _random_frame < 0: _random_ghost()
	if Engine.is_editor_hint(): return
	EventBus.subscribe("random_ghost_requested", _random_ghost)

func play_animation(_normalized_velocity: Vector3) -> void:
	pass

func _random_ghost() -> void:
	_random_frame = randi() % 19
