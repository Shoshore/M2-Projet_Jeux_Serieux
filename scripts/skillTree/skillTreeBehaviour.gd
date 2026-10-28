extends Control

# Chargement de notre liste de compétence (ressource)
const TREE: SkillTree = preload("res://data/skillTree.tres") 

# Signal pour appliquer les compétences
signal unlocked_skill(skill: Skill)

# Pour savoir quelles compétences ont été débloquées par le joueur
var unlocked: Array[StringName] = []

# Visuels
var lineWidth = 10.0
var colorLineLocked = Color.WEB_GRAY
var colorLineUnlocked = Color.GOLDENROD
const lock_text = "Débloquer"
const unlock_text = "Acquis"

# Boutons de l'arbre rangés par id de compétence, rempli dans _ready
var buttons_by_id: Dictionary[String, Button] = {}

# Origine de l'arbre
@onready var button_origin: Button = $HBoxContainer/SkillTree/VBoxContainer/ORIGIN/ButtonOrigin

# Bouton de changement vers le plateau/arbre
@onready var tree_button: Button = $"../TreeButton"

# Affichage des compétences
@onready var skill_name: Label = $HBoxContainer/SkillInfos/VBoxContainerInfos/PanelContainer/SkillName
@onready var skill_icon: TextureRect = $HBoxContainer/SkillInfos/VBoxContainerInfos/PanelContainer2/VBoxContainer/SkillIcon
@onready var skill_description: Label = $HBoxContainer/SkillInfos/VBoxContainerInfos/PanelContainer2/VBoxContainer/SkillDescription
@onready var unlock_button: Button = $HBoxContainer/SkillInfos/VBoxContainerInfos/UnlockButton
@onready var audio_click: AudioStreamPlayer2D = $HBoxContainer/SkillInfos/VBoxContainerInfos/UnlockButton/AudioClick
# Audio trouvé ici : https://pixabay.com/fr/sound-effects/films-et-effets-sp%C3%A9ciaux-click-level-up-524643/

# Dernier bouton sélectionné, si vide aucun bouton sélectionné
var last_click = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resized.connect(queue_redraw)

	# Connexion des boutons aux signaux mouse entered/exited
	for button in button_origin.button_group.get_buttons():
		buttons_by_id[button.skill.id] = button
		button.mouse_entered.connect(_on_buttons_entered.bind(button))
		button.mouse_exited.connect(_on_buttons_exited)
		button.toggled.connect(_on_skill_button_toggled.bind(button))
		# On redessine les lignes dès qu'un bouton bouge (placement par les conteneurs)
		button.item_rect_changed.connect(queue_redraw)



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

# Trace une ligne entre chaque bouton et les boutons de ses prérequis.
# La ligne devient dorée quand le prérequis est débloqué.
func _draw() -> void:
	for button in buttons_by_id.values():
		for requirement in button.skill.requierment:
			# Prérequis sans bouton dans la scène (ex : IA) : pas de ligne
			if requirement.id not in buttons_by_id:
				continue
			var color = colorLineUnlocked if requirement.id in unlocked else colorLineLocked
			draw_line(buttonCenter(buttons_by_id[requirement.id]), buttonCenter(button), color, lineWidth)

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
	# _draw() colore en doré les lignes qui partent de la compétence débloquée
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
