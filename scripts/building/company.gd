extends Building
class_name Company

var _number_developer = 1
var _number_researcher = 1
var _number_recruiter = 0

var _funds = 100
var _boost_turnover = 1

var _mood_gauge = 30
var _boost_mood = 1
var _mood_threshold = 0

var _list_unities: Array[Unit]

var _skill_tree: SkillTree
var _next_unit_id: int = 0

func _find_tile_create_unit() -> Tile:
	return _map.get_free_neighbor(position.position)

enum Create_unit_type {
	RECRUITER
}

func _generate_unit_id() -> int:
	var new_id := _next_unit_id
	_next_unit_id += 1
	return new_id


func create_unit(type: Create_unit_type) -> void:
	var tile := _find_tile_create_unit()
	if tile == null:
		return

	var unit: Unit
	match type:
		Create_unit_type.RECRUITER:
			unit = Recruiter.new(_id, _generate_unit_id(), tile.coordinate)
			_number_recruiter += 1

	if unit == null:
		return

	_list_unities.push_back(unit)
	tile.occupant = unit
	tile.reload_visual()


func _init(id_unic: int, position_: Vector2i, map: Map) -> void:
	super(id_unic, position_, 5, map)
	texture = Visuals.COMPANY
	create_unit(Create_unit_type.RECRUITER)

func _fire_consequence():
	_mood_gauge = floor(_mood_gauge / 2)
	_funds += 2000

enum Employee_type {
	DEVELOPER,
	RESEARCHER,
	RECRUITER
}

func _find_unit_by_id(unit_id: int) -> Unit:
	for unit in _list_unities:
		if unit.id == unit_id:
			return unit
	return null


func fire_unit(unit: Unit) -> void:
	var index := _list_unities.find(unit)
	if index == -1:
		return
	_list_unities.remove_at(index)
	var tile := _map.get_tile_at(unit.position_component.coord)
	if tile != null:
		tile.occupant = null


func fire_employee(type: Employee_type, id_: int = -1) -> void:
	match type:
		Employee_type.DEVELOPER:
			if _number_developer > 0:
				_number_developer -= 1
				_fire_consequence()
		Employee_type.RESEARCHER:
			if _number_researcher > 0:
				_number_researcher -= 1
				_fire_consequence()
		Employee_type.RECRUITER:
			if _number_recruiter > 0:
				_number_recruiter -= 1
				fire_unit(_find_unit_by_id(id_))


func _update_funds(tour: int) -> void:
	# pay
	var pay_rise = 1 + 0.3 * floor(tour / 3)
	var total_payroll = pay_rise * (230 * _number_developer + 205 * _number_researcher + 165 * _number_recruiter)
	var energy_cost = 40 * (_number_developer + _number_researcher + _number_recruiter)

	# profit
	var profit = _boost_turnover * 850 * _number_developer
	if _mood_threshold > (_mood_gauge * _boost_mood):
		profit *= 0.4

	_funds += profit - (energy_cost + total_payroll)


func _update_unit() -> void:
	for unit in _list_unities:
		unit.update_end_turn()


func _update_mood() -> void:
	_mood_threshold += 3
	if _mood_gauge < 30:
		_mood_gauge += 3
		if _mood_gauge > 30:
			_mood_gauge = 30


func update_end_turn(tour: int) -> void:
	_update_funds(tour)
	_update_unit()
	_update_mood()


func display() -> void:
	print("nb dev :", _number_developer)
	print("nb researcher :", _number_researcher)
	print("nb recruiter :", _number_recruiter)
	print("funds: ", _funds)
	print("boost turnover: ", _boost_turnover)
	print("mood gauge: ", _mood_gauge)
	print("boost mood: ", _boost_mood)
	print("mood threshold : ", _mood_threshold)
	print("---------------")
