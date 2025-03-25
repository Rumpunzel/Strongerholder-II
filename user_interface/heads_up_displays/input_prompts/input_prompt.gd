@tool
@icon("uid://dpi0uyjawwtnk")
class_name InputPrompt
extends HeadsUpDisplay

const INPUT_PROMPT_SCENE: PackedScene = preload("uid://d3ufd1hkx3mvi")

@export_group("Configuration")
@export var _timer: Timer

var available_action: StringName

var input_events: Array[InputEvent]:
	set(new_input_events):
		input_events = new_input_events
		_input_event_index = 0
		if input_events.size() > 1: _timer.start()

var heads_up_anchor: HeadsUpAnchor

var _current_prompt: KeyPrompt:
	set(new_current_prompt):
		if _current_prompt:
			remove_child(_current_prompt)
			_current_prompt.queue_free()
		_current_prompt = new_current_prompt
		if not _current_prompt: return
		add_child(_current_prompt)

var _input_event_index: int = 0:
	set(new__input_event_index):
		_input_event_index = new__input_event_index
		if input_events.is_empty(): return
		_input_event_index %= input_events.size()
		var input_event: InputEvent = input_events[_input_event_index]
		match input_event.get_class():
			"InputEventKey": _current_prompt = KeyPrompt.create(input_event as InputEventKey)
			"InputEventMouse": push_warning("InputEventShortcut is not yet implemented!")
			"InputEventJoypadButton": push_warning("InputEventShortcut is not yet implemented!")
			"InputEventJoypadMotion": push_warning("InputEventShortcut is not yet implemented!")
			"InputEventShortcut": push_warning("InputEventShortcut is not yet implemented!")
			_: push_error("InputEvent type for %s not supported!" % input_event)

static func create(for_available_action: StringName, for_input_events: Array[InputEvent], at_heads_up_anchor: HeadsUpAnchor) -> InputPrompt:
	assert(not for_available_action.is_empty())
	assert(not for_input_events.is_empty())
	assert(at_heads_up_anchor)
	var new_input_prompt: InputPrompt = INPUT_PROMPT_SCENE.instantiate()
	new_input_prompt.available_action = for_available_action
	new_input_prompt.input_events = for_input_events
	new_input_prompt.heads_up_anchor = at_heads_up_anchor
	return new_input_prompt

func _process(_delta: float) -> void:
	assert(heads_up_anchor)
	var viewport_camera: Camera3D = get_viewport().get_camera_3d()
	visible = not viewport_camera.is_position_behind(heads_up_anchor.global_position)
	position = viewport_camera.unproject_position(heads_up_anchor.global_position) - Vector2(size.x, size.y / 2.0)
	_current_prompt.button_pressed = Input.is_action_pressed(available_action)

func hide_prompt() -> void:
	queue_free()

func _on_timer_timeout() -> void:
	_input_event_index += 1

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _timer: warnings.append("Missing Timer reference.")
	return warnings
