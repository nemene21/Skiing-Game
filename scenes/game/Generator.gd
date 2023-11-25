extends Node

@onready var scene := get_parent()
@onready var log_scene := preload("res://scenes/game/obstacles/log/log.tscn")

func _ready() -> void:
	generate.call_deferred()

func generate() -> void:
	var points := 10.0
	var length := 1000.0
	
	var noise := FastNoiseLite.new()
	for i in points:
		var pos := length * (i / points)
		var noise_value := noise.get_noise_1d(pos)
		
		var log := log_scene.instantiate()
		add_sibling(log)
		
		log.global_position = Vector2(noise_value + 160, -pos)
