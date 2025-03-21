class_name Menu
extends Control

@export var join_button: Button
@export var ip_address: LineEdit
@export var host_button: Button
@export var host_ip_address_button: Button

func _ready() -> void:
	Game.game_paused.connect(_on_game_paused)
	Game.game_continued.connect(_on_game_continued)
	Game.game_hosted.connect(_on_game_hosted)
	Game.stopped_hosting_game.connect(_on_stopped_hosting_game)

func _on_continue_pressed() -> void:
	Game.continue_game()

func _on_join_toggled(joining: bool) -> void:
	if joining:
		var ip_address_to_join := ip_address.text
		if ip_address_to_join.is_empty(): ip_address_to_join = Multiplayer.DEFAULT_SERVER_IP
		Game.join_game(ip_address_to_join)
	else:
		Game.leave_game()
	ip_address.editable = not joining
	host_button.disabled = joining

func _on_ip_address_text_changed(new_ip_address: String) -> void:
	join_button.disabled = not new_ip_address.is_empty() and not new_ip_address.is_valid_ip_address()

func _on_ip_address_text_submitted(new_ip_address: String) -> void:
	_on_ip_address_text_changed(new_ip_address)
	if join_button.disabled: return
	join_button.button_pressed = true

func _on_host_toggled(hosting: bool) -> void:
	if hosting: Game.host_game()
	else: Game.stop_hosting_game()
	join_button.disabled = hosting
	ip_address.editable = not hosting

func _on_quit_confirmation_dialog_confirmed() -> void:
	Game.quit_game()

func _on_game_paused() -> void:
	show()

func _on_game_continued() -> void:
	hide()

func _on_game_hosted(host_ip_address: String, _port: int) -> void:
	host_ip_address_button.text = host_ip_address

func _on_stopped_hosting_game() -> void:
	host_ip_address_button.text = ""
