@tool
class_name ClipboardButton
extends Button

signal text_changed(new_text: String)

@export_category("Toast")
@export_multiline var message: String = ""
@export var text_color: Color = Color(1, 1, 1, 1)
@export var background_color: Color = Color(0, 0, 0, 0.7)
@export_enum("top", "bottom") var gravity: String = "top"
@export_enum("left", "center", "right") var direction: String = "center"
@export var text_size := 18
@export var custom_toast_font := false

func _ready() -> void:
	_set("text", text)
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	DisplayServer.clipboard_set(text)
	_show_toast()

func _show_toast() -> void:
	if message.is_empty():
		printerr("No message, not showing ClipboardButton toast!")
		return
	ToastParty.show({
		"text": message,
		"bgcolor": background_color,
		"color": text_color,
		"gravity": gravity,
		"direction": direction,
		"text_size": text_size,
		"use_font": custom_toast_font,
	})

func _set(property: StringName, value: Variant) -> bool:
	match property:
		"text":
			assert(value is String)
			@warning_ignore("unsafe_cast")
			var new_text := value as String
			text = new_text
			disabled = text.is_empty()
			text_changed.emit(text)
			return true
	return false
