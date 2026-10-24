extends Control

func _ready() -> void:
	display_results()

func display_results() -> void:
	var status = Global.game_result.get_status()
	var turn = Global.game_result.get_turn()
	var score = Global.game_result.get_score()

	if status == "Victoire":
		$PanelContainer/VBoxContainer/Status.text = "Bravo! Vous avez gagné!"
	elif status == "Défaite":
		$PanelContainer/VBoxContainer/Status.text = "Dommage... Vous avez perdu..."

	$PanelContainer/VBoxContainer/Turn.text = "Vous avez survécu " + str(turn) + " tours"
	$PanelContainer/VBoxContainer/Score.text = "Vous avez amassé " + str(score) + " euros"


func _on_back_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
