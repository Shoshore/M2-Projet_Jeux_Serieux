class_name Position_component
extends RefCounted

var _position: Vector2i

func _init(spawn_position: Vector2i = Vector2i.ZERO) -> void:
	_position = spawn_position


func get_position() -> Vector2i:
	return _position


func set_position(position: Vector2i) -> void:
	_position = position
