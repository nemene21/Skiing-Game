extends CharacterBody2D

var speed := 20.0
var max_speed := 200.0
var steering := .0
var horizontal_vel := .0
var jump_height := 200.0

var direction := -.5*PI

var breaking := false
var dead := false

var height := .0
var grounded := true

@onready var velocitycomp := $VelocityComponent
@onready var skis := $Sprites/skis
@onready var sprite := $Sprites/Sprite
@onready var sprites := $Sprites
@onready var animator := $Animator
@onready var break_particles1 := $BreakParticles
@onready var break_particles2 := $BreakParticles2
@onready var scarf := $Sprites/Scarf
@onready var shadow := $Shadow
@onready var trail1 := $Sprites/Trail
@onready var trail2 := $Sprites/Trail2
@onready var stick1 := $Sprites/Sprite/Stick
@onready var stick2 := $Sprites/Sprite/Stick2


func _ready() -> void:
	velocitycomp.vel.y = -1
	Utils.player = self

func _process(delta: float) -> void:
	if dead:
		velocitycomp.lerp_velocity(Vector2.ZERO, 8.0)
		return
	
	var steering_input := float(Input.is_action_pressed("right")) - float(Input.is_action_pressed("left"))
	var is_breaking := Input.is_action_pressed("right") and Input.is_action_pressed("left")
	var speeding := Input.is_action_pressed("up")
	
	steering = Utils.dlerp(steering, steering_input, 8.0)
	
	if grounded != (height == 0):
		grounded = height == 0
		
		if grounded:
			land()
	
	if is_breaking and grounded:
		velocitycomp.lerp_velocity(Vector2.ZERO, 2.0)
	else:
		var speedup = 1 + int(speeding) * 2
		velocitycomp.accelerate(velocitycomp.vel.normalized() * speed * speedup)
	
	height = max(0, height + horizontal_vel * delta)
	horizontal_vel = Utils.dlerp(horizontal_vel, -jump_height, 6.0)
	
	direction += steering * delta * 5.0
	
	if Input.is_action_just_pressed("up") and grounded:
		jump()
	
	if breaking != is_breaking:
		breaking = is_breaking
		animator.call(["play", "play_backwards"][int(!breaking)], "break")
	
	skis.skew = (direction + PI*.5) * .5
	skis.rotation = PI*.25 + direction * .5
	
	sprite.rotation = steering * 0.25
	
	var ski_nodes = skis.get_children()
	ski_nodes[0].position.y = -max(steering, 0) * 3 - 4
	ski_nodes[1].position.y =  min(steering, 0) * 3 - 4

	var fast_enough = velocitycomp.vel.length() > 50
	break_particles1.emitting = Input.is_action_pressed("left")  and fast_enough
	break_particles2.emitting = Input.is_action_pressed("right") and fast_enough
	
	direction = Utils.dlerp(direction, clamp(direction, -PI*.75, -PI*.25), 12.0)
	
	if grounded:
		velocitycomp.vel = Utils.dlerp(
			velocitycomp.vel,
			velocitycomp.vel.length() * Vector2.RIGHT.rotated(direction),
			4.0
		)
	velocitycomp.cap_velocity(max_speed)

	scarf.randomness = velocitycomp.vel.length()/max_speed * 2
	
	sprite.scale = Utils.dlerp(
		sprite.scale,
		lerp(Vector2(1, 1), Vector2(1.2, 0.7), float(speeding)),
		6.0
	)
	sprites.position.y = -height
	shadow.scale = Vector2(0.484, 1.542) * (1.0 - height/32.0)
	
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

func jump():
	horizontal_vel = jump_height
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
	
	trail1.turn_on()
	trail2.turn_on()

func try_dying() -> bool:
	if velocitycomp.vel.length() > max_speed * .5:
		die()
		return true
	return false

func die():
	jump()
	animator.play("die")
	VfxManager.play_vfx("puddle", global_position, 0, Vector2(.5, .5), -1)
	dead = true
	velocitycomp.vel *= 1.5

func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name != "die":
		return
	
	VfxManager.play_vfx("puddle", global_position, 0, Vector2(.65, .65), -1)
	await(get_tree().create_timer(0.2).timeout)
	VfxManager.play_vfx("puddle", global_position, 0, Vector2(1, 1), -1)
