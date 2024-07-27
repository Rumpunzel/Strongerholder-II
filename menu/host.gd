extends VBoxContainer

@onready var _ip_address: Button = $IPAddress

func _on_game_hosted(hosting: bool) -> void:
	if hosting:
		Multiplayer.host_game()
	_ip_address.visible = hosting
	Game.start_game()
