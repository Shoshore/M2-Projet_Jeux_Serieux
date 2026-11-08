extends Control

# Chargement de notre liste de compétence (ressource)
var TREE: SkillTree = load("res://data/skillTree.tres") 

# Signal pour appliquer les compétences
signal unlocked_skill(skill: Skill)
signal reset_info()
# Pour savoir quelles compétences ont été débloquées par le joueur
var unlocked: Array[StringName] = []

# Visuels
var lineWidth = 10.0
var colorLineLocked = Color.WEB_GRAY
var colorLineUnlocked = Color.GOLDENROD
const lock_text = "Débloquer"
const unlock_text = "Acquis"
const failed_text = "Mauvaise réponse, réessayez au prochain tour"
const BLANK_COLOR := "#4a4a4a"    
const PENDING_COLOR := "#646464"  
const BLANK_WIDTH := 8
const BLANK_CHAR := "_"
const NBSP := " "

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
@onready var skill_name: Label = $SkillInfos/VBoxInfos/NamePanel/SkillName
@onready var skill_icon: TextureRect = $SkillInfos/VBoxInfos/DescriptionPanel/VBoxContainer/SkillIcon
@onready var skill_description: RichTextLabel = $SkillInfos/VBoxInfos/DescriptionPanel/VBoxContainer/SkillDescription
@onready var unlock_button: Button = $SkillInfos/VBoxInfos/UnlockButton
@onready var audio_click: AudioStreamPlayer2D = $SkillInfos/VBoxInfos/UnlockButton/AudioClick
# Audio trouvé ici : https://pixabay.com/fr/sound-effects/films-et-effets-sp%C3%A9ciaux-click-level-up-524643/
@onready var v_box_infos: VBoxContainer = $SkillInfos/VBoxInfos
@onready var error_sound: AudioStreamPlayer2D = $SkillInfos/VBoxInfos/UnlockButton/ErrorSound
@onready var name_panel: PanelContainer = $SkillInfos/VBoxInfos/NamePanel
@onready var description_panel: PanelContainer = $SkillInfos/VBoxInfos/DescriptionPanel

# Bouton qui reset la position de l'arbre
@onready var reset_button: Button = $SkillInfos/VBoxInfos/ResetButton

# Pour lire les valeurs de l'entreprise
var company: Company = null

# Dernier bouton sélectionné, si vide aucun bouton sélectionné
var last_click = ""

# Pour les compétences a compléter
var solved: Dictionary[String, Array] = {}        # id -> trous trouvés (ils restent affichés)
var pending: Dictionary[String, Dictionary] = {}  # id -> {trou: réponse choisie}
var locked_this_turn: Array[String] = []
var current_skill: Skill
var current_blank := -1
@onready var answer_menu: PopupMenu = $SkillInfos/VBoxInfos/DescriptionPanel/VBoxContainer/SkillDescription/AnswerMenu


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
	if company._mood_gauge < s.conditions.mood_gauge:
		return false
	return true

func display_conditions(s: Skill) -> String:
	var text := "Condition d'obtention : \n"
	if s.conditions.number_developer > 0:
		text += "Nombre de développeur nécessaire : "
		text += str(s.conditions.number_developer)
		text += "\n"  
	if s.conditions.number_researcher > 0:
		text += "Nombre de chercheur nécessaire : "
		text += str(s.conditions.number_researcher)
		text += "\n"   
	if s.conditions.funds > 0:
		text += "Quantité d'argent nécessaire : "
		text += str(s.conditions.funds)
		text += "€\n"  
	if s.conditions.mood_gauge > 0:
		text += "Quantité d'humeur nécessaire :  "
		text += str(s.conditions.mood_gauge)
		text += "\n"  
	return text


func display_boost(s: Skill) -> String:
	var text := "Gain d'acquisition du noeud :\n"
	for effect in s.effects:
		if effect.variable_name == "_boost_turnover":
			text += "Gain de revenue : "
			text += str(effect.value * 100) + "%"
			text += "\n"
		if effect.variable_name == "_mood_gauge":
			text += "Gain d'humeur : "
			text += str(effect.value)
			text += "\n"
		if effect.variable_name == "vision":
			text += "Gain de portée visuelle : +1"
			text += "\n"
		if effect.variable_name == "_number_recruiter":
			text += "Recrutement d'unité recruteur : +1"
			text += "\n"
		if effect.variable_name == "_list_unities":
			text += "Point de mouvement supplémentaire : +1"
			text += "\n"
		if effect.variable_name == "_debt":
			text += "Employé recrutable dans les université et Forum : +1 "
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

# Vérifie si le bouton "débloquer" est cliquable
func is_unlock_button_active(skill: Skill) -> bool:
	if not can_unlock_skill(skill):      # déjà acquise ou prérequis manquants
		return false
	if not is_conditions_filled(skill):  # pas assez d'argent, d'employés…
		return false
	if skill.id in locked_this_turn:     # mauvaise réponse ce tour-ci
		return false
	if not are_all_blanks_filled(skill): # il reste des trous vides
		return false
	return true

func unlock(s: Skill) -> void:
	if can_unlock_skill(s):
		if is_conditions_filled(s):
			if not check_answers(s):
				locked_this_turn.append(s.id)
				s.color = Color.RED
				display_skill(s)
				_change_skill_infos_color(s)
				error_sound.play()
				return
			unlocked.append(s.id)
			unlocked_skill.emit(s)
			audio_click.play()
			unlock_button.disabled = true
			unlock_button.text = unlock_text
			s.color = Color.WHITE
			display_skill(s)
			_change_skill_infos_color(s)

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
	draw_line(buttonCenter(buttons_by_id["origin"]) - Vector2(0,-10000), buttonCenter(buttons_by_id["origin"]), Color.GOLDENROD, lineWidth)

# Affichage de la compétence dans la fenetre
func display_skill(skill: Skill) -> void:
	current_skill = skill
	skill_name.text = skill.name
	skill_description.text = build_description(skill)
	var text_cond = display_conditions(skill)
	var text_boost = display_boost(skill)
	if text_cond != "Condition d'obtention : \n":
		skill_description.text = text_cond + "\n---------------------------\n" + skill_description.text
	else:
		skill_description.text = "Condition d'obtention : \n Gratuit" + "\n---------------------------\n" + skill_description.text
	if text_boost != "Gain d'acquisition du noeud :\n":
		skill_description.text = text_boost + "\n---------------------------\n" + skill_description.text
	skill_description.scroll_to_line(0)  # revient en haut pour chaque nouvelle compétence
	if skill.id in unlocked and is_conditions_filled(skill):
		unlock_button.text = unlock_text
	else:
		unlock_button.text = lock_text
	if is_unlock_button_active(skill):
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
		_change_skill_infos_color(button.skill)

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


func _on_reset_button_pressed() -> void:
	skill_tree.pivot_offset = skill_tree.size / 2
	skill_tree.scale = Vector2(0.5, 0.5)
	var top_bar := 64.0 # Taille de la barre du HUD
	var free_rect := Rect2(0, top_bar, size.x, size.y - top_bar) # Espace dispo pour le skilltree
	skill_tree.position = free_rect.get_center() - skill_tree.size / 2

# Construit la description a trou
func build_description(s: Skill) -> String:
	var text := s.description
	for i in s.blanks.size():
		var part: String
		if i in solved.get(s.id, []): # Si le joueur a eu bon à l'essai précédent
			part = "[color=green]%s[/color]" % s.blanks[i].correct_answer
		elif pending.get(s.id, {}).has(i):
			var answer: String = pending[s.id][i].replace(" ", NBSP)
			part = "[url=%d][bgcolor=%s]%s[/bgcolor][/url]" % [i, PENDING_COLOR, answer]
		else:
			# Texte de la même couleur que le fond : les "_" sont invisibles mais occupent la place
			part = "[url=%d][bgcolor=%s][color=%s]%s[/color][/bgcolor][/url]" % [i, BLANK_COLOR, BLANK_COLOR, BLANK_CHAR.repeat(BLANK_WIDTH)]
		text = text.replace("{%d}" % i, part)
	return text

func _on_skill_description_meta_clicked(meta) -> void:
	if last_click == "" or current_skill.id in locked_this_turn:
		return
	current_blank = int(meta)
	var blank: SkillBlank = current_skill.blanks[current_blank]
	var choices := [blank.correct_answer] + blank.wrong_answers
	Random.shuffle(choices)
	answer_menu.clear()
	for c in choices:
		answer_menu.add_item(c)
	answer_menu.position = Vector2i(get_global_mouse_position())
	answer_menu.popup()

func _on_answer_menu_index_pressed(index: int) -> void:
	pending.get_or_add(current_skill.id, {})[current_blank] = answer_menu.get_item_text(index)
	display_skill(current_skill)

func check_answers(s: Skill) -> bool:
	var found: Array = solved.get_or_add(s.id, [])
	var answers: Dictionary = pending.get(s.id, {})
	for i in answers:
		if answers[i] == s.blanks[i].correct_answer and i not in found:
			found.append(i)   # les bonnes réponses sont conservées
	pending.erase(s.id)       # les mauvaises réponses sont effacées
	return found.size() == s.blanks.size()

# Pour que le joueur puisse réessayer de remplir les trou au prochain tour (appelé dans turn_manager)
func new_turn() -> void:
	locked_this_turn.clear()
	for s in TREE.skills:
		s.color = Color.WHITE
	_reset_skill_infos_color()

# Vérifie que tous les trous de la compétences sont rempli
func are_all_blanks_filled(skill: Skill) -> bool:
	var nb_found: int = solved.get(skill.id, []).size()
	var nb_chosen: int = pending.get(skill.id, {}).size()
	return nb_found + nb_chosen == skill.blanks.size()

func _change_skill_infos_color(s: Skill) -> void:
	name_panel.self_modulate = s.color
	description_panel.self_modulate = s.color
	unlock_button.modulate = s.color
	reset_button.modulate = s.color

func _reset_skill_infos_color() -> void:
	name_panel.self_modulate = Color.WHITE
	description_panel.self_modulate = Color.WHITE
	unlock_button.modulate = Color.WHITE
	reset_button.modulate = Color.WHITE
