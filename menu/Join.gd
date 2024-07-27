extends HBoxContainer

@onready var _join_game_button: Button = $JoinGame
@onready var _ip_address_input: LineEdit = $IPAddress

func _ready() -> void:
	Multiplayer.game_hosted.connect(_on_game_hosted)

func _on_game_hosted() -> void:
	var hosting := true
	_join_game_button.disabled = hosting
	_ip_address_input.editable = not hosting
	_ip_address_input.focus_mode = Control.FOCUS_NONE if hosting else Control.FOCUS_ALL

func _on_game_joined() -> void:
	var ip_address := _ip_address_input.text if not _ip_address_input.text.is_empty() else _ip_address_input.placeholder_text
	Multiplayer.connect_to_game(ip_address)
	Game.start_game()
