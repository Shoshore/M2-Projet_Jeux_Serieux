extends Control

# Chargement de notre liste de compétence (ressource)
const TREE: SkillTree = preload("res://data/skillTree.tres") 

# Pour savoir quelles compétences ont été débloquées par le joueur
var unlocked: Array[StringName] = []

# Visuels
var lineWidth = 10.0
var colorLineOrigin = Color.WEB_GRAY
var colorLineTech1 = Color.WEB_GRAY
var colorLineTech2 = Color.WEB_GRAY
var colorLineTech3 = Color.WEB_GRAY
var colorLineHuman1 = Color.WEB_GRAY
var colorLineHuman2 = Color.WEB_GRAY
var colorLineHuman3 = Color.WEB_GRAY

# Compétences technologies
@onready var button_tech_1: Button = $HBoxContainerGlobal/VBoxContainer/HBoxContainer/VBoxContainer/Button
@onready var button_tech_2: Button = $HBoxContainerGlobal/VBoxContainer/HBoxContainer/VBoxContainer/Button2
@onready var button_tech_3: Button = $HBoxContainerGlobal/VBoxContainer/HBoxContainer/VBoxContainer/Button3
@onready var button_tech_4: Button = $HBoxContainerGlobal/VBoxContainer/HBoxContainer/VBoxContainer/Button4

# Compétences humaines
@onready var button_human_1: Button = $HBoxContainerGlobal/VBoxContainer/HBoxContainer/VBoxContainer2/Button
@onready var button_human_2: Button = $HBoxContainerGlobal/VBoxContainer/HBoxContainer/VBoxContainer2/Button2
@onready var button_human_3: Button = $HBoxContainerGlobal/VBoxContainer/HBoxContainer/VBoxContainer2/Button3
@onready var button_human_4: Button = $HBoxContainerGlobal/VBoxContainer/HBoxContainer/VBoxContainer2/Button4

# Origine de l'arbre
@onready var button_origin: Button = $HBoxContainerGlobal/VBoxContainer/HBoxContainer2/ButtonOrigin

# Bouton de changement vers le plateau/arbre
@onready var tree_button: Button = $"../TreeButton"

@onready var skill_name: Label = $ControlSkillInfos/VBoxContainer/PanelContainer/SkillName
@onready var skill_description: Label = $ControlSkillInfos/VBoxContainer/PanelContainer2/SkillDescription
@onready var unlock_button: Button = $ControlSkillInfos/VBoxContainer/UnlockButton

var last_click = ""
var lock_text = "Débloquer"
var unlock_text = "Acquis"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resized.connect(queue_redraw)
	# On redessine les lignes une fois que les boutons sont bien placé
	$HBoxContainerGlobal/VBoxContainer/HBoxContainer/VBoxContainer.sort_children.connect(queue_redraw)
	$HBoxContainerGlobal/VBoxContainer/HBoxContainer/VBoxContainer2.sort_children.connect(queue_redraw)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func can_unlock_skill(s: Skill) -> bool :
	# Si la compétence est déjà débloqué on la débloque pas
	if s.id in unlocked:
		return false
	# Si on a pas les prérequis pour débloquer la compétence on la débloque pas
	for r in s.requierment:
		if r.id not in unlocked:
			return false
	# Sinon on débloque la compétence
	return true

func unlock(s: Skill) -> void:
	if can_unlock_skill(s):
		unlocked.append(s.id)

func buttonCenter(button: Control):
	return button.get_global_rect().get_center() - global_position ;

func _draw() -> void:
	draw_line(buttonCenter(button_origin), buttonCenter(button_human_1), colorLineOrigin, lineWidth)
	draw_line(buttonCenter(button_origin), buttonCenter(button_tech_1), colorLineOrigin, lineWidth)
	draw_line(buttonCenter(button_tech_1), buttonCenter(button_tech_2), colorLineTech1, lineWidth)
	draw_line(buttonCenter(button_tech_2), buttonCenter(button_tech_3), colorLineTech2, lineWidth)
	draw_line(buttonCenter(button_tech_3), buttonCenter(button_tech_4), colorLineTech3, lineWidth)
	draw_line(buttonCenter(button_human_1), buttonCenter(button_human_2), colorLineHuman1, lineWidth)
	draw_line(buttonCenter(button_human_2), buttonCenter(button_human_3), colorLineHuman2, lineWidth)
	draw_line(buttonCenter(button_human_3), buttonCenter(button_human_4), colorLineHuman3, lineWidth)

# Comportement des boutons
func _on_button_origin_toggled(toggled_on: bool) -> void:
	last_click = "origin"
	if toggled_on:
		var skill = TREE.get_skill(last_click)
		skill_name.text = skill.name
		skill_description.text = skill.description
		if last_click in unlocked:
			unlock_button.text = unlock_text
		else:
			unlock_button.text = lock_text
		if can_unlock_skill(skill):
			unlock_button.disabled = false
	else: # Désaffiche la fenetre 
		skill_name.text = ""
		skill_description.text = ""
		unlock_button.disabled = true

func _on_button_tech1_toggled(toggled_on: bool) -> void:
	last_click = "tech_1"
	if toggled_on:
		var skill = TREE.get_skill(last_click)
		skill_name.text = skill.name
		skill_description.text = skill.description
		if last_click in unlocked:
			unlock_button.text = unlock_text
		else:
			unlock_button.text = lock_text
		if can_unlock_skill(skill):
			unlock_button.disabled = false
	else: # Désaffiche la fenetre 
		skill_name.text = ""
		skill_description.text = ""
		unlock_button.disabled = true

func _on_button_tech2_toggled(toggled_on: bool) -> void:
	last_click = "tech_2"
	if toggled_on:
		var skill = TREE.get_skill(last_click)
		skill_name.text = skill.name
		skill_description.text = skill.description
		if last_click in unlocked:
			unlock_button.text = unlock_text
		else:
			unlock_button.text = lock_text
		if can_unlock_skill(skill):
			unlock_button.disabled = false
	else: # Désaffiche la fenetre 
		skill_name.text = ""
		skill_description.text = ""
		unlock_button.disabled = true

func _on_button_tech3_toggled(toggled_on: bool) -> void:
	last_click = "tech_3"
	if toggled_on:
		var skill = TREE.get_skill(last_click)
		skill_name.text = skill.name
		skill_description.text = skill.description
		if last_click in unlocked:
			unlock_button.text = unlock_text
		else:
			unlock_button.text = lock_text
		if can_unlock_skill(skill):
			unlock_button.disabled = false
	else: # Désaffiche la fenetre 
		skill_name.text = ""
		skill_description.text = ""
		unlock_button.disabled = true

func _on_button_tech4_toggled(toggled_on: bool) -> void:
	last_click = "tech_4"
	if toggled_on:
		var skill = TREE.get_skill(last_click)
		skill_name.text = skill.name
		skill_description.text = skill.description
		if last_click in unlocked:
			unlock_button.text = unlock_text
		else:
			unlock_button.text = lock_text
		if can_unlock_skill(skill):
			unlock_button.disabled = false
	else: # Désaffiche la fenetre 
		skill_name.text = ""
		skill_description.text = ""
		unlock_button.disabled = true

func _on_button_human1_toggled(toggled_on: bool) -> void:
	last_click = "human_1"
	if toggled_on:
		var skill = TREE.get_skill(last_click)
		skill_name.text = skill.name
		skill_description.text = skill.description
		if last_click in unlocked:
			unlock_button.text = unlock_text
		else:
			unlock_button.text = lock_text
		if can_unlock_skill(skill):
			unlock_button.disabled = false
	else: # Désaffiche la fenetre 
		skill_name.text = ""
		skill_description.text = ""
		unlock_button.disabled = true

func _on_button_human2_toggled(toggled_on: bool) -> void:
	last_click = "human_2"
	if toggled_on:
		var skill = TREE.get_skill(last_click)
		skill_name.text = skill.name
		skill_description.text = skill.description
		if last_click in unlocked:
			unlock_button.text = unlock_text
		else:
			unlock_button.text = lock_text
		if can_unlock_skill(skill):
			unlock_button.disabled = false
	else: # Désaffiche la fenetre 
		skill_name.text = ""
		skill_description.text = ""
		unlock_button.disabled = true

func _on_button_human3_toggled(toggled_on: bool) -> void:
	last_click = "human_3"
	if toggled_on:
		var skill = TREE.get_skill(last_click)
		skill_name.text = skill.name
		skill_description.text = skill.description
		if last_click in unlocked:
			unlock_button.text = unlock_text
		else:
			unlock_button.text = lock_text
		if can_unlock_skill(skill):
			unlock_button.disabled = false
	else: # Désaffiche la fenetre 
		skill_name.text = ""
		skill_description.text = ""
		unlock_button.disabled = true

func _on_button_human4_toggled(toggled_on: bool) -> void:
	last_click = "human_4"
	if toggled_on:
		var skill = TREE.get_skill(last_click)
		skill_name.text = skill.name
		skill_description.text = skill.description
		if last_click in unlocked:
			unlock_button.text = unlock_text
		else:
			unlock_button.text = lock_text
		if can_unlock_skill(skill):
			unlock_button.disabled = false
	else: # Désaffiche la fenetre 
		skill_name.text = ""
		skill_description.text = ""
		unlock_button.disabled = true

func _on_unlock_button_pressed() -> void:
	var skill = TREE.get_skill(last_click)
	unlock(skill)
	unlock_button.disabled = true
	unlock_button.text = unlock_text
	match skill.id:
		"origin":
			colorLineOrigin = Color.GOLDENROD
		"tech_1":
			colorLineTech1 = Color.GOLDENROD
		"tech_2":
			colorLineTech2 = Color.GOLDENROD
		"tech_3":
			colorLineTech3 = Color.GOLDENROD
		"human_1":
			colorLineHuman1 = Color.GOLDENROD
		"human_2":
			colorLineHuman2 = Color.GOLDENROD
		"human_3":
			colorLineHuman3 = Color.GOLDENROD
	queue_redraw()
