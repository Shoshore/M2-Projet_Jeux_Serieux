@abstract
class_name Building

var position: Position_component
var _map: Map

var id: int:
	get: return _id
var _id: int

var texture: Texture2D = null

func _init(id: int, spawn_point: Vector2i, map: Map) -> void:
	_id = id
	position = Position_component.new(spawn_point)
	_map = map

@abstract func display() -> void
