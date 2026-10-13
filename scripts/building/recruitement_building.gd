extends Building
class_name Recruitement_building

enum Ressources {
	DEVELOPPER,
	RESEARCHER
}

var _ressource : Ressources

func _init(id_unic: int, position_: Vector2i, ressource : Ressources) -> void:
	super(id_unic, position_)
	texture = Visuals.RECRUITEMENT
	_ressource = ressource

func display():
	print("Position : ", _position.x, _position.y)
	print("Ressource : ", _ressource)
