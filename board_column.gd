extends Area2D

@export
var column_id: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	modulate = Color(1.5, 1.5, 1.5)


func _on_area_exited(area: Area2D) -> void:
	modulate = Color(1, 1, 1)
