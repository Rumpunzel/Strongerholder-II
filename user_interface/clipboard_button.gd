@tool
class_name ClipboardButton
extends Button

signal text_changed(new_text: String)

@export_category("Toast")
@export_multiline var message: String = ""
@export var type: Toasts.Type = Toasts.Type.INFO
@export var gravity: Toasts.Gravity = Toasts.Gravity.TOP
@export var direction: Toasts.Direction = Toasts.Direction.CENTER
@export var text_size: int = 18
@export var custom_toast_font: bool = false

func _ready() -> void:
	_set("text", text)
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	DisplayServer.clipboard_set(text)
	if message.is_empty():
		printerr("No message, not showing ClipboardButton toast!")
		return
	Toasts.show_toast(message, type, gravity, direction, text_size, custom_toast_font)

func _set(property: StringName, value: Variant) -> bool:
	match property:
		"text":
			assert(value is String)
			var new_text: String = value
			text = new_text
			disabled = text.is_empty()
			text_changed.emit(text)
			return true
	return false
