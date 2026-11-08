extends Building
class_name Recruitement_building

enum Ressources {
	DEVELOPPER,
	RESEARCHER
}

var _name : String
var _ressource : Ressources
var _array_recruiter : Dictionary[Unit, int] = {} # id of unit : turn to get ressource
var _turn_get_unit = 2
var _max_ressource : int

func _init(id_unic: int, position_: Vector2i, ressource: Ressources,
	texture: Texture2D, max_ressource: int, name: String) -> void:
	super(id_unic, position_, texture)
	_ressource = ressource
	_max_ressource = max_ressource
	_name = name


func update_end_turn(tiles: Array[Tile]) -> void:
	if _max_ressource == 0:
		return
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
				_max_ressource -=1
			else:
				new_array_recruiter[occupant] = turn - 1
		else:
			new_array_recruiter[occupant] = _turn_get_unit - 1
	_array_recruiter = new_array_recruiter


func display():
	print("Position : ", position.get_position())
	print("Ressource : ", _ressource)


func text_turn_left() -> String:
	if _max_ressource == 0:
		return ''
	for key in _array_recruiter:
		if key.get_company_id() == 0:
			return ("Tour restant pour que votre unité recrute : " + str(_array_recruiter[key]))
	return ''
