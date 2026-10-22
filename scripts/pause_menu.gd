extends Control


func _ready() -> void:
	hide()

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
	pass # Replace with function body.
	
	
func _process(float):
	pause_menu()
