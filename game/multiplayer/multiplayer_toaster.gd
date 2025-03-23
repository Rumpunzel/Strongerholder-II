extends Toaster

func _on_multiplayer_session_started(_player: Player) -> void:
	toast_success("Hosted game!")

func _on_multiplayer_session_stopped(_existing_player: Player) -> void:
	toast_info("Left multiplayer!")

func _on_player_joined(player: SynchronizedPlayer) -> void:
	toast_success("%s joined!" % player.player_name)

func _on_player_disconnected(_peer_id: int, player: SynchronizedPlayer) -> void:
	toast_warning("%s left!" % player.player_name)
