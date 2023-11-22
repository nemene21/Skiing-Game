extends Node2D

@onready var camera := $Camera2D
@onready var player := $Player

var player_dist := .0

func _ready() -> void:
	VfxManager.set_target(self)

@onready var log_scene := preload("res://scenes/game/obstacles/log/log.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Utils.player == null:
		return
	
	camera.global_position.y = Utils.dlerp(
		camera.global_position.y,
		player.global_position.y - 160 - abs(player.velocitycomp.vel.length()) * 0.33,
		3
	)
	
	if player.global_position.y < player_dist:
		player_dist -= 500
		var log = log_scene.instantiate()
		log.global_position.x = randf_range(100, 220)
		log.global_position.y = player.global_position.y - 500
		log.rotation = (randf() * 2 - 1) * 0.1
		add_child(log)
	
	for child in get_children():
		if str(child.name).begins_with("Tree"):
			if child.global_position.y - camera.global_position.y > 450:
				child.global_position.y -= 900
