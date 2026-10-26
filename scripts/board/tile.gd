extends Area2D

class_name Tile

#const HEX_SIZE : float = 20.0

var hex_ground := Polygon2D.new()
var hex_company := Polygon2D.new()
var hex_recruiter := Polygon2D.new()
var outline := Line2D.new()

var coordinate : Vector2i = Vector2i.ZERO
var ressource : String = "Rien"
var ceo : String = "Aucun"
var is_recruitment_site: bool = false
var is_visible_by_fog: bool = false
var occupant: Unit = null
var building: Building = null

const FOG_MODULATE := Color(0.16, 0.16, 0.2)

func _ready() -> void:
	var points := hex_vertices(Global.HEX_SIZE)

	for layer: Polygon2D in [hex_ground, hex_company, hex_recruiter]:
		layer.polygon = points
		add_child(layer)

	outline.points = points
	outline.closed = true
	outline.width = 1.0
	outline.default_color = Color(0, 0, 0, 0.15)
	add_child(outline)

	set_texture_hex(hex_ground, Visuals.GRASS)
	set_texture_hex(hex_company, Visuals.COMPANY)
	set_texture_hex(hex_recruiter, Visuals.RECRUITER)
	reload_visual()

static func hex_vertices(radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60.0 * i - 30.0)
		pts.append(Vector2(cos(angle), sin(angle)) * radius)
	return pts


func set_sprite(s: Sprite2D, tex: Texture2D) -> void:
	s.texture = tex
	if tex == null:
		return
	var targeted_length := Global.HEX_SIZE * sqrt(3.0)
	s.scale = Vector2.ONE * (targeted_length / tex.get_width())

func set_texture_hex(p: Polygon2D, tex: Texture2D) -> void:
	if p.texture == tex:
		return
	p.texture = tex
	if tex == null:
		return
	var width := Global.HEX_SIZE * sqrt(3.0)
	var height := Global.HEX_SIZE * 2.0
	var texture_size := Vector2(tex.get_size())
	var uvs := PackedVector2Array()
	for v in p.polygon:
		var normalise := Vector2((v.x + width / 2.0) / width, (v.y + height / 2.0) / height)
		uvs.append(normalise * texture_size)  
	p.uv = uvs
	
func reload_visual() -> void:
	hex_company.visible = building != null
	hex_recruiter.visible = occupant != null

	if building:
		set_texture_hex(hex_company, building.texture)
	elif occupant:
		set_texture_hex(hex_recruiter, occupant.texture)

	var visibility_modulate := Color.WHITE if is_visible_by_fog else FOG_MODULATE
	var ground_modulate := Color(1.0, 0.1, 0.7) if is_recruitment_site else Color.WHITE
	hex_ground.modulate = ground_modulate * visibility_modulate
	hex_company.modulate = visibility_modulate
	hex_recruiter.modulate = visibility_modulate
	outline.modulate = visibility_modulate

func initialize(q : int, r : int, available_ressource : String = "Rien") -> void:
	coordinate = Vector2i(q, r)
	ressource = available_ressource

func get_info() -> Dictionary:
	return {
		"coordinate": coordinate,
		"ressource": ressource,
		"ceo": ceo,
		"is_recruitment_site": is_recruitment_site
	}


func get_info_text() -> String:
	return (
		"Tuile %s\n"
		+ "Ressource : %s\n"
		+ "Propriétaire : %s\n"
		+ "Site de recrutement : %s\n"
	) % [coordinate, ressource, ceo, "Oui" if is_recruitment_site else "Non"]


func display_data() -> void:
	print(get_info_text())
