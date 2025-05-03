@tool
@icon("uid://bfpmyljmhdkos")
class_name Level
extends Node3D

var _grid: Dictionary[Vector3i, GridCell]
var _debugs: Dictionary[Vector3i, Label3D]

func _ready() -> void:
	for z: int in range(-32, 32):
		for x: int in range(-32, 32):
			var debug_label: GridDebugLevel = GridDebugLevel.new()
			var cell_position: Vector3i = Vector3i(x, 0, z)
			debug_label.cell_position = cell_position
			add_child(debug_label)
			_debugs[cell_position] = debug_label

func _update_debug(cell_position: Vector3i, grid_cell: GridCell) -> void:
	var debug_label: GridDebugLevel = _debugs[cell_position]
	debug_label.grid_cell = grid_cell
	debug_label.update_text()

func _on_character_entered_grid_cell(cell_position: Vector3i) -> void:
	var ground_cell: GroundCell = _grid.get_or_add(cell_position, GridCell.get_default())
	ground_cell.times_entered += 1
	_grid[cell_position] = ground_cell
	_update_debug(cell_position, ground_cell)
