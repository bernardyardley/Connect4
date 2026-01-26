extends Node2D

var piece_radius: float
var piece_initial_position: Vector2
var column_zero_centre_x: float
var player_piece: Resource
var current_piece
var yellow_piece: Sprite2D
var rng = RandomNumberGenerator.new()
var ai_wrapper_script = load("res://AiWrapper.cs")
var ai_wrapper = ai_wrapper_script.new(1000, 1.414)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	piece_radius = $PlayerPiece.radius
	piece_initial_position = $PlayerPiece.position
	# Get the x value of the centre of column 0
	column_zero_centre_x = $InnerBoard.position.x + $InnerBoard.column_width / 2.0
	player_piece = preload("res://player_piece.tscn")
	current_piece = $PlayerPiece
	yellow_piece = $YellowPath/YellowPathFollow/YellowPiece
	print(ai_wrapper.GameOver)

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
	# The next line will move it to the top of the board, we then wait for it to finish
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
	# Move the piece to over a random column
	var target_column: int = rng.randi_range(0, 6)
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
	
	# Put the pieces back where they were
	spawn_new_player_piece()
	$YellowPath/YellowPathFollow.progress_ratio = 0.0
	yellow_piece.show()

func get_column_centre_x(col: int) -> float:
	return column_zero_centre_x + $InnerBoard.column_width * col

func get_empty_cell_y(col: int) -> float:
	var multiplier = 13 - 2.0 * $InnerBoard.filled_cells[col]
	return $InnerBoard.column_top + $PlayerPiece.radius * multiplier
