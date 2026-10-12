extends Node

var map := Map.new()
var selection := Selection_controller.new(map)
@onready var label_info: Label = get_node("CanvasLayer/info/Label")

var game_length := 30
var current_turn := 1

var company_array : Dictionary[int,Company] = {} # id -> Company


func _ready() -> void:
	add_child(map)
	_map_filling(map)
	$HUD/Control/HBoxContainer/Tour_info/Label.text = "Tour " + str(current_turn) +"/"+str(game_length)

	
func _map_filling(map: Map) -> void:
	var origin := Vector2i(0, 0)
	var tile: Tile = map.tiles_by_coord[origin]
	var player_company = Company.new(0, origin, map)
	
	tile.building = player_company #modifier constructeur si nécessaire
	company_array[0] = player_company
	tile.reload_visual()


# Les datas des entreprises :
# si t'as ressources -> tu peux faire des trucs dans le skilltree
# faire des getters, des fonctions de gestions 
# L'argent
# le bonheur 
# les unités
# chercheurs/dev

# les positions des sites de recrutements
# les stackeholders 

# Gestion de tours malus :
# mod tour X -> modifie un truc 

func _update_companies(tour : int) ->void:
	for key in company_array:
		company_array.get(key).update_end_turn(tour)


func _on_end_turn_button_pressed() -> void:
	$HUD/Control/End_turn_button/AudioClick.play()
	current_turn+=1
	$HUD/Control/HBoxContainer/Tour_info/Label.text = "Tour " + str(current_turn) +"/"+str(game_length)
	_update_companies(current_turn)


func _on_tile_clicked(tile: Tile) -> void:
	label_info.text = tile.get_info_text()
	var build = tile.building
	if build:
		build.display()


func _on_input_board_click(position: Vector2) -> void:
	var coord := map.pixel_to_coords(position)
	var tile := map.get_tile_at(coord)
	if tile != null:
		_on_tile_clicked(tile)
		selection.on_tile_clicked(tile)
		print("tile")
	else:
		print("no tile")
