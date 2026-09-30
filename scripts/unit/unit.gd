extends Node2D
class_name Unit

var vision: Vision_component
var movement: Movement_component

var id: int:
	get: return _id
var _id: int

var compagny_id: int:
	get: return _compagny_id
var _compagny_id: int

func _init(compagny_id: int, id: int, spawn_point: Vector2i, max_movement: int, vision_range: int) -> void:
	_compagny_id = compagny_id
	_id = id
	vision = Vision_component.new(vision_range)
	movement = Movement_component.new(max_movement, Position_component.new(spawn_point))

func update_end_turn() -> void:
	movement.update_end_turn()
