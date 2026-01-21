extends Node2D

var piece_radius: float
var piece_initial_position: Vector2
var column_zero_centre_x: float
var player_piece: Resource
var current_piece

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	piece_radius = $PlayerPiece.radius
	piece_initial_position = $PlayerPiece.position
	# Get the x value of the centre of column 0
	column_zero_centre_x = $InnerBoard.position.x + $InnerBoard.column_width / 2.0
	player_piece = preload("res://player_piece.tscn")
	current_piece = $PlayerPiece

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_player_piece_released() -> void:
	var current_column = $InnerBoard.get_current_column()
	var tween: Tween = create_tween()
	if current_column == -1:
		tween.tween_property(current_piece, "position", piece_initial_position, 0.5)
		current_piece.state = $PlayerPiece.State.DRAGGABLE
	else:
		# Centre the piece over the column
		var target_x = column_zero_centre_x + $InnerBoard.column_width * current_column
		current_piece.position.x = target_x
		var multiplier = 13 - 2.0 * $InnerBoard.filled_cells[current_column]
		var target_y = $InnerBoard.column_top + $PlayerPiece.radius * multiplier
		current_piece.z_index = 1
		tween.tween_property(current_piece, "position", Vector2(target_x, target_y), 1.0)
		current_piece.state = $PlayerPiece.State.FINISHED
		# Record that we've dropped there
		$InnerBoard.play_to_column(current_column)
		# Finally, spawn a new piece
		var piece = player_piece.instantiate()
		piece.position = piece_initial_position
		piece.connect("released", _on_player_piece_released)
		current_piece = piece
		piece.z_index = 3
		# Wait for the movement to stop
		await tween.finished
		$AudioStreamPlayer.play()
		add_child(piece)
		
