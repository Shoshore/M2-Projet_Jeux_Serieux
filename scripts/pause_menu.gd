extends Control

@onready var tmp = $CanvasLayer2/PauseMenu

func resume():
	get_tree().paused = false
	
func pause():
	get_tree().paused = true
	
func pause_menu():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false :
		pause()
		print("On est en pause ")
	elif Input.is_action_just_pressed("esc") and get_tree().paused== true:
		resume()
		print("On est plus en pause ")
		
		
func _process(float):
	pause_menu()
