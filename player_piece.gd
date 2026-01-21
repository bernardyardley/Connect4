extends Node2D

signal released

var radius: float

enum State {
	DRAGGABLE,		# Waiting to be dragged
	BEING_DRAGGED,	# Being dragged
	RELEASED		# Player has released the piece
}

@export
var state: State = State.DRAGGABLE
var mouse_position: Vector2

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and get_local_mouse_position().length() <= radius and state == State.DRAGGABLE:
				mouse_position = get_global_mouse_position()
				state = State.BEING_DRAGGED 
		else:
			if state == State.BEING_DRAGGED:
				state = State.RELEASED
				emit_signal("released")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	radius = $RedPiece.get_rect().size.x / 2.0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == State.BEING_DRAGGED:
		var new_mouse_position = get_global_mouse_position()
		var offset = new_mouse_position - mouse_position
		position += offset
		mouse_position = new_mouse_position
