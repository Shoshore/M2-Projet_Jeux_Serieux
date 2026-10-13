extends Node2D

signal board_click(position: Vector2)
signal camera_zoom(zoom: Vector2)
signal camera_position(position: Vector2)
signal camera_is_pressed(is_pressed: bool)
#func _on_tree_button_toggled(toggled_on: bool) -> void:
	#map.is_board_clickable = !toggled_on

# on peux bouger la cam tous en sélectionnant une tuile


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var is_pressed = event.pressed
			camera_is_pressed.emit(is_pressed)
			if is_pressed:
				var position_souris := get_local_mouse_position()
				board_click.emit(position_souris)

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_zoom.emit(Vector2(0.01, 0.01))

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_zoom.emit(Vector2(-0.01, -0.01))

	if event is InputEventMouseMotion:
		camera_position.emit(event.relative)
		

			


#CREER UN INPUT MANAGER QUAND TOUT MARCHE POUR RENDRE LE CODE PLUS LISIBLE

#GAMELOOP DEVRAIT DETECTER LE CLIC PAS LA MAP 


# Après le menu -> On veut que ça init le jeu
# créer plateau (fait)
# Donne les ressources de bases à l'entreprise (voir compagnie)
# On veut écouter les inputs du joueur :
# -> Spécifier les inputs , les limités  
# Detecter un input pour le menu 
# Detection input changement fenetre world map/skilltree
# Detecter les inputs du skilltree
