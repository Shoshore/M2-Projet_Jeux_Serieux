extends Node2D

class_name Tile

const TAILLE_HEX : float = 20.0

var hex_ground := Polygon2D.new()
var hex_compagny := Polygon2D.new()
var hex_recruiter := Polygon2D.new()
var contour := Line2D.new()

var coordonnee : Vector2i = Vector2i.ZERO
var ressource : String = "Rien"
var proprietaire : String = "Aucun"
var occupant: Unit = null
var building: Building = null

func _ready() -> void:
	var points := points_hexagone(TAILLE_HEX)

	for layer: Polygon2D in [hex_ground, hex_compagny, hex_recruiter]:
		layer.polygon = points
		add_child(layer)

	contour.points = points
	contour.closed = true
	contour.width = 1.0
	contour.default_color = Color(0, 0, 0, 0.35)
	add_child(contour)

	set_texture_hex(hex_ground, Visuels.GRASS)
	set_texture_hex(hex_compagny, Visuels.COMPAGNY)
	set_texture_hex(hex_recruiter, Visuels.RECRUITER)
	reload_visual()

static func points_hexagone(rayon: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60.0 * i - 30.0)
		pts.append(Vector2(cos(angle), sin(angle)) * rayon)
	return pts


func set_sprite(s: Sprite2D, tex: Texture2D) -> void:
	s.texture = tex
	if tex == null:
		return
	var largeur_cible := Map.TAILLE_HEX * sqrt(3.0)
	s.scale = Vector2.ONE * (largeur_cible / tex.get_width())

func set_texture_hex(p: Polygon2D, tex: Texture2D) -> void:
	if p.texture == tex:
		return
	p.texture = tex
	if tex == null:
		return
	var largeur := TAILLE_HEX * sqrt(3.0)
	var hauteur := TAILLE_HEX * 2.0
	var taille_tex := Vector2(tex.get_size())
	var uvs := PackedVector2Array()
	for v in p.polygon:
		var normalise := Vector2((v.x + largeur / 2.0) / largeur, (v.y + hauteur / 2.0) / hauteur)
		uvs.append(normalise * taille_tex)  # les UV sont en pixels de texture
	p.uv = uvs
	
func reload_visual() -> void:
	hex_compagny.visible = building != null
	hex_recruiter.visible = occupant != null

	if building:
		set_texture_hex(hex_compagny, building.texture)
	elif occupant:
		set_texture_hex(hex_recruiter, occupant.texture)

	hex_ground.modulate = Color.WHITE
	hex_compagny.modulate = Color.WHITE
	hex_recruiter.modulate = Color.WHITE

func initialiser(q : int, r : int, ressource_disponible : String = "Rien") -> void:
	coordonnee = Vector2i(q, r)
	ressource = ressource_disponible

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
