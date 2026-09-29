extends Node2D
class_name Recruiter

var vision: Vision_component
var movement: Movement_component

var id: int:
			get: return _id
var _id: int

var compagny_id: int:
			get: return _compagny_id
var _compagny_id: int

func _init(compagny_id: int, id: int, spawn_point: Vector2) -> void:
	_compagny_id = compagny_id
	_id = id
	
	vision = Vision_component.new(3)
	movement = Movement_component.new(3, Position_component.new(spawn_point))

# todo maybe something that make only him can get ressources
