class_name Texture_component
extends RefCounted

var _texture: Texture2D = null

func _init(texture: Texture2D) -> void:
	_texture = texture

func get_texture() -> Texture2D:
	return _texture


func set_texture(texture: Texture2D) -> void:
	_texture = texture
