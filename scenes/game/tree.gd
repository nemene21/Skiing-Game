extends Sprite2D

@onready var greenery := $Greenery

func _ready() -> void:
	rotation = randf_range(-.1, .1)

func _process(delta: float) -> void:
	greenery.rotation = sin(Utils.time + global_position.x + global_position.y) * 0.075
