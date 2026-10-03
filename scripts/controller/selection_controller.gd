class_name Selection_controller
extends RefCounted

var map: Map
var selected_unit: Unit = null

func _init(p_map: Map) -> void:
	map = p_map


func _get_current_tile(unit: Unit) -> Tile:
	return map.get_tile_at(unit.movement.position.position)



func on_tile_clicked(tile: Tile) -> void:
	if tile.occupant != null:
		selected_unit = tile.occupant
		return
	
	if selected_unit == null:
		return
	
	if tile.building != null:
		return
	
	var from_tile: Tile = _get_current_tile(selected_unit)
	if selected_unit.movement.move_to(tile.coordonnee):
		if from_tile != null:
			from_tile.occupant = null
		tile.occupant = selected_unit
	selected_unit = null
	map.refresh()
