extends Area2D

class_name Tile


var hexagon := Polygon2D.new()
var outline := Line2D.new()

var texture: Texture_component

var coordinate : Vector2i = Vector2i.ZERO

var _occupant: Unit = null
var _building: Building = null

func _ready() -> void:
	var points := hex_vertices(Global.HEX_SIZE)

	for layer: Polygon2D in [hexagon]:
		layer.polygon = points
		add_child(layer)

	outline.points = points
	outline.closed = true
	outline.width = 1.0
	outline.default_color = Color(0, 0, 0, 0.35)
	add_child(outline)
	texture = Texture_component.new(Visuals.GRASS)
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

	if _building:
		set_texture_hex(hexagon, _building.texture.get_texture())
	elif _occupant:
		set_texture_hex(hexagon, _occupant.texture.get_texture())
	else:
		set_texture_hex(hexagon, texture.get_texture())
	hexagon.modulate = Color.WHITE


func initialize(q : int, r : int) -> void:
	coordinate = Vector2i(q, r)


func get_info() -> Dictionary:
	return {
		"coordinate": coordinate,
	}


func get_info_text() -> String:
	return str(coordinate)


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
