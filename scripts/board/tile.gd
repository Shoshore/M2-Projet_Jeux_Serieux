extends Area2D

class_name Tile


var hexagon := Polygon2D.new()
var outline := Line2D.new()

var texture: Texture_component

var position_ : Position_component

var _occupant: Unit = null
var _building: Building = null
var hex_ground := Polygon2D.new()
var hex_company := Polygon2D.new()
var hex_recruiter := Polygon2D.new()
var hex_recruitment := Polygon2D.new()
var hex_university := Polygon2D.new()
var outline := Line2D.new()

enum Biome {
	GRASS,
	EMPTY,
	RED_SAND,
}

var biome: Biome = Biome.GRASS
var is_recruitment_site: bool = false
var is_visible_by_fog: bool = false

const FOG_COLOR := Color(0.16, 0.16, 0.2)

func _ready() -> void:
	var points := hex_vertices(Global.HEX_SIZE)

	for layer: Polygon2D in [hex_ground, hex_company, hex_recruiter, hex_recruitment_site]:
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
	set_texture_hex(hex_recruitment, Visuals.RECRUITEMENT)
	set_texture_hex(hex_university, Visuals.UNIVERSITY)
	reload_visual()

static func hex_vertices(radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60.0 * i - 30.0)
		pts.append(Vector2(cos(angle), sin(angle)) * radius)
	return pts


func set_sprite(sprite: Sprite2D, texture: Texture2D) -> void:
	sprite.texture = texture
	if texture == null:
		return
	var targeted_length := Global.HEX_SIZE * sqrt(3.0)
	sprite.scale = Vector2.ONE * (targeted_length / texture.get_width())


func set_texture_hex(polygon: Polygon2D, tex: Texture2D) -> void:
	if polygon.texture == tex:
		return
	polygon.texture = tex
	if tex == null:
		return
	var width := Global.HEX_SIZE * sqrt(3.0)
	var height := Global.HEX_SIZE * 2.0
	var texture_size := Vector2(tex.get_size())
	var uvs := PackedVector2Array()
	for v in polygon.polygon:
		var normalise := Vector2((v.x + width / 2.0) / width, (v.y + height / 2.0) / height)
		uvs.append(normalise * texture_size)  
	polygon.uv = uvs
	
func reload_visual() -> void:
	hex_ground.visible = true
	hex_company.visible = building != null
	hex_recruiter.visible = occupant != null
	hex_recruitment_site.visible = is_recruitment_site
	match biome:
		Biome.GRASS:
			set_texture_hex(hex_ground, Visuals.GRASS)
		Biome.EMPTY:
			set_texture_hex(hex_ground, Visuals.EMPTY)
		Biome.PROCESSOR:
			set_texture_hex(hex_ground, Visuals.PROCESSOR)


	if _building:
		set_texture_hex(hexagon, _building.texture.get_texture())
	elif _occupant:
		set_texture_hex(hexagon, _occupant.texture.get_texture())
	else:
		set_texture_hex(hexagon, texture.get_texture())
	hexagon.modulate = Color.WHITE

	var visibility_modulate := Color.WHITE if is_visible_by_fog else FOG_MODULATE
	hex_ground.modulate = visibility_modulate
	hex_company.modulate = visibility_modulate
	hex_recruiter.modulate = visibility_modulate
	hex_recruitment_site.modulate = visibility_modulate
	outline.modulate = visibility_modulate

func initialize(q : int, r : int) -> void:
	position_ = Position_component.new(Vector2i(q, r))


func get_info() -> Dictionary:
	return {
		"position : ": position_.get_position(),
		"biome": Biome.keys()[biome],
	}


func get_info_text() -> String:
	return (
		"Tuile %s\n"
		+ "Biome : %s\n"
	) % [coordinate, Biome.keys()[biome]]

func display_data() -> void:
	print(get_info_text())

# -----------
# getter
# ------------
func get_building() -> Building:
	return _building


func get_occupant() -> Unit:
	return _occupant


# -----------
# setter
# ------------
func set_building(build: Building) -> void:
	_building = build


func set_occupant(unit: Unit) -> void:
	_occupant = unit
