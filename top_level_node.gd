extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Game.modulate = Color(0.5, 0.5, 0.5)


func _on_start_menu_ready_to_start(level: int) -> void:
	$AnimationPlayer.play("new_animation")
	$Game.start(level)
