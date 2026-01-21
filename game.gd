extends Node2D

var piece_radius: float
var piece_initial_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	piece_radius = $PlayerPiece.radius
	piece_initial_position = $PlayerPiece.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_piece_released() -> void:
	var current_column = $InnerBoard.get_current_column()
	if current_column == -1:
		var tween: Tween = create_tween()
		tween.tween_property($PlayerPiece, "position", piece_initial_position, 0.5)
		$PlayerPiece.state = $PlayerPiece.State.DRAGGABLE
	else:
		print("Piece is over column " + str(current_column))
