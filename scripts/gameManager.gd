extends Node2D

var map := Map.new()
var selection := Selection_controller.new(map)
@onready var label_info: Label = get_node("CanvasLayer/info/Label")

func _ready() -> void:
	add_child(map)
	map.tile_clicked.connect(selection.on_tile_clicked)
	map.tile_clicked.connect(_on_tile_clicked)

func _on_tile_clicked(tile: Tile) -> void:
	label_info.text = tile.get_info_text()
