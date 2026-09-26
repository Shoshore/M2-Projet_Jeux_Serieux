extends Control

@onready var button_tech_1: Button = $HBoxContainer/VBoxContainer/Button
@onready var button_tech_2: Button = $HBoxContainer/VBoxContainer/Button2
@onready var button_tech_3: Button = $HBoxContainer/VBoxContainer/Button3
@onready var button_tech_4: Button = $HBoxContainer/VBoxContainer/Button4
@onready var button_human_1: Button = $HBoxContainer/VBoxContainer2/Button
@onready var button_human_2: Button = $HBoxContainer/VBoxContainer2/Button2
@onready var button_human_3: Button = $HBoxContainer/VBoxContainer2/Button3
@onready var button_human_4: Button = $HBoxContainer/VBoxContainer2/Button4
@onready var button_origin: Button = $ButtonOrigin

@onready var tree_button: Button = $"../TreeButton"

func buttonCenter(button: Control):
	return button.get_global_rect().get_center() - global_position ;
	
var lineWidth = 3.0

var colorOrigin = Color.WHITE
var colorTech1 = Color.WHITE
var colorTech2 = Color.WHITE
var colorTech3 = Color.WHITE
var colorHuman1 = Color.WHITE
var colorHuman2 = Color.WHITE
var colorHuman3 = Color.WHITE

func _draw() -> void:
	draw_line(buttonCenter(button_origin), buttonCenter(button_human_1), colorOrigin, lineWidth)
	draw_line(buttonCenter(button_origin), buttonCenter(button_tech_1), colorOrigin, lineWidth)
	draw_line(buttonCenter(button_tech_1), buttonCenter(button_tech_2), colorTech1, lineWidth)
	draw_line(buttonCenter(button_tech_2), buttonCenter(button_tech_3), colorTech2, lineWidth)
	draw_line(buttonCenter(button_tech_3), buttonCenter(button_tech_4), colorTech3, lineWidth)
	draw_line(buttonCenter(button_human_1), buttonCenter(button_human_2), colorHuman1, lineWidth)
	draw_line(buttonCenter(button_human_2), buttonCenter(button_human_3), colorHuman2, lineWidth)
	draw_line(buttonCenter(button_human_3), buttonCenter(button_human_4), colorHuman3, lineWidth)

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
	colorOrigin = Color.GOLDENROD
	queue_redraw()

func _on_button_tech1_pressed() -> void:
	button_tech_2.disabled = false ;
	button_tech_1.disabled = true ;
	colorTech1 = Color.GOLDENROD
	queue_redraw()

func _on_button_tech2_pressed() -> void:
	button_tech_3.disabled = false ;
	button_tech_2.disabled = true ;
	colorTech2 = Color.GOLDENROD
	queue_redraw()

func _on_button_tech3_pressed() -> void:
	button_tech_4.disabled = false ;
	button_tech_3.disabled = true ;
	colorTech3 = Color.GOLDENROD
	queue_redraw()

func _on_button_tech4_pressed() -> void:
	button_tech_4.disabled = true ;


func _on_button_human1_pressed() -> void:
	button_human_2.disabled = false ;
	button_human_1.disabled = true ;
	colorHuman1 = Color.GOLDENROD
	queue_redraw()

func _on_button_human2_pressed() -> void:
	button_human_3.disabled = false ;
	button_human_2.disabled = true ;
	colorHuman2 = Color.GOLDENROD
	queue_redraw()

func _on_button_human3_pressed() -> void:
	button_human_4.disabled = false ;
	button_human_3.disabled = true ;
	colorHuman3 = Color.GOLDENROD
	queue_redraw()

func _on_button_human4_pressed() -> void:
	button_human_4.disabled = true ;



func _on_tree_button_toggled(toggled_on: bool) -> void:
	visible = toggled_on
	if(toggled_on):
		tree_button.text = "Plateau de jeu"
	else:
		tree_button.text = "Arbre de compétences"
