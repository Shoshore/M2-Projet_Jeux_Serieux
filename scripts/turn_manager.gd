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
	$CanvasLayer2/Control/HBoxContainer/Tour_info/Label.text = "Tour " + str(current_turn) +"/"+str(game_length)

	
func _map_filling(map: Map) -> void:
	var origin := Vector2i(0, 0)
	var tile: Tile = map.tiles_by_coord[origin]
	var player_company = Company.new(0, origin, map)
	
	tile.building = player_company #modifier constructeur si nécessaire
	company_array[0] = player_company
	tile.reload_visual()

#func _process(delta: float) -> void:
	




	
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


func _on_button_pressed() -> void:
	$CanvasLayer2/Control/Button/AudioClick.play()
	current_turn+=1
	$CanvasLayer2/Control/HBoxContainer/Tour_info/Label.text = "Tour " + str(current_turn) +"/"+str(game_length)
	_update_companies(current_turn)
	
