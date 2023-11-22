extends Line2D

@export var pivot: Node2D
@export var length := 16
@export var border := 32.0
@export var randomness := .0

var processing := true

func _process(delta: float) -> void:
	if !processing:
		return
	
	global_position = Vector2.ZERO
	
	add_point(pivot.global_position + Vector2(randf_range(-randomness, randomness), randf_range(-randomness, randomness)))
	
	var killed := 0 
	for i in get_point_count():
		if get_point_position(i - killed).distance_to(pivot.global_position) > border:
			remove_point(i - killed)
			killed += 1
	
	if length != -1:
		if get_point_count() > length:
			remove_point(0)


func turn_on():
	processing = true

func turn_off(kill_time: float = 80.0) -> void:
	processing = false
	var line = Line2D.new()
	line.global_position = Vector2.ZERO
	
	for i in get_point_count():
		line.add_point(get_point_position(i))
		
	line.default_color = default_color
	line.width = width
	line.width_curve = width_curve
	line.z_index = z_index
	
	var timer = Timer.new()
	timer.wait_time = kill_time
	line.add_child(timer)
	timer.connect("timeout", line.queue_free)
	timer.autostart = true
	
	clear_points()
	
	VfxManager.target.add_child(line)
