extends Node

var _generator := RandomNumberGenerator.new()
var _seed: int = 64

func _ready() -> void:
	_apply_seed()


func _apply_seed() -> void:
	if _seed == 0:
		_generator.randomize()
		_seed = _generator.seed
	else:
		_generator.seed = _seed


func randf() -> float:
	return _generator.randf()


func randi() -> int:
	return _generator.randi()
