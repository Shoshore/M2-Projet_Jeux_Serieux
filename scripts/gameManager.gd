extends Node2D

var map := Map.new()
var selection := Selection_controller.new(map)
@onready var label_info: Label = get_node("CanvasLayer/info/Label")

func _ready() -> void:
	add_child(map)
	_map_filling(map)
	map.tile_clicked.connect(selection.on_tile_clicked)
	map.tile_clicked.connect(_on_tile_clicked)

func _on_tile_clicked(tile: Tile) -> void:
	label_info.text = tile.get_info_text()
	var build = tile.building
	if build:
		build.display()


func _on_tree_button_toggled(toggled_on: bool) -> void:
	map.is_board_clickable = !toggled_on

func _map_filling(map: Map) -> void:
	var origin := Vector2i(0, 0)
	var tile: Tile = map.tiles_by_coord[origin]
	tile.building = Compagny.new(0, origin, map)
	tile.reload_visual()
