@abstract
class_name Building


var position: Position_component
var id: Id_component
var texture: Texture_component

func _init(id_: int, spawn_point: Vector2i, texture_: Texture2D) -> void:
	id = Id_component.new(id_)
	position = Position_component.new(spawn_point)
	texture = Texture_component.new(texture_)

@abstract func display() -> void
