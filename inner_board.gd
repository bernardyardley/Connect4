extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_current_column() -> int:
	for column in get_tree().get_nodes_in_group("columns"):
		if column.entered:
			return column.column_id
	
	return -1
