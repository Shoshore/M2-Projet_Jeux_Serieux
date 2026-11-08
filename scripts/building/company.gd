extends Building
class_name Company

var vision: Vision_component

var _number_developer := 1
var _number_researcher := 1
var _number_recruiter := 0

const _NET_SALARY := 2350.0
const _NET_TO_GROSS := 0.78
const _EMPLOYER_CHARGES := 0.42

const _GROSS_SALARY := _NET_SALARY / _NET_TO_GROSS
const _EMPLOYER_COST := _GROSS_SALARY * (1.0 + _EMPLOYER_CHARGES)


const _OVERHEAD := 50
const _PROFIT := 9100

const _RAISE := 0.1
const _RAISE_EVERY := 6

const _MOOD_STEP := 3
const _MOOD_FIRE_CONS := 15
const _MOOD_MALUS_FLOOR := 0.6
const _MOOD_MALUS_PER_POINT := 0.1

const _REFUND := 0.1
const _BORROWED_AMOUNT := 20000
const _FIRE_EMPLOY_AMOUT := 10000
const _INTEREST := 1.2

var _funds := 35000
var _boost_turnover := 1.0

var _mood_gauge := 30
var _mood_reduce := 0
var _mood_threshold := 0.0

var _debt := 0.0

var _list_unities: Array[Unit]

var _next_unit_id := 0



var _cyber_security := false
var _cyber_defense := false
var _cyber_attack := false

func _init(id_unic: int, position: Vector2i) -> void:
	super(id_unic, position, Visuals.COMPANY)
	vision = Vision_component.new(3)

# -------------------
# Unit creation 
# -------------------

enum Create_unit_type {
	RECRUITER
}


func _generate_unit_id() -> int:
	var new_id := _next_unit_id
	_next_unit_id += 1
	return new_id


func create_unit(tile : Tile, next_unite: Create_unit_type) -> void:
	if tile == null:
		return

	var unit: Unit
	match next_unite:
		Create_unit_type.RECRUITER:
			unit = Recruiter.new(id.get_id(), _generate_unit_id(), tile.position_.get_position())
			_number_recruiter += 1

	if unit == null:
		return

	_list_unities.push_back(unit)
	tile.set_occupant(unit) 
	tile.reload_visual()


# -------------------
# Fire Employee
# -------------------
enum Employee_type {
	DEVELOPER,
	RESEARCHER,
	RECRUITER
}


func _fire_consequence():
	_mood_reduce += _MOOD_FIRE_CONS
	_funds += _FIRE_EMPLOY_AMOUT


func _fire_unit() -> void:
	var unit := _list_unities[0]
	_list_unities.remove_at(0)
	Global.company_fire_employee.emit(unit.movement.position.get_position())


func fire_employee(type: Employee_type) -> void:
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
				_fire_unit()
				_fire_consequence()

func borrowed() -> void:
	_debt += _BORROWED_AMOUNT * _INTEREST
	_funds += _BORROWED_AMOUNT
# -------------------
# Update
# -------------------
func _get_pay_rise(turn: int) -> float:
	return pow(1.0 + _RAISE, floori(float(turn) / _RAISE_EVERY))


func _get_mood_factor() -> float:
	var gap := _mood_threshold - (_mood_gauge - _mood_reduce)
	if gap <= 0:
		return 1.0
	return maxf(_MOOD_MALUS_FLOOR, 1.0 - _MOOD_MALUS_PER_POINT * gap)


func _update_funds(turn: int, check := false) -> int:
	var staff := get_number_employees()
	var payroll := _get_pay_rise(turn) * _EMPLOYER_COST * staff
	var overhead := _OVERHEAD * staff

	var pay_debt := _debt * _REFUND
	if _debt < 100.0:
		pay_debt = _debt
	_debt = maxf(_debt - pay_debt, 0.0)

	var profit := _boost_turnover * _PROFIT * _number_developer * _get_mood_factor()
	if check :
		return int(profit - payroll - overhead - pay_debt)
	else :
		_funds += int(profit - payroll - overhead - pay_debt)
		return 0 


func _update_unit() -> void:
	for unit in _list_unities:
		unit.update_end_turn()


func _update_mood() -> void:
	_mood_threshold = minf(_mood_threshold + _MOOD_STEP, 80.0)
	_mood_reduce = maxi(_mood_reduce - 3, 0)


func update_end_turn(tour: int) -> void:
	_update_funds(tour)
	_update_unit()
	_update_mood()

# -------------------
# Getter
# -------------------
func get_funds() -> int:
	return _funds

func get_number_developers() -> int:
	return _number_developer


func get_number_researchers() -> int:
	return _number_researcher


func get_number_recruiters() -> int:
	return _number_recruiter


func get_number_employees() -> int:
	return _number_developer + _number_researcher + _number_recruiter


func get_happiness() -> int:
	return _mood_gauge

func get_mood_threshold() -> int:
	return _mood_threshold

func display() -> void:
	print("nb dev : ", _number_developer)
	print("nb researcher : ", _number_researcher)
	print("nb recruiter : ", _number_recruiter)
	print("funds : ", _funds)
	print("boost turnover : ", _boost_turnover)
	print("mood gauge : ", _mood_gauge)
	print("mood threshold : ", _mood_threshold)
	print("------------------------")


# -------------------
# setter
# -------------------

func set_ressources(ressource: Recruitement_building.Ressources) -> void:
	match ressource:
		Recruitement_building.Ressources.DEVELOPPER:
			_number_developer += 1
		Recruitement_building.Ressources.RESEARCHER:
			_number_researcher += 1


# Application des compétences
func apply_effect(effect: SkillEffect, tile : Tile = null) -> void:
	# En cas d'erreur dans le nom de la variable
	if not effect.variable_name in self:
		push_error("[COMPAGNY] Variable inconnue : '%s'" % effect.variable_name)
		return
	
	var selected_var = get(effect.variable_name)
	print("[COMPAGNY] variable modifier : '%s'" % effect.variable_name)
	match effect.operation:
		SkillEffect.Operation.ADD:
			set(effect.variable_name, selected_var + effect.value)
		SkillEffect.Operation.MUL:
			set(effect.variable_name, selected_var * effect.value)
		SkillEffect.Operation.BOOL:
			set(effect.variable_name, not selected_var)
		SkillEffect.Operation.PO:
			vision.sight_range += 1
			for unit in _list_unities:
				unit.vision.sight_range += 1
		SkillEffect.Operation.UNIT:
			create_unit(tile, Create_unit_type.RECRUITER)
		SkillEffect.Operation.PM:
			for unit in _list_unities:
				unit.movement._max_movement += 1
				unit.movement._current_movement += 1
		SkillEffect.Operation.RESSOURCE:
			pass


func apply_skill(skill: Skill, tile : Tile = null) -> void:
	for effect in skill.effects:
		apply_effect(effect, tile)
