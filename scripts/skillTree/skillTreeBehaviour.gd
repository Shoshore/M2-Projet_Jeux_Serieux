extends Control

# Chargement de notre liste de compétence (ressource)
const TREE: SkillTree = preload("res://data/skillTree.tres") 

# Signal pour appliquer les compétences
signal unlocked_skill(skill: Skill)

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
const lock_text = "Débloquer"
const unlock_text = "Acquis"

# Compétences technologies
@onready var button_tech_1: Button = $HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer/VBoxContainer/Button
@onready var button_tech_2: Button = $HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer/VBoxContainer/Button2
@onready var button_tech_3: Button = $HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer/VBoxContainer/Button3
@onready var button_tech_4: Button = $HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer/VBoxContainer/Button4

# Compétences humaines
@onready var button_human_1: Button = $HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer/VBoxContainer2/Button
@onready var button_human_2: Button = $HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer/VBoxContainer2/Button2
@onready var button_human_3: Button = $HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer/VBoxContainer2/Button3
@onready var button_human_4: Button = $HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer/VBoxContainer2/Button4

# Origine de l'arbre
@onready var button_origin: Button = $HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer2/ButtonOrigin

# Bouton de changement vers le plateau/arbre
@onready var tree_button: Button = $"../TreeButton"

# Affichage des compétences
@onready var skill_name: Label = $HBoxContainer/HBoxContainerInfos/VBoxContainerInfos/PanelContainer/SkillName
@onready var skill_icon: TextureRect = $HBoxContainer/HBoxContainerInfos/VBoxContainerInfos/PanelContainer2/VBoxContainer/SkillIcon
@onready var skill_description: Label = $HBoxContainer/HBoxContainerInfos/VBoxContainerInfos/PanelContainer2/VBoxContainer/SkillDescription
@onready var unlock_button: Button = $HBoxContainer/HBoxContainerInfos/VBoxContainerInfos/UnlockButton
@onready var audio_click: AudioStreamPlayer2D = $HBoxContainer/HBoxContainerInfos/VBoxContainerInfos/UnlockButton/AudioClick
# Audio trouvé ici : https://pixabay.com/fr/sound-effects/films-et-effets-sp%C3%A9ciaux-click-level-up-524643/

var last_click = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resized.connect(queue_redraw)
	# On redessine les lignes une fois que les boutons sont bien placé
	$HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer/VBoxContainer.sort_children.connect(queue_redraw)
	$HBoxContainer/HBoxContainerSkillTree/VBoxContainer/HBoxContainer/VBoxContainer2.sort_children.connect(queue_redraw)
	
	# Connexion des boutons aux signaux mouse entered/exited
	for button in button_origin.button_group.get_buttons():
		button.mouse_entered.connect(_on_buttons_entered.bind(button))
		button.mouse_exited.connect(_on_buttons_exited)
		button.toggled.connect(_on_skill_button_toggled.bind(button))



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
		unlocked_skill.emit(s)
		audio_click.play()

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

# Affichage de la compétence dans la fenetre
func display_skill(skill: Skill) -> void:
	skill_name.text = skill.name
	skill_description.text = skill.description
	if skill.id in unlocked:
		unlock_button.text = unlock_text
	else:
		unlock_button.text = lock_text
	if can_unlock_skill(skill):
		unlock_button.disabled = false
	if skill.icone:
		skill_icon.visible = true
		skill_icon.texture = skill.icone
	else:
		skill_icon.visible = false

# Réinitialise la fenetre
func undisplay_skill() -> void:
	skill_name.text = ""
	skill_description.text = ""
	unlock_button.disabled = true
	skill_icon.visible = false

# Comportement des boutons
func _on_skill_button_toggled(toggled_on: bool, button: Button) -> void:
	last_click = button.skill.id
	if toggled_on :
		display_skill(button.skill)
	else:
		undisplay_skill()

# Débloquer une compétence
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

# Affichage des compétences quand aucune n'est sélectionné
func _on_buttons_entered(button: Button) -> void:
	if last_click == "":
		display_skill(button.skill)

func _on_buttons_exited() -> void:
	if last_click == "":
		undisplay_skill()

# Déselectionne une compétence en cliquant n'importe où ailleurs
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Relache le dernier bouton enfoncé
		var pressed_button := button_origin.button_group.get_pressed_button()
		if pressed_button :
			pressed_button.button_pressed = false
		# Désaffiche la compétence
		last_click = ""
		undisplay_skill()
