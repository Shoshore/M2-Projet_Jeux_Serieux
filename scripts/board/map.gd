extends Node2D

class_name Map

var grid_size : int = 10
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
			add_child(t)
			tiles_by_coord[Vector2i(q, r)] = t
	return


func _get_biome(noise_value: float) -> Tile.Biome:
	if noise_value < -0.15:
		return Tile.Biome.PROCESSOR
	if noise_value < 0.25:
		return Tile.Biome.GRASS
	return Tile.Biome.EMPTY


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


func refresh_sight(tile: Tile) -> void:
	var entity = null
	var build = tile.get_building()
	if build is Company:
		entity = build
	elif tile.get_occupant() != null:
		entity = tile.get_occupant()
	else:
		return

	for coord in entity.vision.get_visible_hexes(tile.position_.get_position()):
		var t := get_tile_at(coord)
		if t == null or t.is_visible_by_fog:
			continue
		t.is_visible_by_fog = true
		t.reload_visual()

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


# ------------------------------
# filling map
# ---------------------------
func create_company(position: Vector2i, id: int) -> Company:
	var tile: Tile = tiles_by_coord[position]
	var current_compagny = Company.new(id, position)
	current_compagny.create_unit(get_free_neighbor(current_compagny.position.get_position()), Company.Create_unit_type.RECRUITER)
	tile.set_building(current_compagny)
	tile.reload_visual()
	refresh_sight(tile)
	return current_compagny

func create_ressources(quantity: int, start_distance: int) -> Array[Recruitement_building]:
	var _next_site_id = 0
	var result: Array[Recruitement_building] = []
	var target := quantity * 2

	var candidates: Array[Tile] = []
	for tile: Tile in tiles_by_coord.values():
		if tile.get_building() == null and tile.get_occupant() == null:
			candidates.append(tile)
	candidates.shuffle()

	var min_dist := start_distance
	while result.size() < target and min_dist >= 1:
		for tile in candidates:
			if result.size() >= target:
				break
			if tile.get_building() != null:
				continue

			var pos := tile.position_.get_position()
			if not _is_far_enough(pos, result, min_dist):
				continue

			var site: Building
			if result.size() % 2 == 0:
				site = University_site.new(_next_site_id, pos)
			else:
				site = Recruitement_site.new(_next_site_id, pos)
			_next_site_id += 1

			tile.set_building(site)
			result.append(site)
		min_dist -= 1

	return result


func _is_far_enough(pos: Vector2i, sites: Array[Recruitement_building], min_dist: int) -> bool:
	for s in sites:
		if hex_distance(pos, s.position.get_position()) < min_dist:
			return false
	return true


func hex_distance(a: Vector2i, b: Vector2i) -> int:
	var dq := a.x - b.x
	var dr := a.y - b.y
	return (absi(dq) + absi(dq + dr) + absi(dr)) / 2
