extends Node2D

class_name Map

const HEX_SIZE : float = 20.0

var grid_size : int = 10
var tiles_by_coord: Dictionary = {}


const NEIGHBORS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]


func _ready() -> void:
	generate_hex_grid(grid_size)


# Génère une grille hexagonale régulière
func generate_hex_grid(radius : int) -> void:
	tiles_by_coord.clear()
	
	for q in range(-radius, radius + 1):
		var r_min : int = max(-radius, -q - radius)
		var r_max : int = min(radius, -q + radius)
		
		for r in range(r_min, r_max + 1):
			var t = Tile.new()
			t.position = coords_to_pixel(q, r)
			t.initialize(q, r)
			add_child(t)
			tiles_by_coord[Vector2i(q, r)] = t
	return




# Conversion des coordonnées axiales vers la position à l'écran
func coords_to_pixel(q : int, r : int) -> Vector2:
	var x : float = HEX_SIZE * sqrt(3.0) * (q + r * 0.5)
	var y : float = HEX_SIZE * 1.5 * r
	
	return Vector2(x, y)

func pixel_to_coords(p: Vector2) -> Vector2i:
	var q: float = (sqrt(3.0) / 3.0 * p.x - 1.0 / 3.0 * p.y) / HEX_SIZE
	var r: float = (2.0 / 3.0 * p.y) / HEX_SIZE
	return axial_round(Vector2(q, r))


func axial_round(frac: Vector2) -> Vector2i:
	var x := frac.x
	var z := frac.y
	var y := -x - z
	var rx := roundf(x)
	var ry := roundf(y)
	var rz := roundf(z)
	var dx := absf(rx - x)
	var dy := absf(ry - y)
	var dz := absf(rz - z)
	if dx > dy and dx > dz:
		rx = -ry - rz
	elif dy > dz:
		ry = -rx - rz
	else:
		rz = -rx - ry
	return Vector2i(int(rx), int(rz))





func get_tile_at(coord: Vector2i) -> Tile:
	return tiles_by_coord.get(coord)


func get_neighbors(coord: Vector2i) -> Array[Tile]:
	var result: Array[Tile] = []
	for dir in NEIGHBORS:
		var tile := get_tile_at(coord + dir)
		if tile != null:
			result.append(tile)
	return result


func get_free_neighbor(coord: Vector2i) -> Tile:
	for tile in get_neighbors(coord):
		if tile.building == null and tile.occupant == null:
			return tile
	return null


func refresh() -> void:
	for tile: Tile in tiles_by_coord.values():
		tile.reload_visual()
