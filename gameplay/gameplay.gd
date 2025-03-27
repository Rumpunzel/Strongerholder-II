@icon("uid://bes0anop2dh5u")
extends Node

signal save_requested(save_file_path: StringName)
signal load_requested(save_file_path: StringName)

@warning_ignore_start("unused_signal")
signal request_agent_for_character(character: Character)
signal character_haunted(haunted_character: Character, haunting_character: Character)
signal character_unhaunted(unhaunted_character: Character)
@warning_ignore_restore("unused_signal")

@onready var _hud: HUD = _initialize_heads_up_displays()

func request_save(save_file_path: StringName = Serializer.SAVE_FILE_PATH) -> void:
	save_requested.emit(save_file_path)

func request_load(save_file_path: StringName = Serializer.SAVE_FILE_PATH) -> void:
	load_requested.emit(save_file_path)

func update_available_actions(available_actions: Array[CharacterInteraction]) -> void:
	_hud.update_available_actions(available_actions)

static func _initialize_heads_up_displays() -> HUD:
	var hud_scene: PackedScene = preload("uid://rdlta1e1aqkb")
	var hud: HUD = hud_scene.instantiate()
	Gameplay.add_child(hud)
	return hud
