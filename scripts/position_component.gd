class_name Position_component
extends RefCounted

var position: Vector2

func _init(spawn_position: Vector2 = Vector2.ZERO) -> void:
	position = spawn_position
