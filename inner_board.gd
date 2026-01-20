extends Node2D

signal column_change(id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_board_column_column_entered(id: int) -> void:
	emit_signal("column_change", id) # Replace with function body.

func _on_board_column_column_exited() -> void:
	emit_signal("column_change", -1)
