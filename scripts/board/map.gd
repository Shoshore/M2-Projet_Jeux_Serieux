extends Node2D

class_name Map

#const HEX_SIZE : float = 20.0

var grid_size : int = 10
var visibility_range: int = 1
var recruitment_site_chance: float = 0.03
var biome_noise_frequency: float = 0.12
var tiles_by_coord: Dictionary = {}
var is_board_clickable = true


const NEIGHBORS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]


func _ready() -> void:
	generate_hex_grid(grid_size)


# Génère une grille hexagonale régulière
func generate_hex_grid(radius : int) -> void:
	tiles_by_coord.clear()
	var biome_noise := FastNoiseLite.new()
	biome_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	biome_noise.frequency = biome_noise_frequency
	biome_noise.seed = Random.randi()
	
	for q in range(-radius, radius + 1):
		var r_min : int = max(-radius, -q - radius)
		var r_max : int = min(radius, -q + radius)
		
		for r in range(r_min, r_max + 1):
			var t = Tile.new()
			t.position = coords_to_pixel(q, r)
			t.initialize(q, r)
			t.biome = _get_biome(biome_noise.get_noise_2d(q, r))
			t.is_recruitment_site = Random.randf() < clampf(recruitment_site_chance, 0.01, 0.05)
			add_child(t)
			tiles_by_coord[Vector2i(q, r)] = t
	return



func _get_biome(noise_value: float) -> Tile.Biome:
	if noise_value < -0.35:
		return Tile.Biome.EMPTY
	if noise_value < -0.15:
		return Tile.Biome.PROCESSOR
	if noise_value < 0.25:
		return Tile.Biome.GRASS


# Conversion des coordonnées axiales vers la position à l'écran
func coords_to_pixel(q : int, r : int) -> Vector2:
	var x : float = Global.HEX_SIZE * sqrt(3.0) * (q + r * 0.5)
	var y : float = Global.HEX_SIZE * 1.5 * r
	
	return Vector2(x, y)

func pixel_to_coords(p: Vector2) -> Vector2i:
	var q: float = (sqrt(3.0) / 3.0 * p.x - 1.0 / 3.0 * p.y) / Global.HEX_SIZE
	var r: float = (2.0 / 3.0 * p.y) / Global.HEX_SIZE
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


func refresh() -> void:
	for tile: Tile in tiles_by_coord.values():
		tile.reload_visual()

# ----------------
# getter
# ----------------
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
		if tile.get_building() == null and tile.get_occupant() == null:
			return tile
	return null


func get_occuped_neighbor(coord: Vector2i) -> Array[Tile]:
	var tiles : Array[Tile] = []
	for tile in get_neighbors(coord):
		if tile.get_occupant() != null:
			tiles.append(tile)
	return tiles


func refresh() -> void:
	var vision := Vision_component.new(visibility_range)
	var visible_coordinates: Dictionary[Vector2i, bool] = {}

	for tile: Tile in tiles_by_coord.values():
		if tile.ceo == "Aucun":
			continue
		for coord in vision.get_visible_hexes(tile.coordinate):
			if tiles_by_coord.has(coord):
				visible_coordinates[coord] = true

	for tile: Tile in tiles_by_coord.values():
		tile.is_visible_by_fog = visible_coordinates.has(tile.coordinate)
		tile.reload_visual()
