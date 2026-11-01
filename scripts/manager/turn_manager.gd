extends Node

var boardText = "Carte du monde"
var skillTreeText = "Arbre de compétence"

var map := Map.new()
var selection_manager := Selection_manager.new(map)
@onready var label_info: RichTextLabel = get_node("InfoBox/Info_node/Info_container/Info_panel/Info_label")

const GAME_LENGTH := 30
var current_turn := 1
const MAX_STITCH_TURN := 2
var current_stitch_turn := 0

const TURN_SHARE_HOLDER = 5
var turn_wait_share_holder = 0

var company_array : Dictionary[int, Company] = {} # id -> Company
var recrutement_building_array : Dictionary[int, Recruitement_building] = {}

@onready var boardObject: Node2D = $"."
@onready var skill_tree: Control = $HUD/SkillTree
@onready var tree_button: Button = $HUD/TreeButton
@onready var round_button: Button = $HUD/Control/End_turn_button
@onready var tiles_info: Control = $InfoBox/Info_node
@onready var window_info_label: Control = $HUD/Control/HBoxContainer/Window_info/Label
@onready var ressources_label: Label = $HUD/Control/HBoxContainer/Ressources/Label

func _ready() -> void:
	add_child(map)
	Global.company_fire_employee.connect(_delete_unit)
	Global.recruitement_give_employee.connect(_give_employee)
	selection_manager.info_reset.connect(_on_tile_clicked)
	_map_filling(map)
	$HUD/Control/HBoxContainer/Tour_info/Label.text = "Tour " + str(current_turn) +" /" +str(GAME_LENGTH)
	skill_tree.unlocked_skill.connect(_on_skill_unlock)
	skill_tree.company = company_array[0]
	_update_company_info()


func _map_filling(map: Map) -> void:
	company_array[0] = map.create_company(Vector2i(0, 0), 0)
	var ressources := map.create_ressources(10, 3)
	var size := ressources.size()
	for idx in range(size):
		recrutement_building_array[idx] = ressources[idx]


func update_result(score : int, turn : int, status : String):
	Global.game_result.set_score(score)
	Global.game_result.set_turn(turn)
	Global.game_result.set_status(status)
	print("score : ", Global.game_result.get_score(),
	"\n turn : ", Global.game_result.get_turn(),
	"\n satus : ", Global.game_result.get_status())


func _end_check():
	if current_turn > GAME_LENGTH:
		update_result(company_array[0].get_funds(), current_turn - 1, "Victoire")
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
	var funds = company_array[0].get_funds()
	if funds < 0:
		current_stitch_turn += 1
		if current_stitch_turn > MAX_STITCH_TURN:
			update_result(company_array[0].get_funds(), current_turn, "Défaite")
			get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
	else:
		current_stitch_turn = 0


func _update_companies() -> void:
	for key in company_array:
		company_array.get(key).update_end_turn(current_turn)
		company_array.get(key).display()


func _update_recruitement_building() -> void:
	for key in recrutement_building_array:
		var build = recrutement_building_array.get(key)
		build.update_end_turn(map.get_occuped_neighbor(build.position.get_position()))


func _on_end_turn_button_pressed() -> void:
	$HUD/Control/End_turn_button/AudioClick.play()
	current_turn += 1
	_update_recruitement_building()
	_update_companies()
	_update_company_info()
	_end_check()
	$HUD/Control/HBoxContainer/Tour_info/Label.text = "Tour " + str(current_turn) +"/"+str(GAME_LENGTH)
	_on_tile_clicked(selection_manager.selected_tile)
	if turn_wait_share_holder > 0:
		turn_wait_share_holder -= 1


func _on_tile_clicked(tile: Tile) -> void:
	if tile.is_visible_by_fog:
		var text = tile.get_info_text(company_array[0], current_turn)
		if tile.get_building() == company_array[0]:
			text +=  "Tour avant le prochain emprunt : " + str(turn_wait_share_holder) + "\n"
			if company_array[0]._funds < 0:
				text += "Tour avant de faire fahite : " + str(2 - current_stitch_turn)
			var b: Control = $InfoBox/Info_node/Info_container/Fire_employe
			print("visible: ", b.visible, " | in tree: ", b.is_visible_in_tree(), " | size: ", b.size, " | pos: ", b.global_position)
			$InfoBox/Info_node/Info_container/Fire_employe.visible = true
			$InfoBox/Info_node/Info_container/Pay_share_holder.visible = true
		else:
			$InfoBox/Info_node/Info_container/Fire_employe.visible = false
			$InfoBox/Info_node/Info_container/Pay_share_holder.visible = false
		label_info.text = text
	else:
		label_info.text = "Le brouillard vous empêche de savoir \n ce qu'il  y a sur cette hexagone"


func _on_input_board_click(position: Vector2) -> void:
	if(!map.is_board_clickable): return
	var coord := map.pixel_to_coords(position)
	var tile := map.get_tile_at(coord)
	if tile != null:
		_on_tile_clicked(tile)
		selection_manager.on_tile_clicked(tile)


func _go_to_skill_tree() -> void:
	var currentValue = map.is_board_clickable
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


func _on_skill_unlock(skill: Skill) -> void:
	var company: Company = company_array[0]
	company.apply_skill(skill)


# ------------
# signals
# ------------
func _delete_unit(position: Vector2i) -> void:
	var tile := map.get_tile_at(position)
	if tile != null:
		tile._occupant = null
		tile.reload_visual()


func _give_employee(id: int, ressource: Recruitement_building.Ressources) -> void:
	company_array[id].set_ressources(ressource)


func _update_company_info() -> void:
	var company: Company = company_array[0]

	ressources_label.text = (
		"Argent: " + str(company.get_funds()) + "\n"
		+ "Employés: " + str(company.get_number_employees()) + "\n"
		+ "Developpeurs: " + str(company.get_number_developers()) + "|"
		+ "Chercheurs: " + str(company.get_number_researchers()) + "|"
		+ "Recruteurs: " + str(company.get_number_recruiters()) + "\n"
		+ "Bonheur: " + str(company.get_happiness()) + "  bonheur à atteindre est : " + str(company.get_mood_threshold())
	)


func _on_fire_button_item_selected(index: int) -> void:
	match index:
		1:
			print("test")
			company_array[0].fire_employee(Company.Employee_type.RESEARCHER)
		2:
			print("c")
			company_array[0].fire_employee(Company.Employee_type.DEVELOPER)
		3:
			print("ici")
			company_array[0].fire_employee(Company.Employee_type.RECRUITER, 0)
	_on_tile_clicked(map.get_tile_at(Vector2i(0, 0)))


func _on_share_holder_pressed() -> void:
	if turn_wait_share_holder != 0:
		return
	
	var player = company_array[0]
	player.borrowed()
	turn_wait_share_holder = TURN_SHARE_HOLDER
	_on_tile_clicked(map.get_tile_at(Vector2i(0, 0)))
