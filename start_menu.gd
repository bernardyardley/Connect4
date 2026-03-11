extends CanvasLayer

signal ready_to_start(level: int)

var level: int = 0
var level_names = ["Beginner", "Intermediate", "Expert"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_level(l: int) -> void:
	level = l
	%LevelLabel.text = "Press Start to compete in " + level_names[l] + " mode"

func _on_start_button_pressed() -> void:
	ready_to_start.emit(level)
