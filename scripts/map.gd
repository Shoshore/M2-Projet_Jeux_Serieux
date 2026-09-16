extends Node2D

const TAILLE_HEX : float = 20.0
const COULEUR_REMPLISSAGE := Color(0.15, 0.35, 0.55)
const COULEUR_CONTOUR := Color(0.8, 0.9, 1.0)

var rayon_grille : int = 10
var tableau_hexagonal : Array = []


func _ready() -> void:
	tableau_hexagonal = generer_grille_hexagonale(rayon_grille)
	queue_redraw()


# Génère une grille hexagonale régulière
func generer_grille_hexagonale(rayon : int) -> Array:
	var tuiles : Array = []
	
	for q in range(-rayon, rayon + 1):
		var r_min : int = max(-rayon, -q - rayon)
		var r_max : int = min(rayon, -q + rayon)
		
		for r in range(r_min, r_max + 1):
			tuiles.append(Vector2i(q, r))
	
	return tuiles


# Dessine la grille
func _draw() -> void:
	for coordonnee in tableau_hexagonal:
		var q : int = coordonnee.x
		var r : int = coordonnee.y
		
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
