class_name Toasts
extends Node

enum Type {
	INFO,
	SUCCESS,
	WARNING,
	ERROR,
}

enum Gravity {
	TOP,
	BOTTOM,
}

enum Direction {
	CENTER,
	LEFT,
	RIGHT,
}

const text_colors: Dictionary[Type, Color] = {
	Type.INFO: Color.WHITE,
	Type.SUCCESS: Color.BLACK,
	Type.WARNING: Color.BLACK,
	Type.ERROR: Color.WHITE,
}

const background_colors: Dictionary[Type, Color] = {
	Type.INFO: Color("#414042"),
	Type.SUCCESS: Color(0.45, 0.95, 0.5),
	Type.WARNING: Color(1, 0.87, 0.4),
	Type.ERROR: Color(1, 0.47, 0.42),
}

static func show_toast(
	message: String,
	type: Type = Type.INFO,
	gravity: Gravity = Gravity.TOP,
	direction: Direction = Direction.CENTER,
	text_size: int = 18, 
	custom_toast_font: bool = false,
) -> void:
	assert(not message.is_empty())
	ToastParty.show({
		"text": message,
		"bgcolor": background_colors[type],
		"color": text_colors[type],
		"gravity": _parse_gravity(gravity),
		"direction": _parse_direction(direction),
		"text_size": text_size,
		"use_font": custom_toast_font,
	})

static func _parse_gravity(gravity: Gravity) -> String:
	match(gravity):
		Gravity.TOP: return "top"
		Gravity.BOTTOM: return "bottom"
	assert(false, "Match case for Gravity is not exhaustive!")
	return ""

static func _parse_direction(direction: Direction) -> String:
	match(direction):
		Direction.CENTER: return "center"
		Direction.LEFT: return "left"
		Direction.RIGHT: return "right"
	assert(false, "Match case for Direction is not exhaustive!")
	return ""
