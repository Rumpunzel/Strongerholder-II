@tool
extends HBoxContainer

signal zoom_changed(new_zoom: float)
signal zoomed_out
signal zoomed_in

@export var _inverted: bool = true

@export_group("Configuration")
@export var _zoom_slider: Slider
@export var _config: Config

func _ready() -> void:
	_zoom_slider.value = _config.get_value_from_config("Zoom", "zoom", 0.5)

func _on_zoom_slider_value_changed(value: float) -> void:
	var new_zoom: float = (_zoom_slider.max_value - value) if _inverted else value
	zoom_changed.emit(new_zoom)
	_config.update_value_in_config(new_zoom, "Zoom", "zoom")

func _on_zoom_out_pressed() -> void:
	zoomed_out.emit()

func _on_zoom_in_pressed() -> void:
	zoomed_in.emit()

func _on_zoom_value_changed(zoom_value: float) -> void:
	var new_zoom: float = (_zoom_slider.max_value - zoom_value) if _inverted else zoom_value
	_zoom_slider.set_value_no_signal(new_zoom)
	_config.update_value_in_config(new_zoom, "Zoom", "zoom")
