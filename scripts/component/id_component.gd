class_name Id_component
extends RefCounted

var _id : int


func _init(id : int) -> void:
	_id = id


func get_id() -> int:
	return _id
