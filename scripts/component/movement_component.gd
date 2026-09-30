class_name Movement_component

var _max_movement: int = 3
var _current_movement: int = 3

var position: Position_component

func _init(max_movement: int, spawn_position: Position_component) -> void:
	_max_movement = max_movement
	position = spawn_position

func update_end_turn() -> void:
	_current_movement = _max_movement

func get_hex_distance(position_1: Vector2i, position_2: Vector2i) -> int:
	var a : int = position_1.x - position_2.x
	var b : int = position_1.y - position_2.y
	return (abs(a) + abs(a + b) + abs(b)) / 2

func move_to(new_position: Vector2i) -> bool:
	var distance_cost: int = get_hex_distance(position.position, new_position)
	
	if _current_movement < distance_cost:
		return false
	
	_current_movement -= distance_cost
	position.position = new_position
	return true
