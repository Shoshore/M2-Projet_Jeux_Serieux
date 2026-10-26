extends Node

var _generator := RandomNumberGenerator.new()


func _ready() -> void:
	_generator.randomize()


func randf() -> float:
	return _generator.randf()
