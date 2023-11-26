extends Node2D

func _process(delta: float) -> void:
	visible = abs(global_position.y - Utils.player.global_position.y) < 500
