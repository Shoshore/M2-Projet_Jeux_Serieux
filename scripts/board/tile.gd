extends Area2D

class_name Tile

const HEX_SIZE : float = 20.0

var hex_ground := Polygon2D.new()
var hex_company := Polygon2D.new()
var hex_recruiter := Polygon2D.new()
var outline := Line2D.new()

var coordinate : Vector2i = Vector2i.ZERO
var ressource : String = "Rien"
var ceo : String = "Aucun"
var occupant: Unit = null
var building: Building = null

func _ready() -> void:
	var points := hex_vertices(HEX_SIZE)

	for layer: Polygon2D in [hex_ground, hex_company, hex_recruiter]:
		layer.polygon = points
		add_child(layer)

	outline.points = points
	outline.closed = true
	outline.width = 1.0
	outline.default_color = Color(0, 0, 0, 0.35)
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
	var targeted_length := Map.HEX_SIZE * sqrt(3.0)
	s.scale = Vector2.ONE * (targeted_length / tex.get_width())

func set_texture_hex(p: Polygon2D, tex: Texture2D) -> void:
	if p.texture == tex:
		return
	p.texture = tex
	if tex == null:
		return
	var width := HEX_SIZE * sqrt(3.0)
	var height := HEX_SIZE * 2.0
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

	hex_ground.modulate = Color.WHITE
	hex_company.modulate = Color.WHITE
	hex_recruiter.modulate = Color.WHITE

func initialize(q : int, r : int, available_ressource : String = "Rien") -> void:
	coordinate = Vector2i(q, r)
	ressource = available_ressource

func get_info() -> Dictionary:
	return {
		"coordinate": coordinate,
		"ressource": ressource,
		"ceo": ceo
	}


func get_info_text() -> String:
	return (
		"Tuile %s\n"
		+ "Ressource : %s\n"
		+ "Propriétaire : %s\n"
	) % [coordinate, ressource, ceo]


func display_data() -> void:
	print(get_info_text())
