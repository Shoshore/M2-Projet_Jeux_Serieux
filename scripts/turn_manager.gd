extends Node

var boardText = "Carte du monde"
var skillTreeText = "Arbre de compétence"

var map := Map.new()
var selection := Selection_controller.new(map)
@onready var label_info: Label = get_node("CanvasLayer/info/Label")

const GAME_LENGTH := 30
var current_turn := 1
const MAX_STITCH_TURN := 2
var current_stitch_turn := 0

var company_array : Dictionary[int,Company] = {} # id -> Company

@onready var boardObject: Node2D = $"."
@onready var skill_tree: SkillTree = $HUD/SkillTree
@onready var tree_button: Button = $HUD/TreeButton
@onready var round_button: Button = $HUD/Control/End_turn_button
@onready var tiles_info: PanelContainer = $CanvasLayer/info
@onready var window_info_label: Control = $HUD/Control/HBoxContainer/Window_info/Label

func _ready() -> void:
	add_child(map)
	_map_filling(map)
	$HUD/Control/HBoxContainer/Tour_info/Label.text = "Tour " + str(current_turn) +"/"+str(GAME_LENGTH)

	
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


func update_result(score : int, turn : int, status : String):
	Global.game_result.set_score(score)
	Global.game_result.set_turn(turn)
	Global.game_result.set_status(status)
	print("score : ", Global.game_result.get_score(),
	"\n turn : ", Global.game_result.get_turn(),
	"\n satus : ", Global.game_result.get_status())

# TODO faire le switch de scène
func _end_check():
	if current_turn > GAME_LENGTH:
		update_result(company_array[0].get_funds(), current_turn - 1, "Victoire")
	var funds = company_array[0].get_funds()
	if funds < 0:
		current_stitch_turn += 1
		if current_stitch_turn > MAX_STITCH_TURN:
			update_result(company_array[0].get_funds(), current_turn, "Défaite")
	else:
		current_stitch_turn = 0

func _update_companies() ->void:
	for key in company_array:
		company_array.get(key).update_end_turn(current_turn)
		company_array.get(key).display()


func _on_end_turn_button_pressed() -> void:
	$HUD/Control/End_turn_button/AudioClick.play()
	current_turn += 1
	_update_companies()
	_end_check()
	$HUD/Control/HBoxContainer/Tour_info/Label.text = "Tour " + str(current_turn) +"/"+str(GAME_LENGTH)


func _on_tile_clicked(tile: Tile) -> void:
	label_info.text = tile.get_info_text()


func _on_input_board_click(position: Vector2) -> void:
	if(!map.is_board_clickable): return
	var coord := map.pixel_to_coords(position)
	var tile := map.get_tile_at(coord)
	if tile != null:
		_on_tile_clicked(tile)
		selection.on_tile_clicked(tile)
		print("tile")
	else:
		print("no tile")


func _go_to_skill_tree() -> void:
	var currentValue = map.is_board_clickable
	print("État du plateau au moment du clic : ", currentValue)
	map.is_board_clickable = !currentValue
	boardObject.visible = !currentValue
	round_button.visible = !currentValue
	tiles_info.visible = !currentValue
	skill_tree.visible = currentValue
	if(currentValue):
		tree_button.text = boardText
		window_info_label.text = skillTreeText
	else:
		tree_button.text = skillTreeText
		window_info_label.text = boardText
