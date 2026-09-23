extends Node2D

class_name Tile

const TAILLE_HEX : float = 20.0
const COULEUR_REMPLISSAGE := Color(0.15, 0.35, 0.55)
const COULEUR_CONTOUR := Color(0.8, 0.9, 1.0)

var coordonnee : Vector2i = Vector2i.ZERO
var ressource : String = "Rien"
var proprietaire : String = "Aucun"

func _ready() -> void:
	queue_redraw()


func initialiser(q : int, r : int, ressource_disponible : String = "Rien") -> void:
	coordonnee = Vector2i(q, r)
	ressource = ressource_disponible
	queue_redraw()


func _draw() -> void:
	var points : PackedVector2Array = PackedVector2Array()
	for i in range(6):
		var angle : float = deg_to_rad(60.0 * i - 30.0)
		var point : Vector2 = Vector2(
			cos(angle),
			sin(angle)
		) * TAILLE_HEX
		points.append(point)

	draw_colored_polygon(points, COULEUR_REMPLISSAGE)

	for i in range(6):
		var suivant : int = (i + 1) % 6
		draw_line(points[i], points[suivant], COULEUR_CONTOUR, 2.0)


func contient_point(point_local : Vector2) -> bool:
	return point_local.length() <= TAILLE_HEX

func get_info() -> Dictionary:
	return {
		"coordonnee": coordonnee,
		"ressource": ressource,
		"proprietaire": proprietaire
	}


func get_info_text() -> String:
	return (
		"Tuile %s\n"
		+ "Ressource : %s\n"
		+ "Propriétaire : %s\n"
	) % [coordonnee, ressource, proprietaire]


func afficher_infos() -> void:
	print(get_info_text())
