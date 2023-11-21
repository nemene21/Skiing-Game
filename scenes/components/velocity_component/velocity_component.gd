extends Node

var vel := Vector2.ZERO

@onready var parent := get_parent()

@export var move_automatically := true

func steer(angle) -> void:
	var delta = get_process_delta_time()
	vel = vel.rotated(deg_to_rad(angle) * delta)

func accelerate(speed: Vector2) -> void:
	var delta = get_process_delta_time()
	vel += speed * delta

func lerp_velocity(value: Vector2, speed: float) -> void:
	vel = Utils.dlerp(vel, value, speed)

func cap_velocity(cap: float) -> void:
	if vel.length() > cap:
		vel = vel.normalized() * cap

func cap_rotation(minimum: float, maximum: float):
	minimum = deg_to_rad(minimum)
	maximum = deg_to_rad(maximum)
	
	var angle = vel.angle()
	if angle < minimum:
		vel = Vector2.RIGHT.rotated(minimum) * vel.length()
	elif angle > maximum:
		vel = Vector2.RIGHT.rotated(maximum) * vel.length()

func cap_rotation_smoothly(minimum: float, maximum: float, speed: float):
	var copy_vel = vel
	cap_rotation(minimum, maximum)
	
	vel = Utils.dlerp(copy_vel, vel, speed)
	

func _process(delta: float) -> void:
	if !move_automatically:
		return
	
	if parent is CharacterBody2D:
		parent.velocity = vel
		parent.move_and_slide()
	else:
		parent.global_position += vel * delta
