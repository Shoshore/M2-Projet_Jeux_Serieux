class_name Selection_manager
extends RefCounted

var map: Map
var selected_unit: Unit = null

func _init(p_map: Map) -> void:
	map = p_map


func _get_current_tile(unit: Unit) -> Tile:
	return map.get_tile_at(unit.movement.position.get_position())


func on_tile_clicked(tile: Tile) -> void:
	var unit = tile.get_occupant()
	if  unit != null:
		if unit == selected_unit:
			selected_unit = null
		else:
			selected_unit = unit
		return
	
	if selected_unit == null:
		return
	
	if tile.get_building() != null:
		return
	
	var from_tile: Tile = _get_current_tile(selected_unit)
	var target_pos := tile.position_.get_position()
	
	if from_tile != null and map.is_path_blocked(from_tile.position_.get_position(), target_pos):
		selected_unit = null
		return
	
	if selected_unit.movement.move_to(target_pos):
		if from_tile != null:
			from_tile.set_occupant(null)
			from_tile.reload_visual() 
		tile.set_occupant(selected_unit)
		tile.reload_visual()
		map.refresh_sight(tile)
	selected_unit = null
