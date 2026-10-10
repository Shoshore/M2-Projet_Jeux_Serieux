extends Node

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
		if event is InputEventMouseButton :
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed :
				emit_signal("FIN DE TOUR")
