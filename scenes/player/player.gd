extends CharacterBody2D

var speed := 20.0
var max_speed := 200.0
var steering := .0
var horizontal_vel := .0
var jump_height := 250.0

var direction := -.5*PI

var breaking := false
var dead := false

var height := .0
var grounded := true

#region Node referances
@onready var velocitycomp := $VelocityComponent
@onready var collider := $CollisionShape2D

@onready var skis := $Sprites/skis
@onready var sprite := $Sprites/Sprite
@onready var sprites := $Sprites

@onready var animator := $Animator

@onready var shadow := $Shadow

@onready var trail1 := $Sprites/Trail
@onready var trail2 := $Sprites/Trail2
@onready var scarf := $Sprites/Scarf
@onready var hair := $Sprites/Hair

@onready var stick1 := $Sprites/Sprite/Stick
@onready var stick2 := $Sprites/Sprite/Stick2

@onready var speed_particles := $SpeedParticles
@onready var break_particles1 := $BreakParticles
@onready var break_particles2 := $BreakParticles2
#endregion

func _ready() -> void:
	velocitycomp.vel.y = -1
	Utils.player = self

func _process(delta: float) -> void:
	# If dead, slow down and dont process...
	if dead:
		velocitycomp.lerp_velocity(Vector2.ZERO, 8.0)
		return
	
	#region Input
	var steering_input := Input.get_axis("left", "right")
	var is_breaking := (Input.is_action_pressed("right") and Input.is_action_pressed("left")) or Input.is_action_pressed("break")
	var speeding := Input.is_action_pressed("up")
	
	steering = Utils.dlerp(steering, steering_input, 8.0)
	#endregion
	
	#region Movement
	# Update grounded variable and call landed if its landed
	var new_grounded := height == 0
	if grounded != (new_grounded):
		grounded = new_grounded
		
		if grounded: land()
	
	# Slow down and cap on break or collision
	if (is_breaking and grounded):
		velocitycomp.lerp_velocity(Vector2.ZERO, 4.0)
	elif is_on_ceiling():
		velocitycomp.cap_velocity(max_speed * .1)
	
	# Speed up due to slope
	else:
		var speedup = 1 + int(speeding) * 2
		velocitycomp.accelerate(velocitycomp.vel.normalized() * speed * speedup)
	
	# Gravity
	height = max(0, height + horizontal_vel * delta)
	horizontal_vel = Utils.dlerp(horizontal_vel, -jump_height, 6.0)
	
	# Steering
	direction += steering * delta * 6.0
	direction = Utils.dlerp(direction, clamp(direction, -PI*.75, -PI*.25), 12.0)
	
	if grounded:
		# Moves the veliocity towards the steer if on ground
		velocitycomp.vel = Utils.dlerp(
			velocitycomp.vel,
			velocitycomp.vel.length() * Vector2.RIGHT.rotated(direction),
			5.0
		)
	
	# Jump
	if Input.is_action_just_pressed("up") and grounded: jump()
	
	# Play breaking animation
	if breaking != is_breaking:
		breaking = is_breaking
		animator.call(["play", "play_backwards"][int(!breaking)], "break")
	
	# Cap velocity
	velocitycomp.cap_velocity(max_speed)
	#endregion
	
	#region Graphics Processing
	# Skis
	skis.skew = (direction + PI*.5) * .5
	skis.rotation = PI*.25 + direction * .5
	
	var ski_nodes = skis.get_children()
	ski_nodes[0].position.y = -max(steering, 0) * 3 - 4
	ski_nodes[1].position.y =  min(steering, 0) * 3 - 4
	
	# Scarf
	scarf.randomness = velocitycomp.vel.length()/max_speed * 2
	
	# Sprite
	sprite.rotation = steering * 0.25
	
	sprite.scale = Utils.dlerp(
		sprite.scale,
		lerp(Vector2(1, 1), Vector2(1.2, 0.7), float(speeding)),
		6.0
	)
	sprites.position.y = -height
	
	# Shadow
	shadow.scale = Vector2(0.484, 1.542) * (1.0 - height/32.0)
	
	# Sticks
	stick1.rotation_degrees = Utils.dlerp(
		stick1.rotation_degrees,
		lerp(-60, -80, int(speeding)),
		12.0
	)
	stick1.scale.x = Utils.dlerp(stick1.scale.x, lerp(1.0, 0.65, float(speeding)), 10.0)
	
	stick2.rotation_degrees = Utils.dlerp(
		stick2.rotation_degrees,
		lerp(240, 260, int(speeding)),
		12.0
	)
	stick2.scale.x = Utils.dlerp(stick2.scale.x, lerp(1.0, 0.65, float(speeding)), 10.0)
	
	# Particles
	var normalized_vel: Vector2 = -velocitycomp.vel.normalized()
	speed_particles.emitting = fatal_speed()
	speed_particles.process_material.direction = Vector3(normalized_vel.x, normalized_vel.y, .0)
	speed_particles.amount_ratio = (velocitycomp.vel.length() / max_speed)
	
	var fast_enough = velocitycomp.vel.length() > 50
	break_particles1.emitting = (Input.is_action_pressed("left") or breaking)  and fast_enough
	break_particles2.emitting = (Input.is_action_pressed("right") or breaking) and fast_enough
	#endregion

#region Vertical Movement
func jump(strength: float = 1.0):
	horizontal_vel = jump_height * strength
	sprite.scale = Vector2(0.66, 1.33)
	create_tween().tween_property(sprite, "scale", Vector2(1, 1), 0.25)
	
	var shockwave = VfxManager.play_vfx("shockwave", global_position + velocitycomp.vel * 0.05, 0, Vector2.ONE * .33)
	shockwave.modulate = Color("#5a6988")
	shockwave.z_index = -1
	
	trail1.turn_off()
	trail2.turn_off()

func land():
	var shockwave = VfxManager.play_vfx("shockwave", global_position + velocitycomp.vel * 0.05, 0, Vector2.ONE * .5)
	shockwave.modulate = Color("#5a6988")
	shockwave.z_index = -1
	
	var scale_rn = sprite.scale
	sprite.scale = Vector2(1.33, 0.66)
	get_tree().create_tween().tween_property(sprite, "scale", scale_rn, .2)
	
	trail1.turn_on()
	trail2.turn_on()
#endregion

#region Death
func try_dying() -> bool:
	if fatal_speed():
		die()
		return true
	return false

func die():
	jump(2.0); animator.play("die")
	VfxManager.play_vfx("puddle", global_position, 0, Vector2(.5, .5), -1)
	VfxManager.play_vfx("blood_impact", global_position)
	
	trail1.turn_off(); trail2.turn_off()
	
	velocitycomp.vel *= 1.5
	collider.set_deferred("disabled", true)
	
	dead = true
	speed_particles.emitting = false
	scarf.processing = false
	hair.processing = false

func fatal_speed() -> bool:
	return velocitycomp.vel.length() > max_speed * .7

func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name != "die":
		return
	
	# On death animation end
	scarf.processing = true
	hair.processing = true
	
	VfxManager.play_vfx("puddle", global_position, 0, Vector2(.65, .65), -1)
	await(get_tree().create_timer(0.2).timeout)
	VfxManager.play_vfx("puddle", global_position, 0, Vector2(1, 1), -1)
	
	get_parent().death_animator.play("death")
	get_parent().post_processing_death_anim()
#endregion
