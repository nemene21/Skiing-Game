extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skew = randf_range(-.2, .2)
