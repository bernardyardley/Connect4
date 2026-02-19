extends Node2D

var column_width: float
var column_top: float

var filled_cells: PackedInt32Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	column_width = $BoardColumn.width
	column_top = $BoardColumn.cell_top
	reset()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func reset() -> void:
	filled_cells = [0, 0, 0, 0, 0, 0, 0]
	for column in get_tree().get_nodes_in_group("columns"):
		column.entered = false
		column.valid = true

func get_current_column() -> int:
	for column in get_tree().get_nodes_in_group("columns"):
		if column.entered:
			return column.column_id
	
	return -1

func play_to_column(col_no: int) -> void:
	filled_cells[col_no] += 1
	if filled_cells[col_no] == 6:
		# The column is full
		# Find the column
		var column = get_tree().get_nodes_in_group("columns").filter(func(c): return c.column_id == col_no).front()
		column.valid = false
		column._on_area_exited(null)
