extends Area2D

@export
var column_id: int = 0

var entered = false
var width: float
var cell_top: float
var valid: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	width = $Cell.get_rect().size.x
	cell_top = $Cell2.position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_entered(_area: Area2D) -> void:
	if valid:
		entered = true
		modulate = Color(1.5, 1.5, 1.5)

func _on_area_exited(_area: Area2D) -> void:
	entered = false
	modulate = Color(1, 1, 1)
	
