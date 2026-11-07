extends Control

@onready var tutoriel: Control = $Tuto

func _ready() -> void:
	hide()
	tutoriel.hide()
	
func resume():
	get_tree().paused = false
	hide()
	
func pause():
	get_tree().paused = true
	show()
	
func pause_menu():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false :
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused== true:
		resume()
		
		
		
func _on_resume_pressed() -> void:
	resume()

func _on_save_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")	

	
func _process(float):
	pause_menu()

func _on_tuturiel_button_pressed() -> void:
	tutoriel.show()
