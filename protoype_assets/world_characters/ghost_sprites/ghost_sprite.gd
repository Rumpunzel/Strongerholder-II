class_name GhostSprite
extends WorldCharacter

@onready var animated_sprite: AnimatedSprite3D = %AnimatedSprite3D

func _ready() -> void:
	animated_sprite.frame = randi() % 20

func play_animation(_normalized_velocity: Vector3) -> void:
	pass
