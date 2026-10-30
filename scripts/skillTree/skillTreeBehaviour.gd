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

# Arbre de compétence complet
@onready var skill_tree: HBoxContainer = $SkillTree
var is_dragging := false
const ZOOM_VALUE := 0.05

# Origine de l'arbre
@onready var button_origin: Button = $SkillTree/VBoxContainer/ORIGIN/ButtonOrigin

# Bouton de changement vers le plateau/arbre
@onready var tree_button: Button = $"../TreeButton"

# Affichage des compétences
@onready var skill_name: Label = $SkillInfos/VBoxContainerInfos/PanelContainer/SkillName
@onready var skill_icon: TextureRect = $SkillInfos/VBoxContainerInfos/PanelContainer2/VBoxContainer/SkillIcon
@onready var skill_description: RichTextLabel = $SkillInfos/VBoxContainerInfos/PanelContainer2/VBoxContainer/SkillDescription
@onready var unlock_button: Button = $SkillInfos/VBoxContainerInfos/UnlockButton
@onready var audio_click: AudioStreamPlayer2D = $SkillInfos/VBoxContainerInfos/UnlockButton/AudioClick
# Audio trouvé ici : https://pixabay.com/fr/sound-effects/films-et-effets-sp%C3%A9ciaux-click-level-up-524643/

var company: Company = null

# Dernier bouton sélectionné, si vide aucun bouton sélectionné
var last_click = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resized.connect(queue_redraw)
	# Pour centrer le zoom
	skill_tree.pivot_offset = skill_tree.size / 2
	# Connexion des boutons aux signaux mouse entered/exited
	for button in button_origin.button_group.get_buttons():
		buttons_by_id[button.skill.id] = button
		button.mouse_entered.connect(_on_buttons_entered.bind(button))
		button.mouse_exited.connect(_on_buttons_exited)
		button.toggled.connect(_on_skill_button_toggled.bind(button))
		# On redessine les lignes dès qu'un bouton bouge (placement par les conteneurs)
		button.item_rect_changed.connect(queue_redraw)
		apply_funds_to_skill(button.skill)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw() # Les liens entre skills sont conservé durant les déplacements

func apply_funds_to_skill(s: Skill) -> void:
	var funds = s.conditions.funds
	if funds < 0 :
		return
	var skillEffect = SkillEffect.new()
	skillEffect.variable_name = "_funds"
	skillEffect.operation = SkillEffect.Operation.ADD
	skillEffect.value = -funds
	s.effects.append(skillEffect)

func is_conditions_filled(s: Skill) -> bool:
	if company._number_developer < s.conditions.number_developer:
		return false 
	if company._number_researcher < s.conditions.number_researcher:
		return false
	if company._number_recruiter < s.conditions.number_recruiter:
		return false
	if company._funds < s.conditions.funds:
		return false
	if company._boost_turnover < s.conditions.boost_turnover:
		return false
	if company._mood_gauge < s.conditions.mood_gauge:
		return false
	if company._boost_mood < s.conditions.boost_mood:
		return false
	return true

func display_conditions(s: Skill) -> String:
	var text := ""
	if s.conditions.number_developer > 0:
		text += "Number Developer > "
		text += str(s.conditions.number_developer)
		text += "\n"  
	if s.conditions.number_researcher > 0:
		text += "Number Researcher > "
		text += str(s.conditions.number_researcher)
		text += "\n"  
	if s.conditions.number_recruiter > 0:
		text += "Number Recruiter > "
		text += str(s.conditions.number_recruiter)
		text += "\n"  
	if s.conditions.funds > 0:
		text += "Funds > "
		text += str(s.conditions.funds)
		text += "\n"  
	if s.conditions.boost_turnover > 0:
		text += "Boost Turnover > "
		text += str(s.conditions.boost_turnover)
		text += "\n"  
	if s.conditions.mood_gauge > 0:
		text += "Mood gauge > "
		text += str(s.conditions.mood_gauge)
		text += "\n"  
	if s.conditions.boost_mood > 0:
		text += "Boost mood > "
		text += str(s.conditions.boost_mood)
		text += "\n"  
	return text

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
		if is_conditions_filled(s):
			unlocked.append(s.id)
			unlocked_skill.emit(s)
			audio_click.play()
			unlock_button.disabled = true
			unlock_button.text = unlock_text

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
	skill_description.text = display_conditions(skill) + "--------------------\n" + skill.description
	skill_description.scroll_to_line(0)  # revient en haut pour chaque nouvelle compétence
	if skill.id in unlocked and is_conditions_filled(skill):
		unlock_button.text = unlock_text
	else:
		unlock_button.text = lock_text
	if can_unlock_skill(skill) and is_conditions_filled(skill):
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
	# Gestion du zoom et déplacement de l'arbre
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed # Mode déplacement
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if skill_tree.scale < Vector2(2,2):
				skill_tree.scale += Vector2(ZOOM_VALUE,ZOOM_VALUE)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if skill_tree.scale > Vector2(0.4,0.4):
				skill_tree.scale -= Vector2(ZOOM_VALUE,ZOOM_VALUE)
	elif event is InputEventMouseMotion and is_dragging:
		skill_tree.position += event.relative
	
	# Gestion du clic hors compétences
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Relache le dernier bouton enfoncé
		var pressed_button := button_origin.button_group.get_pressed_button()
		if pressed_button :
			pressed_button.button_pressed = false
		# Désaffiche la compétence
		last_click = ""
		undisplay_skill()
		company.display()
