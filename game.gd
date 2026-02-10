extends Node2D

var piece_radius: float
var piece_initial_position: Vector2
var column_zero_centre_x: float
var yellow_piece: Sprite2D
var ai_wrapper_script = load("res://AiWrapper.cs")
var ai_wrapper = ai_wrapper_script.new(10000, 1.414)

# Game play variables
var player_column: int
var computer_column: int
var winner: int
var human_player: int = 1
var computer_wins:int = 0
var human_wins:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ai_wrapper.connect("MoveCalculated", _on_ai_wrapper_move_calculated)
	piece_radius = $PlayerPiece.radius
	piece_initial_position = $PlayerPiece.position
	# Get the x value of the centre of column 0
	column_zero_centre_x = $InnerBoard.position.x + $InnerBoard.column_width / 2.0
	yellow_piece = $YellowPath/YellowPathFollow/YellowPiece
	human_player = 1
	%Label.text = "You start (red player)"
	# Hide the new game button
	$StartAgainButton.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_player_piece_released() -> void:
	var current_column = $InnerBoard.get_current_column()
	player_column = current_column
	if current_column == -1:
		var tween: Tween = create_tween()
		tween.tween_property($PlayerPiece, "position", piece_initial_position, 0.5)
		await tween.finished
		$PlayerPiece.state = $PlayerPiece.State.DRAGGABLE
	else:
		# Centre the piece over the column
		var target_x = get_column_centre_x(current_column)
		var target_y = get_empty_cell_y(current_column)
		$PlayerPiece.hide()
		await drop_piece($PlayerPiece.position, Vector2(target_x, target_y), $PlayerPiece/RedPiece.texture)
		# Record that we've dropped there
		$InnerBoard.play_to_column(current_column)
		# Do the computer's move
		%Label.text = "The computer is thinking..."
		# Get the computer's response; this also detects if the player has won
		ai_wrapper.GetResponse(player_column)
		
func drop_piece(from: Vector2, to: Vector2, texture: Texture2D) -> void:
	# Create a sprite on the from location with the relevant texture
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2(to.x, from.y)
	sprite.z_index = 1
	add_child(sprite)
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "position", to, 0.5)
	await tween.finished
	# Record that we've played to that column
	$AudioStreamPlayer.play()

func do_computer_move() -> void:
	# If the game is over but the computer has won, we'll still need to move its piece
	if ai_wrapper.GameOver:
		winner = ai_wrapper.Winner
		if winner == human_player:
			%Label.text = "You won!"
			human_wins += 1
			%PlayerScore.text = "Player: " + str(human_wins) + " "
		offer_new_game()
	else:
		%Label.text = "The computer is playing to column " + str(computer_column + 1)
		# Otherwise, continue with the gane
		$YellowPath/YellowPathFollow.move_computer_piece(get_column_centre_x(computer_column))

func spawn_new_player_piece():
	$PlayerPiece.position = piece_initial_position
	$PlayerPiece.show()
	%Label.text = "Your turn (red player)"

# This function is called when the computer's piece has moved to the top of the board
# The code does not follow the DRY principle and should be improved
func _on_yellow_path_follow_finished() -> void:
	# Use the AI to decide where to move to
	var target_x = get_column_centre_x(computer_column)
	var target_y = get_empty_cell_y(computer_column)
	yellow_piece.hide()
	await drop_piece(yellow_piece.global_position, Vector2(target_x, target_y), yellow_piece.texture)
	# Record that we've played to that column
	$InnerBoard.play_to_column(computer_column)
	
	# If the game is over, don't respawn the piece
	if ai_wrapper.GameOver:
		if winner == 0:
			%Label.text = "It was a draw!"
		else:
			%Label.text = "The computer won!"
			computer_wins += 1
			%ComputerScore.text = " Computer: " + str(computer_wins)
		offer_new_game()
	else:
		# Put the pieces back where they were
		spawn_new_player_piece()
		$YellowPath/YellowPathFollow.progress_ratio = 0.0
		yellow_piece.show()
		$PlayerPiece.state = $PlayerPiece.State.DRAGGABLE

func offer_new_game():
	$StartAgainButton.show()
	print("Offer new game entered")

func get_column_centre_x(col: int) -> float:
	return column_zero_centre_x + $InnerBoard.column_width * col

func get_empty_cell_y(col: int) -> float:
	var multiplier = 13 - 2.0 * $InnerBoard.filled_cells[col]
	return $InnerBoard.column_top + $PlayerPiece.radius * multiplier


func _on_ai_wrapper_move_calculated(move: int) -> void:
	computer_column = move
	do_computer_move()

func _on_start_again_button_pressed() -> void:
	print("Button clicked")
