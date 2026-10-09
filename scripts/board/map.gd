extends Node2D

class_name Map

const TAILLE_HEX : float = 20.0

var rayon_grille : int = 10
var tiles_by_coord: Dictionary = {}


const DIRECTIONS_HEX: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]


func _ready() -> void:
	generer_grille_hexagonale(rayon_grille)


# Génère une grille hexagonale régulière
func generer_grille_hexagonale(rayon : int) -> void:
	tiles_by_coord.clear()
	
	for q in range(-rayon, rayon + 1):
		var r_min : int = max(-rayon, -q - rayon)
		var r_max : int = min(rayon, -q + rayon)
		
		for r in range(r_min, r_max + 1):
			var t = Tile.new()
			t.position = coordonnees_vers_pixel(q, r)
			t.initialiser(q, r)
			add_child(t)
			tiles_by_coord[Vector2i(q, r)] = t
	return




# Conversion des coordonnées axiales vers la position à l'écran
func coordonnees_vers_pixel(q : int, r : int) -> Vector2:
	var x : float = TAILLE_HEX * sqrt(3.0) * (q + r * 0.5)
	var y : float = TAILLE_HEX * 1.5 * r
	
	return Vector2(x, y)

func pixel_vers_coordonnees(p: Vector2) -> Vector2i:
	var q: float = (sqrt(3.0) / 3.0 * p.x - 1.0 / 3.0 * p.y) / TAILLE_HEX
	var r: float = (2.0 / 3.0 * p.y) / TAILLE_HEX
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
	for dir in DIRECTIONS_HEX:
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
