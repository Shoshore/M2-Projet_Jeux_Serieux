# TODO :
# link skill tree and connect his signal
# link unity + reset their pm
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

func _init(id_unic: int, position: Vector2i = Vector2i.ZERO) -> void:
	super(id_unic, position, 5)
	# push new unit into the list -> need to have the basic unit objet to do this
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

enum EmployeeType {
	DEVELOPER,
	RESEARCHER,
	RECRUITER
}

func fire_employee(type: EmployeeType) -> void:
	match type:
		EmployeeType.DEVELOPER:
			if _number_developer > 0:
				_number_developer -= 1
				_fire_consequence()
		EmployeeType.RESEARCHER:
			if _number_researcher > 0:
				_number_researcher -= 1
				_fire_consequence()
		EmployeeType.RECRUITER:
			if _number_recruiter > 0:
				_number_recruiter -= 1
				_fire_consequence()


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
