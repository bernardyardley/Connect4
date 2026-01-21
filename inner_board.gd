extends Node2D

var column_width: float
var column_top: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	column_width = $BoardColumn.width
	column_top = $BoardColumn.cell_top

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_current_column() -> int:
	for column in get_tree().get_nodes_in_group("columns"):
		if column.entered:
			return column.column_id
	
	return -1
