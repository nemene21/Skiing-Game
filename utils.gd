extends Node

var time := .0
var player
var res := Vector2(320, 180)

func _process(delta: float) -> void:
	time += delta
	
	if Input.is_action_just_pressed("out"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

## Frame independent lerp (delta lerp)
func dlerp(a, b, speed):
	var delta = get_process_delta_time()
	var blend = pow(.5, delta * speed)
	return lerp(b, a, blend)

func remove_file_ending(filename: String) -> String:
	var dot = filename.find(".")
	return filename.left(dot)
