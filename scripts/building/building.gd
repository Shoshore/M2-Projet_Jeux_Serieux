class_name Building

var vision: Vision_component
var position: Position_component

var id: int:
	get: return _id
var _id: int

func _init(id: int, spawn_point: Vector2i, vision_range: int) -> void:
	_id = id
	vision = Vision_component.new(vision_range)
	position = Position_component.new(spawn_point)
