class_name CharacterModel
extends Node3D

@export var animation_player: AnimationPlayer
@export var animation_tree: AnimationTree

func play_animation(velocity: Vector3, is_on_floor: bool) -> void:
	if velocity:
		animation_player.play("Run")
	else:
		animation_player.play("Idle")
