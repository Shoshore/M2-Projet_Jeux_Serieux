extends Node2D

var map = Map.new()
@onready var label_info: Label = get_node("CanvasLayer/info/Label")

func _ready() -> void:
	map.generer_grille_hexagonale(10)
	add_child(map)
	
func _process(delta: float) -> void:
	pass
