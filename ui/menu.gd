class_name Menu
extends Control

@export var join_button: Button
@export var disconnect_button: Button
@export var ip_address: LineEdit
@export var host_button: Button
@export var stop_hosting_button: Button
@export var host_ip_address: Button


func _ready() -> void:
	Game.game_paused.connect(_on_game_paused)
	Game.game_continued.connect(_on_game_continued)


func _on_game_paused() -> void:
	show()

func _on_game_continued() -> void:
	hide()

func _on_continue_pressed() -> void:
	Game.continue_game()


func _on_join_pressed() -> void:
	var ip_address_to_join := ip_address.text
	if ip_address_to_join.is_empty(): ip_address_to_join = Multiplayer.DEFAULT_SERVER_IP
	Multiplayer.join_game(ip_address_to_join)
	join_button.visible = false
	disconnect_button.visible = true
	ip_address.editable = false
	host_button.disabled = true

func _on_disconnect_pressed() -> void:
	Multiplayer.leave_multiplayer()
	join_button.visible = true
	disconnect_button.visible = false
	ip_address.editable = true
	host_button.disabled = false

func _on_ip_address_text_changed(new_ip_address: String) -> void:
	join_button.disabled = not new_ip_address.is_empty() and not new_ip_address.is_valid_ip_address()

func _on_ip_address_text_submitted(new_ip_address: String) -> void:
	_on_ip_address_text_changed(new_ip_address)
	if join_button.disabled: return
	_on_join_pressed()

func _on_host_pressed() -> void:
	Multiplayer.host_game()
	join_button.disabled = true
	ip_address.editable = false
	host_button.visible = false
	stop_hosting_button.visible = true
	host_ip_address.visible = true

func _on_stop_hosting_pressed() -> void:
	Multiplayer.leave_multiplayer()
	join_button.disabled = false
	ip_address.editable = true
	host_button.visible = true
	stop_hosting_button.visible = false
	host_ip_address.visible = false


func _on_quit_confirmation_dialog_confirmed() -> void:
	Game.quit_game()
