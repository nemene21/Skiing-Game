extends Node2D

@onready var camera := $Camera2D
@onready var player := $Player
@onready var snow_gradient := $Camera2D/SnowGradient

var player_dist := .0

func _ready() -> void:
	VfxManager.set_target(self)

@onready var log_scene := preload("res://scenes/game/obstacles/log/log.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Utils.player == null:
		return
	
	snow_gradient.material.set_shader_parameter("offset", camera.global_position / Utils.res)
	
	camera.global_position.y = Utils.dlerp(
		camera.global_position.y,
		player.global_position.y - 150,
		Utils.player.velocitycomp.vel.length() * 0.04
	)
	
	if player.global_position.y < player_dist:
		player_dist -= 500
		var log = log_scene.instantiate()
		log.global_position.x = randf_range(100, 220)
		log.global_position.y = player.global_position.y - 500
		log.rotation = (randf() * 2 - 1) * 0.1
		add_child(log)
