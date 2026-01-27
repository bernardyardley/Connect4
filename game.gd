extends Node2D

var piece_radius: float
var piece_initial_position: Vector2
var column_zero_centre_x: float
var player_piece: Resource
var current_piece
var yellow_piece: Sprite2D
var ai_wrapper_script = load("res://AiWrapper.cs")
var ai_wrapper = ai_wrapper_script.new(1000, 1.414)

# Game play variables
var player_column: int
var computer_column: int
var game_over: bool
var winner: int
var human_player: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	piece_radius = $PlayerPiece.radius
	piece_initial_position = $PlayerPiece.position
	# Get the x value of the centre of column 0
	column_zero_centre_x = $InnerBoard.position.x + $InnerBoard.column_width / 2.0
	player_piece = preload("res://player_piece.tscn")
	current_piece = $PlayerPiece
	yellow_piece = $YellowPath/YellowPathFollow/YellowPiece
	human_player = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_player_piece_released() -> void:
	var current_column = $InnerBoard.get_current_column()
	player_column = current_column
	var tween: Tween = create_tween()
	if current_column == -1:
		tween.tween_property(current_piece, "position", piece_initial_position, 0.5)
		current_piece.state = $PlayerPiece.State.DRAGGABLE
	else:
		# Centre the piece over the column
		var target_x = get_column_centre_x(current_column)
		current_piece.position.x = target_x
		var target_y = get_empty_cell_y(current_column)
		current_piece.z_index = 1
		tween.tween_property(current_piece, "position", Vector2(target_x, target_y), 1.0)
		current_piece.state = $PlayerPiece.State.FINISHED
		# Record that we've dropped there
		$InnerBoard.play_to_column(current_column)
		# Wait for the movement to stop
		await tween.finished
		$AudioStreamPlayer.play()		
		
		# Do the computer's move
		do_computer_move()
		
func do_computer_move() -> void:
	# Get the computer's response; this also detects if the player has won
	computer_column = ai_wrapper.GetResponse(player_column)
	# If the game is over but the computer has won, we'll still need to move its piece
	if ai_wrapper.GameOver:
		winner = ai_wrapper.Winner
		game_over = true
		if winner == human_player:
			$Label.text = "You won!"
			return
	
	# Otherwise, continue with the gane
	$YellowPath/YellowPathFollow.move_computer_piece()

func spawn_new_player_piece():
	var piece = player_piece.instantiate()
	piece.position = piece_initial_position
	piece.connect("released", _on_player_piece_released)
	current_piece = piece
	piece.z_index = 3
	add_child(piece)

# This function is called when the computer's piece has moved to the top of the board
# The code does not follow the DRY principle and should be improved
func _on_yellow_path_follow_finished() -> void:
	# We'll create a Sprite that looks like the computer piece
	var sprite = Sprite2D.new()
	sprite.texture = load("res://media/yellow_piece.png")
	sprite.global_position = yellow_piece.global_position
	add_child(sprite)
	yellow_piece.hide()
	# Use the AI to decide where to move to
	var target_column: int = computer_column
	# At this stage, the game could be over - so this should happen sooner
	var target_x = get_column_centre_x(target_column)
	var target_y = sprite.position.y
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "position", Vector2(target_x, target_y), 0.5)
	target_y = get_empty_cell_y(target_column)
	tween.tween_property(sprite, "position", Vector2(target_x, target_y), 0.5)
	await tween.finished
	# Record that we've played to that column
	$InnerBoard.play_to_column(target_column)
	$AudioStreamPlayer.play()
	
	# If the game is over, don't respawn the piece
	if game_over:
		if winner == 0:
			$Label.text = "It was a draw!"
		else:
			$Label.text = "The computer won!"
		return
	
	# Put the pieces back where they were
	spawn_new_player_piece()
	$YellowPath/YellowPathFollow.progress_ratio = 0.0
	yellow_piece.show()

func get_column_centre_x(col: int) -> float:
	return column_zero_centre_x + $InnerBoard.column_width * col

func get_empty_cell_y(col: int) -> float:
	var multiplier = 13 - 2.0 * $InnerBoard.filled_cells[col]
	return $InnerBoard.column_top + $PlayerPiece.radius * multiplier
