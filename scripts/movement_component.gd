class_name Movement_component

var _max_movement: int = 3
var _current_movement: int = 3

var _position : Vector2 = Vector2.ZERO

func _init(max_movement: int, position : Vector2) -> void:
	_max_movement = max_movement
	_position = position

func update_end_turn() -> void:
	_current_movement = _max_movement

# todo :
# movement
func move(new_position: Vector2) -> void:
	if _current_movement < 0:
		return
	
