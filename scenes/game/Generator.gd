extends Node

@export var amplitude := 128.0
@export var frequency := .05
@export var track_width := 180.0

@onready var scene := get_parent()
@onready var log_scene := preload("res://scenes/game/obstacles/log/log.tscn")

@onready var noise := FastNoiseLite.new()

func _ready() -> void:
	generate.call_deferred()

func generate() -> void:
	var length := 2500.0
	var points := length / 200.0
	
	randomize()
	
	for i in points:
		var pos := length * (i / points)
		var noise_value := get_noise(pos)
		
		var log := log_scene.instantiate()
		add_sibling(log)
		
		log.global_position = Vector2(noise_value + 160, -pos)
		
		var chunk = Node2D.new()
		chunk.global_position = Vector2(noise_value + 160, -pos)
		generate_tree_patch(chunk, 96, length / points, Vector2(
			-track_width, 0
		))
		generate_tree_patch(chunk, 160, length / points, Vector2(
			track_width, 0
		))
		chunk.y_sort_enabled = true
		chunk.set_script(chunk_script)
		
		add_sibling(chunk)

@onready var chunk_script := preload("res://scenes/game/chunk.gd")
@onready var tree_scene := preload("res://scenes/game/tree.tscn")

func generate_tree_patch(node: Node, width: float, height: float, offset: Vector2 = Vector2.ZERO) -> void:
	for i in (width * height) / 256:
		var tree = tree_scene.instantiate()
		node.add_child(tree)
		
		tree.position = Vector2(randf_range(-width*.5, width*.5), randf_range(-height*.5, height*.5))
		tree.position += offset

func get_noise(dist: float) -> float:
	return noise.get_noise_1d(dist * frequency) * amplitude
