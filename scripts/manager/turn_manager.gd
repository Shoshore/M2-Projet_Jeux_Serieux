extends Node

var boardText = "Carte du monde"
var skillTreeText = "Arbre de compétence"

var map := Map.new()
var selection_manager := Selection_manager.new(map)
@onready var label_info: Label = get_node("CanvasLayer/info/Label")

const GAME_LENGTH := 30
var current_turn := 1
const MAX_STITCH_TURN := 2
var current_stitch_turn := 0

var company_array : Dictionary[int, Company] = {} # id -> Company
var recrutement_building_array : Dictionary[int, Recruitement_building] = {}

@onready var boardObject: Node2D = $"."
@onready var skill_tree: SkillTree = $HUD/SkillTree
@onready var tree_button: Button = $HUD/TreeButton
@onready var round_button: Button = $HUD/Control/End_turn_button
@onready var tiles_info: PanelContainer = $CanvasLayer/info
@onready var window_info_label: Control = $HUD/Control/HBoxContainer/Window_info/Label

func _ready() -> void:
	add_child(map)
	Global.company_fire_employee.connect(_delete_unit)
	Global.recruitement_give_employee.connect(_give_employee)
	_map_filling(map)
	$HUD/Control/HBoxContainer/Tour_info/Label.text = "Tour " + str(current_turn) +"/"+str(GAME_LENGTH)


func _map_filling(map: Map) -> void:
	var origin := Vector2i(0, 0)
	var tile: Tile = map.tiles_by_coord[origin]
	company_array[0] = Company.new(0, origin, 5)
	var current_compagny = company_array[0]
	current_compagny.create_unit(map.get_free_neighbor(current_compagny.position.get_position()), Company.Create_unit_type.RECRUITER)
	tile.set_building(current_compagny)
	tile.reload_visual()

	var pos_recruitement := Vector2i(2, -2)
	var tile_recruitement : Tile = map.tiles_by_coord[pos_recruitement]
	var recruitement_building := Recruitement_building.new(0, pos_recruitement, Recruitement_building.Ressources.DEVELOPPER)
	tile_recruitement.set_building(recruitement_building)
	recrutement_building_array[0] = recruitement_building
	tile_recruitement.reload_visual()

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

func _update_companies() -> void:
	for key in company_array:
		company_array.get(key).update_end_turn(current_turn)
		company_array.get(key).display()


func _update_recruitement_building() -> void:
	for key in recrutement_building_array:
		recrutement_building_array[0].update_end_turn(map.get_occuped_neighbor(recrutement_building_array[0].position.get_position()))

func _on_end_turn_button_pressed() -> void:
	$HUD/Control/End_turn_button/AudioClick.play()
	current_turn += 1
	_update_companies()
	_update_recruitement_building()
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
		selection_manager.on_tile_clicked(tile)
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

# ------------
# signals
# ------------
func _delete_unit(position: Vector2i) -> void:
	var tile := map.get_tile_at(position)
	if tile != null:
		tile.occupant = null
		tile.reload_visual()


func _give_employee(id: int, ressource: Recruitement_building.Ressources) -> void:
	company_array[id].set_ressources(ressource)
