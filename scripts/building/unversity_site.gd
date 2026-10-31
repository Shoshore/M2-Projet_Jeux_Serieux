extends Recruitement_building
class_name University_site

func _init(id_unic: int, position_: Vector2i) -> void:
	super(id_unic, position_, Recruitement_building.Ressources.RESEARCHER, Visuals.UNIVERSITY)
