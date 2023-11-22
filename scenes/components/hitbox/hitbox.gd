extends Area2D

@export var height := 1000.0

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player") and Utils.player.height < height:
		Utils.player.try_dying()
