class_name Selection_manager
extends RefCounted

signal info_reset(tile: Tile)
var map: Map
var selected_unit: Unit = null
var selected_tile: Tile = null

func _init(p_map: Map) -> void:
	map = p_map


func _get_current_tile(unit: Unit) -> Tile:
	return map.get_tile_at(unit.movement.position.get_position())


func _select_tile(tile: Tile) -> void:
	if selected_tile:
		selected_tile.outline.default_color = Global.outline_default_color
	selected_tile = tile
	selected_tile.outline.default_color = Global.outline_selected_color


func on_tile_clicked(tile: Tile) -> void:
	if selected_tile == tile:
		selected_tile.outline.default_color = Global.outline_default_color
		info_reset.emit(null)
		selected_tile = null
		selected_unit = null
		return
	_select_tile(tile)
	var unit = tile.get_occupant()
	if  unit != null:
		if unit == selected_unit:
			selected_unit = null
		else:
			selected_unit = unit
		return
	
	if selected_unit == null:
		return
	

	var from_tile: Tile = _get_current_tile(selected_unit)
	var target_pos := map.path_check(from_tile.position_.get_position(), tile.position_.get_position())
	var dest_tile: Tile = map.get_tile_at(target_pos)

	if dest_tile == from_tile:
		selected_unit = null
		return


	if selected_unit.movement.can_move_to(target_pos):
		var tiles = map.get_tile_between(from_tile.position_.get_position(), target_pos)
		var size = tiles.size()
		from_tile.set_occupant(null)
		from_tile.reload_visual()
		for i in range(size):
			var current_tile = tiles[i]
			selected_unit.movement.set_position(current_tile.position_.get_position())
			current_tile.set_occupant(selected_unit)
			current_tile.reload_visual()
			map.refresh_sight(current_tile)
			if i > 0:
				var past_tile = tiles[i - 1]
				past_tile.set_occupant(null)
				past_tile.reload_visual()
			await Engine.get_main_loop().create_timer(0.15).timeout
		
		if selected_tile != null:
			selected_tile.outline.default_color = Global.outline_default_color
			selected_tile = null
		info_reset.emit(null)
	selected_unit = null
