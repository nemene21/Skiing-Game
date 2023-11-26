extends Node2D

@onready var camera := $Camera2D
@onready var player := $Player
@onready var snow_gradient := $Camera2D/SnowGradient
@onready var generator := $Generator
@onready var death_animator := $DeathAnimation

func _ready() -> void:
	VfxManager.set_target(self)
	PostProcessing.animator.play("RESET")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Utils.player == null:
		return
	
	snow_gradient.material.set_shader_parameter("offset", (camera.global_position / Utils.res) * .5)
	
	camera.global_position.y = Utils.dlerp(
		camera.global_position.y,
		player.global_position.y - 150,
		Utils.player.velocitycomp.vel.length() * 0.04
	)

func post_processing_death_anim() -> void:
	PostProcessing.animator.play("death")
