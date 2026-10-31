extends Node2D

var isPressed := false 

func _on_input_manager_camera_position(position: Vector2) -> void:
	if isPressed:
		global_position -= position


func _on_input_manager_camera_is_pressed(is_pressed: bool) -> void:
	isPressed = is_pressed


func _on_input_manager_camera_zoom(zoom: Vector2) -> void:
	$camera.zoom += zoom
