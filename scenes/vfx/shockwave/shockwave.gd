extends ColorRect

func _ready() -> void:
	global_position -= size * get_parent().scale


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
