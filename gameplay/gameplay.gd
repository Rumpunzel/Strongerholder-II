@icon("uid://csn6gjpak3yxk")
extends Node

@warning_ignore_start("unused_signal")
signal request_agent_for_character_controller(character_controller: CharacterController)
signal character_controller_haunted(haunted_character_controller: CharacterController, haunting_character_controller: CharacterController)
signal character_controller_unhaunted(unhaunted_character_controller: CharacterController)
@warning_ignore_restore("unused_signal")

@onready var _heads_up_displays: HeadsUpDisplays = _initialize_heads_up_displays()

func update_available_actions(available_actions: Array[CharacterInteraction]) -> void:
	_heads_up_displays.update_available_actions(available_actions)

static func _initialize_heads_up_displays() -> HeadsUpDisplays:
	var heads_up_displays_scene: PackedScene = preload("uid://rdlta1e1aqkb")
	var heads_up_displays: HeadsUpDisplays = heads_up_displays_scene.instantiate()
	Game.add_child(heads_up_displays)
	return heads_up_displays
