@icon("uid://csn6gjpak3yxk")
extends Node

@warning_ignore_start("unused_signal")
signal request_agent_for_character_controller(character_controller: CharacterController)
signal character_controller_haunted(haunted_character_controller: CharacterController, haunting_character_controller: CharacterController)
signal character_controller_unhaunted(unhaunted_character_controller: CharacterController)
@warning_ignore_restore("unused_signal")

@onready var _hud: HUD = _initialize_heads_up_displays()

func update_available_actions(available_actions: Array[CharacterInteraction]) -> void:
	_hud.update_available_actions(available_actions)

static func _initialize_heads_up_displays() -> HUD:
	var hud_scene: PackedScene = preload("uid://rdlta1e1aqkb")
	var hud: HUD = hud_scene.instantiate()
	Game.add_child(hud)
	return hud
