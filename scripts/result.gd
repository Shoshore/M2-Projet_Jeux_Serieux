class_name Result

var _score : int
var _turn : int
var _status : String

func _init():
	_score = 0
	_turn = 1
	_status = "None"

# ---------------------
# getter
# ---------------------
func get_score() -> int:
	return _score


func get_turn() -> int:
	return _turn


func get_status() -> String:
	return _status
# ---------------------
# setter
# ---------------------
func set_score(score: int) -> void:
	_score = score


func set_turn(turn: int) -> void:
	_turn = turn


func set_status(status: String) -> void:
	_status = status
