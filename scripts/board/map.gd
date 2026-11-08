extends Node2D

class_name Map

var grid_size : int = 10
var recruitment_site_chance: float = 0.03
var biome_noise_frequency: float = 0.12
var tiles_by_coord: Dictionary = {}
var is_board_clickable = true

var universites_info : Array[String] = [
	"Sorbonne Université",
	"Université Paris-Saclay",
	"Université Grenoble Alpes",
	"Université de Bordeaux",
	"Université de Lille",
	"Université de Lorraine",
	"Université de Montpellier",
	"Université de Rennes",
	"Université Claude Bernard Lyon 1",
	"Université de Strasbourg",
	"Université Toulouse III - Paul Sabatier",
	"Université Côte d'Azur",
	"Université de Nantes",
	"Aix-Marseille Université",
	"Université Paris Cité"
]

var forums_entreprises_info : Array[String] = [
	"VivaTech",
	"Forum Network Entreprises de Paris",
	"Forum Horizon Chine",
	"Forum des Entreprises de Centrale Lyon",
	"Forum des Entreprises de l'Ensimag (Grenoble)",
	"Forum des Entreprises de Rennes",
	"Forum Emploi de Télécom Paris",
	"Forum Info de Lille",
	"Forum des Entreprises de l'ENSEEIHT (Toulouse)",
	"Forum des Entreprises de l'INSA Lyon",
	"Forum des Entreprises de Polytech Nice Sophia",
	"Forum des Entreprises de l'EPITA",
	"Forum des Entreprises de CentraleSupélec",
	"Forum des Entreprises d'Epitech",
	"Forum des Entreprises de l'Université de Bordeaux"
]

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

func random_draw(which: int) -> String:
	var name : String
	if which == 0:
		name = universites_info[Random.randi_range(0, universites_info.size() - 1)]
		universites_info.erase(name)
	else:
		name = forums_entreprises_info[Random.randi_range(0, forums_entreprises_info.size() - 1)]
		forums_entreprises_info.erase(name)
	return name

func fill_candidates(candidates: Array[Tile],
	result: Array[Recruitement_building], dist: int) -> Array[Tile]:
	var new_candidates : Array[Tile] = []
	for tile in candidates:
		if !_is_far_enough(tile, result, dist):
			continue
		new_candidates.append(tile)
	return new_candidates

func create_ressources(quantity: int, dist_btw_build: int, ring_range: int) -> Array[Recruitement_building]:
	var _next_site_id = 0
	var result: Array[Recruitement_building] = []
	var target := quantity * 2
	
	var free_tile: Array[Tile] = []
	var ring: Array[Tile] = []
	for tile: Tile in tiles_by_coord.values():
		if tile.get_building() != null or tile.get_occupant() != null:
			continue
		if hex_distance(Vector2i.ZERO, tile.position_.get_position()) == ring_range:
			ring.append(tile)
		elif hex_distance(Vector2i.ZERO, tile.position_.get_position()) >= ring_range + 1:
			free_tile.append(tile)
	Random.shuffle(ring)
	var build_ring = 2
	while build_ring != 0:
		var tile := ring[Random.randi_range(0, ring.size()-1)]
		var build : Recruitement_building
		if tile.get_building() != null:
			continue
		
		if !_is_far_enough(tile, result, dist_btw_build):
			continue

		if result.size() % 2 == 0:
			build = University_site.new(_next_site_id, tile.position_.get_position(), random_draw(0))
		else:
			build = Recruitement_site.new(_next_site_id, tile.position_.get_position(), random_draw(1))
		_next_site_id += 1
		result.append(build)
		tile.set_building(build)
		tile.reload_visual()
		build_ring -= 1
		target -= 1

	var candidates: Array[Tile] = fill_candidates(free_tile, result, dist_btw_build)
	while target != 0 and candidates.size() != 0:
		Random.shuffle(candidates)
		var tile := candidates[Random.randi_range(0, candidates.size() - 1)]
		var build : Recruitement_building
		if result.size() % 2 == 0:
			build = University_site.new(_next_site_id, tile.position_.get_position(), random_draw(0))
		else:
			build = Recruitement_site.new(_next_site_id, tile.position_.get_position(), random_draw(1))
		_next_site_id += 1
		target -= 1
		result.append(build)
		tile.set_building(build)
		tile.reload_visual()
		candidates = fill_candidates(candidates, result, dist_btw_build)
	return result

func hex_distance(a: Vector2i, b: Vector2i) -> int:
	var dq := a.x - b.x
	var dr := a.y - b.y
	return (absi(dq) + absi(dq + dr) + absi(dr)) / 2


func _is_far_enough(tile: Tile, sites: Array[Recruitement_building], min_dist: int) -> bool:
	for s in sites:
		if hex_distance(tile.position_.get_position(), s.position.get_position()) < min_dist:
			return false
	return true
# ------------------
# movement unit
# ------------------

func get_line(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var n := hex_distance(a, b)
	if n == 0:
		result.append(a)
		return result
	for i in range(n + 1):
		var t := float(i) / n
		var q := lerpf(a.x, b.x, t) + 1e-6
		var r := lerpf(a.y, b.y, t) + 1e-6
		result.append(axial_round(Vector2(q, r)))
	return result


func path_check(from: Vector2i, to: Vector2i) -> Vector2i:
	var line := get_line(from, to)
	var last_free := from
	for i in range(1, line.size()):
		var t := get_tile_at(line[i])
		if t == null or t.get_building() != null:
			return last_free
		last_free = line[i]
	return last_free


func get_tile_between(from: Vector2i, to: Vector2i) -> Array[Tile]:
	var line := get_line(from, to)
	var result : Array[Tile] = []
	for i in range(1, line.size()):
		result.append(get_tile_at(line[i]))
	return result
