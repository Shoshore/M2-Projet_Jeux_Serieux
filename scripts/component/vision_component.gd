class_name Vision_component
extends RefCounted

var sight_range: int

func _init(p_sight_range: int = 1) -> void:
	sight_range = p_sight_range

func get_visible_hexes(center: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for hexagon in range(-sight_range, sight_range + 1):
		var a_min: int = maxi(-sight_range, -hexagon - sight_range)
		var a_max: int = mini(sight_range, -hexagon + sight_range)
		for a in range(a_min, a_max + 1):
			result.append(center + Vector2i(hexagon, a))
	return result
