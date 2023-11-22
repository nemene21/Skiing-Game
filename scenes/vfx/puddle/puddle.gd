extends ColorRect

func _ready() -> void:
	global_position -= size * get_parent().scale
	rotation = randf() * 2*PI
	
