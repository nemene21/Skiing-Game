extends Node

@export var height := .0
@export var colliders: Array[CollisionShape2D]

func _process(delta: float) -> void:
	var unactive: bool = (Utils.player.height > height) or Utils.player.fatal_speed()
	for collider in colliders:
		collider.disabled = unactive
