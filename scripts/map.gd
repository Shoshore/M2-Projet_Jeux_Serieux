extends Node2D

class_name Map

@onready var info_label: Label = get_node("CanvasLayer/info/Label")
const TAILLE_HEX : float = 20.0
const COULEUR_REMPLISSAGE := Color(0.15, 0.35, 0.55)
const COULEUR_CONTOUR := Color(0.8, 0.9, 1.0)

var rayon_grille : int = 10
var tableau_hexagonal : Array[Tile] = []

func on_tile_clicked(tile: Tile) -> void:
	info_label.text = tile.get_info_text()

func _ready() -> void:
	tableau_hexagonal = generer_grille_hexagonale(rayon_grille)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var position_souris := get_local_mouse_position()
			detecter_clic(position_souris)



func detecter_clic(position_locale: Vector2) -> void:
	for tile in tableau_hexagonal:
		var centre := coordonnees_vers_pixel(
			tile.coordonnee.x,
			tile.coordonnee.y
		)

		var position_dans_tile := position_locale - centre

		if position_dans_tile.length() <= TAILLE_HEX:
			on_tile_clicked(tile)
			return


# Génère une grille hexagonale régulière
func generer_grille_hexagonale(rayon : int) -> Array:
	var tuiles : Array[Tile] = []
	
	for q in range(-rayon, rayon + 1):
		var r_min : int = max(-rayon, -q - rayon)
		var r_max : int = min(rayon, -q + rayon)
		
		for r in range(r_min, r_max + 1):
			var t = Tile.new()
			t.initialiser(q, r)
			add_child(t)
			tuiles.append(t)
	return tuiles


# Dessine la grille
func _draw() -> void:
	for tile in tableau_hexagonal:
		var coord = tile.coordonnee
		var q : int = coord.x
		var r : int = coord.y
		
		var position_hex : Vector2 = coordonnees_vers_pixel(q, r)
		dessiner_hexagone(position_hex)

# Conversion des coordonnées axiales vers la position à l'écran
func coordonnees_vers_pixel(q : int, r : int) -> Vector2:
	var x : float = TAILLE_HEX * sqrt(3.0) * (q + r * 0.5)
	var y : float = TAILLE_HEX * 1.5 * r
	
	return Vector2(x, y)


# Dessine un hexagone centré sur une position
func dessiner_hexagone(centre : Vector2) -> void:
	var points : PackedVector2Array = PackedVector2Array()
	
	for i in range(6):
		var angle : float = deg_to_rad(60.0 * i - 30.0)
		var point : Vector2 = centre + Vector2(
			cos(angle),
			sin(angle)
		) * TAILLE_HEX
		
		points.append(point)
	
	# Remplissage
	draw_colored_polygon(points, COULEUR_REMPLISSAGE)
	
	# Contour
	for i in range(6):
		var suivant : int = (i + 1) % 6
		draw_line(
			points[i],
			points[suivant],
			COULEUR_CONTOUR,
			2.0
		)
