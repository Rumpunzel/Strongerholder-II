class_name Menu
extends Control

@onready var _join_button: Button = %Join
@onready var _ip_address: LineEdit = %IpAddress
@onready var _host_button: Button = %Host
@onready var _host_ip_address_button: Button = %HostIpAddress

func _ready() -> void:
	Game.game_hosted.connect(_on_game_hosted)
	Game.stopped_hosting_game.connect(_on_stopped_hosting_game)
	Game.left_game.connect(_on_left_game)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("open_menu") and not visible:
		open_menu()
		Game.request_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("close_menu") and visible:
		close_menu()
		Game.request_unpause()
		get_viewport().set_input_as_handled()

func open_menu() -> void:
	show()

func close_menu() -> void:
	hide()

func _on_continue_pressed() -> void:
	Game.request_unpause()
	close_menu()

func _on_join_toggled(joining: bool) -> void:
	if joining:
		var ip_address_to_join := _ip_address.text
		if ip_address_to_join.is_empty(): ip_address_to_join = MultiplayerSession.DEFAULT_SERVER_IP
		Game.join_game(ip_address_to_join)
	else:
		Game.leave_game()
	_ip_address.editable = not joining
	_host_button.disabled = joining

func _on_ip_address_text_changed(new_ip_address: String) -> void:
	_join_button.disabled = not new_ip_address.is_empty() and not new_ip_address.is_valid_ip_address()

func _on_ip_address_text_submitted(new_ip_address: String) -> void:
	_on_ip_address_text_changed(new_ip_address)
	if _join_button.disabled: return
	_join_button.button_pressed = true

func _on_host_toggled(hosting: bool) -> void:
	if hosting: Game.host_game()
	else: Game.stop_hosting_game()
	_join_button.disabled = hosting
	_ip_address.editable = not hosting

func _on_save_pressed() -> void:
	Game.save_game()

func _on_quit_confirmation_dialog_confirmed() -> void:
	Game.quit_game()

func _on_game_hosted(host_ip_address: String, _port: int) -> void:
	_host_ip_address_button.text = host_ip_address

func _on_stopped_hosting_game() -> void:
	_host_ip_address_button.text = ""

func _on_left_game() -> void:
	_join_button.disabled = false
	_join_button.button_pressed = false
	_ip_address.editable = true
	_host_button.disabled = false
	_host_button.button_pressed = false
	_host_ip_address_button.text = ""
