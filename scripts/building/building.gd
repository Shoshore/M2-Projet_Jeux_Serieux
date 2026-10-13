@abstract
class_name Building

var _position: Position_component

var _id: int

var texture: Texture2D = null

func _init(id: int, spawn_point: Vector2i) -> void:
	_id = id
	_position = Position_component.new(spawn_point)

@abstract func display() -> void

func get_position() -> Vector2i:
	return _position._position
