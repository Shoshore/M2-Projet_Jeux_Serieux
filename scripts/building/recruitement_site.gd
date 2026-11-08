extends Recruitement_building
class_name Recruitement_site

func _init(id_unic: int, position_: Vector2i, name: String) -> void:
	super(id_unic, position_, Recruitement_building.Ressources.DEVELOPPER, Visuals.RECRUITEMENT, 1, name)
