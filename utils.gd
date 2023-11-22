extends Node

var time := .0
var player

func _process(delta: float) -> void:
	time += delta

## Frame independent lerp (delta lerp)
func dlerp(a, b, speed):
	var delta = get_process_delta_time()
	var blend = pow(.5, delta * speed)
	return lerp(b, a, blend)

func remove_file_ending(filename: String) -> String:
	var dot = filename.find(".")
	return filename.left(dot)
