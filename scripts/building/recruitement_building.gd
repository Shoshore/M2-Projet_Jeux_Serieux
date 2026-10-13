extends Building
class_name Recruitement_building

enum Ressources {
	DEVELOPPER,
	RESEARCHER
}

var _ressource : Ressources

func _init(id_unic: int, position_: Vector2i, map: Map, ressource : Ressources) -> void:
	super(id_unic, position_, map)
	texture = Visuals.RECRUITEMENT
	_ressource = ressource

func display():
	print("Position : ", position.x, position.y)
	print("Ressource : ", _ressource)
