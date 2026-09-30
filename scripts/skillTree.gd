extends Control
class_name SkillTree

# Compétences technologies
@onready var button_tech_1: Button = $HBoxContainer/VBoxContainer/Button
@onready var button_tech_2: Button = $HBoxContainer/VBoxContainer/Button2
@onready var button_tech_3: Button = $HBoxContainer/VBoxContainer/Button3
@onready var button_tech_4: Button = $HBoxContainer/VBoxContainer/Button4

# Compétences humaines
@onready var button_human_1: Button = $HBoxContainer/VBoxContainer2/Button
@onready var button_human_2: Button = $HBoxContainer/VBoxContainer2/Button2
@onready var button_human_3: Button = $HBoxContainer/VBoxContainer2/Button3
@onready var button_human_4: Button = $HBoxContainer/VBoxContainer2/Button4

# Origine de l'arbre
@onready var button_origin: Button = $ButtonOrigin

# Bouton de changement vers le plateau/arbre
@onready var tree_button: Button = $"../TreeButton"

func buttonCenter(button: Control):
	return button.get_global_rect().get_center() - global_position ;
	
var lineWidth = 3.0

var colorLineOrigin = Color.WHITE
var colorLineTech1 = Color.WHITE
var colorLineTech2 = Color.WHITE
var colorLineTech3 = Color.WHITE
var colorLineHuman1 = Color.WHITE
var colorLineHuman2 = Color.WHITE
var colorLineHuman3 = Color.WHITE

func _draw() -> void:
	draw_line(buttonCenter(button_origin), buttonCenter(button_human_1), colorLineOrigin, lineWidth)
	draw_line(buttonCenter(button_origin), buttonCenter(button_tech_1), colorLineOrigin, lineWidth)
	draw_line(buttonCenter(button_tech_1), buttonCenter(button_tech_2), colorLineTech1, lineWidth)
	draw_line(buttonCenter(button_tech_2), buttonCenter(button_tech_3), colorLineTech2, lineWidth)
	draw_line(buttonCenter(button_tech_3), buttonCenter(button_tech_4), colorLineTech3, lineWidth)
	draw_line(buttonCenter(button_human_1), buttonCenter(button_human_2), colorLineHuman1, lineWidth)
	draw_line(buttonCenter(button_human_2), buttonCenter(button_human_3), colorLineHuman2, lineWidth)
	draw_line(buttonCenter(button_human_3), buttonCenter(button_human_4), colorLineHuman3, lineWidth)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_origin.text = "Début"
	resized.connect(queue_redraw)
	# On redessine les lignes une fois que les boutons sont bien placé
	$HBoxContainer/VBoxContainer.sort_children.connect(queue_redraw)
	$HBoxContainer/VBoxContainer2.sort_children.connect(queue_redraw)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_origin_pressed() -> void:
	button_human_1.disabled = false ;
	button_tech_1.disabled = false ;
	button_origin.disabled = true ;
	colorLineOrigin = Color.GOLDENROD
	queue_redraw()

func _on_button_tech1_pressed() -> void:
	button_tech_2.disabled = false ;
	button_tech_1.disabled = true ;
	colorLineTech1 = Color.GOLDENROD
	queue_redraw()

func _on_button_tech2_pressed() -> void:
	button_tech_3.disabled = false ;
	button_tech_2.disabled = true ;
	colorLineTech2 = Color.GOLDENROD
	queue_redraw()

func _on_button_tech3_pressed() -> void:
	button_tech_4.disabled = false ;
	button_tech_3.disabled = true ;
	colorLineTech3 = Color.GOLDENROD
	queue_redraw()

func _on_button_tech4_pressed() -> void:
	button_tech_4.disabled = true ;


func _on_button_human1_pressed() -> void:
	button_human_2.disabled = false ;
	button_human_1.disabled = true ;
	colorLineHuman1 = Color.GOLDENROD
	queue_redraw()

func _on_button_human2_pressed() -> void:
	button_human_3.disabled = false ;
	button_human_2.disabled = true ;
	colorLineHuman2 = Color.GOLDENROD
	queue_redraw()

func _on_button_human3_pressed() -> void:
	button_human_4.disabled = false ;
	button_human_3.disabled = true ;
	colorLineHuman3 = Color.GOLDENROD
	queue_redraw()

func _on_button_human4_pressed() -> void:
	button_human_4.disabled = true ;



func _on_tree_button_toggled(toggled_on: bool) -> void:
	visible = toggled_on
	if(toggled_on):
		tree_button.text = "Plateau de jeu"
	else:
		tree_button.text = "Arbre de compétences"
