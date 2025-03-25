@icon("uid://csn6gjpak3yxk")
extends Node

@warning_ignore_start("unused_signal")
signal request_agent_for_character_controller(character_controller: CharacterController)
signal available_action_changed(available_actions: Array[StringName], heads_up_anchor: HeadsUpAnchor)
@warning_ignore_restore("unused_signal")
