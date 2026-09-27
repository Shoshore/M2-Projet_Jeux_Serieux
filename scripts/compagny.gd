extends Node2D
# TODO :
# link skill tree and connect his signal
# link unity + reset their pm
# try to use sprite when generated on map and make a cool shape on map
class_name compagny

var id: int:
			get: return _id
var _id: int

var _number_developer = 1
var _number_researcher = 1
var _number_recruiter = 1

var _monnay = 100
var _boost_turnover = 1

var _mood_gauge = 30
var _boost_mood = 1
var _mood_threshold = 0

var _list_unities = []

var _path_sprite: String
# var _skill_tree: SkillTree

func init(path_sprite: String, id_unic: int) -> void:
	_path_sprite = path_sprite
	_id = id_unic
	# push new unit into the list -> need to have the basic unit objet to do this
	# new skill tree
	# skill_tree.boost_turnover_changed.connect(_on_boost_turnover_changed)
	# skill_tree.boost_mood_changed.connect(_on_boost_mood_changed)


func _on_boost_turnover_changed(new_boost: float) -> void:
	_boost_turnover = new_boost


func _on_boost_mood_changed(new_boost: float) -> void:
	_boost_mood = new_boost


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
		continue # reset pm of units


func _update_mood() -> void:
	_mood_threshold += 3


func update_end_turn(tour: int) -> void:
	_update_monnay(tour)
	_update_unit()
	_update_mood()
