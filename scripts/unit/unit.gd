extends Node2D
class_name Unit

var vision: Vision_component
var movement: Movement_component
var id: Id_component

var _compagny_id: int
var texture: Texture_component

func _init(compagny_id: int, id_: int, spawn_point: Vector2i, max_movement: int, vision_range: int, texture_: Texture2D) -> void:
	_compagny_id = compagny_id
	id = Id_component.new(id_)
	vision = Vision_component.new(vision_range)
	movement = Movement_component.new(max_movement, Position_component.new(spawn_point))
	texture = Texture_component.new(texture_)

func update_end_turn() -> void:
	movement.update_end_turn()
