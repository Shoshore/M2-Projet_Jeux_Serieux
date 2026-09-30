# TODO :
# link skill tree and connect his signal

extends Building
class_name Compagny

var _number_developer = 1
var _number_researcher = 1
var _number_recruiter = 1

var _monnay = 100
var _boost_turnover = 1

var _mood_gauge = 30
var _boost_mood = 1
var _mood_threshold = 0

var _list_unities: Array[Unit]

# var _skill_tree: SkillTree
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
			unit = Recruiter.new(_id, _generate_unit_id(), tile.coordonnee)
			_number_recruiter += 1

	if unit == null:
		return

	_list_unities.push_back(unit)
	tile.occupant = unit


func _init(id_unic: int, position: Vector2i, map: Map) -> void:
	super(id_unic, position, 5, map)
	create_unit(Create_unit_type.RECRUITER)
	# new skill tree
	# skill_tree.boost_turnover_changed.connect(_on_boost_turnover_changed)
	# skill_tree.boost_mood_changed.connect(_on_boost_mood_changed)


func _on_boost_turnover_changed(new_boost: float) -> void:
	_boost_turnover = new_boost


func _on_boost_mood_changed(new_boost: float) -> void:
	_boost_mood = new_boost

func _fire_consequence():
	_mood_gauge = floor(_mood_gauge / 2)
	_monnay += 2000

enum Employ_type {
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


func fire_employee(type: Employ_type, id: int = -1) -> void:
	match type:
		Employ_type.DEVELOPER:
			if _number_developer > 0:
				_number_developer -= 1
				_fire_consequence()
		Employ_type.RESEARCHER:
			if _number_researcher > 0:
				_number_researcher -= 1
				_fire_consequence()
		Employ_type.RECRUITER:
			if _number_recruiter > 0:
				_number_recruiter -= 1
				fire_unit(_find_unit_by_id(id))


func _update_monnay(tour: int) -> void:
	# pay
	var pay_rise = 1 + 0.3 * floor(tour / 3)
	var total_payroll = pay_rise * (230 * _number_developer + 205 * _number_researcher + 165 * _number_recruiter)
	var energy_cost = 40 * (_number_developer + _number_researcher + _number_recruiter)

	# profit
	var profit = _boost_turnover * 850 * _number_developer
	if _mood_threshold > (_mood_gauge * _boost_mood):
		profit *= 0.4

	_monnay += profit - (energy_cost + total_payroll)


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
	_update_monnay(tour)
	_update_unit()
	_update_mood()
