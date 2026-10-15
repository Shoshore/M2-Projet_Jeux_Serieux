extends Building
class_name Recruitement_building

enum Ressources {
	DEVELOPPER,
	RESEARCHER
}


var _ressource : Ressources


func _init(id_unic: int, position_: Vector2i, ressource: Ressources) -> void:
	var texture := Visuals.RECRUITEMENT
	super(id_unic, position_, texture)
	_ressource = ressource


func display():
	print("Position : ", position.get_position())
	print("Ressource : ", _ressource)
