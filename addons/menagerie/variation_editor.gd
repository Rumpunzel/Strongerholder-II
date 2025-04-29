@tool
extends Control

signal variation_changed(new_variation: int)

@export var _randomize_variation: CheckButton
@export var _variation_spin_box: SpinBox

func _on_variation_spin_box_value_changed(new_value: int) -> void:
	var max_variation: int = _variation_spin_box.max_value + 1
	_variation_spin_box.set_value_no_signal((new_value + max_variation) % max_variation)
	variation_changed.emit(_variation_spin_box.value)

func _on_active_profile_changed(active_profile: Profile) -> void:
	_variation_spin_box.max_value = active_profile.get_variation_count() - 1
	_variation_spin_box.editable = _variation_spin_box.max_value > 0
	if _randomize_variation.button_pressed: _variation_spin_box.value = active_profile.get_random_variation()
	else: _variation_spin_box.value = 0
