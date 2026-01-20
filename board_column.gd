extends Area2D

@export
var column_id: int = 0

signal column_entered(id: int)
signal column_exited

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(_area: Area2D) -> void:
	modulate = Color(1.5, 1.5, 1.5)
	emit_signal("column_entered", column_id)

func _on_area_exited(_area: Area2D) -> void:
	modulate = Color(1, 1, 1)
	emit_signal("column_exited")
