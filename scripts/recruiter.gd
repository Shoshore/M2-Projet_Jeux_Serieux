extends Node2D
class_name Recruiter

var vision: Vision_component = Vision_component.new(3)

var movement: Movement_component = Movement_component.new(3)

var id: int:
			get: return _id
var _id: int

var compagny_id: int:
			get: return _id
var _compagny_id: int

func _init(compagny_id: int, id: int) -> void:
	_compagny_id = compagny_id
	_id = id

# todo maybe something that make only him can get ressources
