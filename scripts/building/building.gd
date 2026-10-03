@abstract
class_name Building

var vision: Vision_component
var position: Position_component
var _map: Map

var id: int:
	get: return _id
var _id: int

var own_color: Color


func _init(id: int, spawn_point: Vector2i, vision_range: int, map: Map, color: Color = Color.AQUA) -> void:
	_id = id
	vision = Vision_component.new(vision_range)
	position = Position_component.new(spawn_point)
	_map = map
	own_color = color

@abstract func display() -> void
