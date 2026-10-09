extends Node2D

var map := Map.new()
var selection := Selection_controller.new(map)
@onready var label_info: Label = get_node("CanvasLayer/info/Label")

var game_length := 30

func _ready() -> void:
	add_child(map)
	_map_filling(map)


func _on_tile_clicked(tile: Tile) -> void:
	label_info.text = tile.get_info_text()
	var build = tile.building
	if build:
		build.display()


func _on_tree_button_toggled(toggled_on: bool) -> void:
	map.is_board_clickable = !toggled_on

func _map_filling(map: Map) -> void:
	var origin := Vector2i(0, 0)
	var tile: Tile = map.tiles_by_coord[origin]
	tile.building = Compagny.new(0, origin, map) #modifier constructeur si nécessaire
	tile.reload_visual()


func detecter_clic(position_locale: Vector2) -> void:
	var coord := map.pixel_vers_coordonnees(position_locale)
	var tile := map.get_tile_at(coord)
	if tile != null:
		_on_tile_clicked(tile)
		selection.on_tile_clicked(tile)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var position_souris := get_local_mouse_position()
			detecter_clic(position_souris)


#CREER UN INPUT MANAGER QUAND TOUT MARCHE POUR RENDRE LE CODE PLUS LISIBLE

#GAMELOOP DEVRAIT DETECTER LE CLIC PAS LA MAP 


# Après le menu -> On veut que ça init le jeu
# créer plateau (fait)
# Donne les ressources de bases à l'entreprise (voir compagnie)
# On veut écouter les inputs du joueur :
# -> Spécifier les inputs , les limités  
# Detecter un input pour le menu 
# Detection input changement fenetre world map/skilltree
# Detecter les inputs du skilltree
