extends PathFollow2D

@export
var speed: float = 0.75

var current_speed: float = 0.0

signal finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_speed > 0.0:
		progress_ratio = min(1.0, progress_ratio + delta * speed)
		if progress_ratio > 0.99:
			current_speed = 0.0
			emit_signal("finished")

func move_computer_piece() -> void:
	current_speed = speed		
