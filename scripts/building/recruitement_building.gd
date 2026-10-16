extends Building
class_name Recruitement_building

enum Ressources {
	DEVELOPPER,
	RESEARCHER
}


var _ressource : Ressources
var _array_recruiter : Dictionary[Unit, int] = {} # id of unit : turn to get ressource
var _turn_get_unit = 2

func _init(id_unic: int, position_: Vector2i, ressource: Ressources) -> void:
	var texture := Visuals.RECRUITEMENT
	super(id_unic, position_, texture)
	_ressource = ressource


func update_end_turn():
	Global.recruitement_ask_map_tile.emit(id.get_id())


func manage_ressources_end_turn(tiles: Array[Tile]) -> void:
	var new_array_recruiter : Dictionary[Unit, int] = {}
	for tile in tiles:
		var occupant = tile.get_occupant() 
		if occupant == null or not (occupant is Recruiter):
			continue
		if _array_recruiter.has(occupant):
			var turn = _array_recruiter[occupant]
			if (turn - 1) <= 0:
				Global.recruitement_give_employee.emit(occupant.get_company_id(), _ressource)
				new_array_recruiter[occupant] = _turn_get_unit
			else:
				new_array_recruiter[occupant] = turn - 1
		else:
			new_array_recruiter[occupant] = _turn_get_unit
	_array_recruiter = new_array_recruiter


func display():
	print("Position : ", position.get_position())
	print("Ressource : ", _ressource)
