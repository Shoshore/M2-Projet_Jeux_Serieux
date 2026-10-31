extends Area2D

class_name Tile


var hexagon := Polygon2D.new()
var outline := Line2D.new()

var _texture : Texture_component

var position_ : Position_component

var _occupant: Unit = null
var _building: Building = null
var hex_ground := Polygon2D.new()
var hex_company := Polygon2D.new()
var hex_recruiter := Polygon2D.new()
var hex_recruitment := Polygon2D.new()
var hex_university := Polygon2D.new()

enum Biome {
	GRASS,
	EMPTY,
	PROCESSOR,
}

var biome: Biome = Biome.GRASS
var is_recruitment_site: bool = false
var is_visible_by_fog: bool = false

const FOG_COLOR := Color(0.16, 0.16, 0.2)

func _ready() -> void:
	var points := hex_vertices(Global.HEX_SIZE)

	for layer: Polygon2D in [hex_ground, hex_company, hex_recruiter, hex_recruitment, hex_university]:
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
	_texture = Texture_component.new(Visuals.EMPTY)
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
	hex_company.visible = _building != null
	hex_recruiter.visible = _occupant != null
	hex_recruitment.visible = _building is Recruitement_building
	hex_university.visible = _building is University_site
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
		set_texture_hex(hexagon, _texture.get_texture())
	hexagon.modulate = Color.WHITE

	var visibility_modulate := Color.WHITE if is_visible_by_fog else FOG_COLOR
	hex_ground.modulate = visibility_modulate
	hex_company.modulate = visibility_modulate
	hex_recruiter.modulate = visibility_modulate
	hex_recruitment.modulate = visibility_modulate
	hex_university.modulate = visibility_modulate
	outline.modulate = visibility_modulate

func initialize(q : int, r : int) -> void:
	position_ = Position_component.new(Vector2i(q, r))

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


#------------------------------
# display information in game
#------------------------------
func company_info(turn: int, not_all : bool = true) -> String:
	var text := ""
	if not_all:
		text = "Argent : " + str(_building._funds) + "\n"
		text += "Boost de revenu : " + str(_building._boost_turnover) + "%\n"
	text += "Humeur : " + str(_building._mood_gauge) + "/" + str(_building._mood_threshold) + "\n"
	var nb_employee = _building._number_developer + _building._number_researcher + _building._number_recruiter
	if not_all:
		text += "Nombre d'employer : " + str(nb_employee) + "\n"
		text += "Nombre de developpers : " + str(_building._number_developer) + "\n"
	text += "Nombre de chercheurs : " + str(_building._number_researcher) + "\n"
	text += "Nombre de recruteurs : " + str(_building._number_recruiter) + "\n"
	text += "Paye des salarier : " + str(_building._salary_pay * (1 + 0.3 * floor(turn / 3))) + "\n" 
	if not_all:
		text += "Profit par salarier : " + str(_building._profit * _building._boost_turnover) + "\n" 
	text += "Portée visuelle : " + str(_building.vision.sight_range) + "\n"
	return text


func get_info_text(company: Company, turn: int) -> String:
	var text := ""
	if _occupant:
		if _occupant.get_company_id() == 0:
			text += "Votre unité 'Recruiter' :\n"
		else:
			text += "Unité Recruiter adverse :\n"
		text +=  "Points de mouvements : " +str(_occupant.movement._current_movement) + "/"
		text += str(_occupant.movement._max_movement) + "\n"
		text += "Portée de visuelle : " + str(_occupant.vision.sight_range)
	elif _building:
		if _building is Company:
			if _building.id.get_id() == 0:
				text += "Votre entreprise :\n"
				text += company_info(turn)
			else:
				text += "Entreprise adverse :\n"
				if company._cyber_attack:
					text += company_info(turn)
				elif _building._cyber_security:
					text += company_info(turn, false)
					text += "L'entreprise adverse commence à développé sa cybersécurité \n"
					text += "vous ne pouvez pas espionné toutes ses informations"
				elif _building._cyber_defense:
					text += "L'entreprise adverse à une cyber defense trop élevé \n"
					text += "pensé à améliorer votre cyber attaque !"
		elif _building is Recruitement_site:
			if _building is University_site:
				text += "Université :\n"
			else:
				text += "Site de recrutement :\n"
			var ressource := ""
			if _building._ressource == Recruitement_building.Ressources.DEVELOPPER:
				ressource = "développer"
			else:
				ressource = "chercheur"
			text += "Employé recrutable : " + ressource + "\n"
			text += "Durée de marchage avant embauche : " + str(_building._turn_get_unit) + " tours"
	else:
		text = "L'hexagone est vide"
	return text
