@tool
@icon("uid://ongd2v8c4cpf")
extends Label

func _ready() -> void:
	text = "Version: %s" % ProjectSettings.get_setting("application/config/version")
