class_name Position_component
extends RefCounted

var position: Vector2i

func _init(spawn_position: Vector2i = Vector2i.ZERO) -> void:
	position = spawn_position
