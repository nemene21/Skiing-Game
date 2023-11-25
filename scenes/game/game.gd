extends Node2D

@onready var camera := $Camera2D
@onready var player := $Player
@onready var snow_gradient := $Camera2D/SnowGradient

func _ready() -> void:
	VfxManager.set_target(self)

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
