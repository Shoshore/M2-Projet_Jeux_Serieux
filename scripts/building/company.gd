extends Building
class_name Company

var vision: Vision_component

var _number_developer := 1
var _number_researcher := 1
var _number_recruiter := 0

var _salary_pay := 500
var _profit := 800

var _funds := 100
var _boost_turnover := 1

var _mood_gauge := 30
var _mood_threshold := 0

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
	_mood_gauge = floor(_mood_gauge / 2)
	_funds += 2000


func _find_unit_by_id(unit_id: int) -> Unit:
	for unit in _list_unities:
		if unit.id.get_id() == unit_id:
			return unit
	return null


func _fire_unit(unit: Unit) -> void:
	var index := _list_unities.find(unit)
	if index == -1:
		return
	_list_unities.remove_at(index)
	Global.company_fire_employee.emit(unit.movement.position.get_position())


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
				_fire_unit(_find_unit_by_id(id_))


# -------------------
# Update
# -------------------
func _update_funds(tour: int) -> void:
	# pay
	var pay_rise = 1 + 0.3 * floor(tour / 3)
	var total_payroll = pay_rise * (_salary_pay * (_number_developer + _number_researcher + _number_recruiter))
	var energy_cost = 40 * (_number_developer + _number_researcher + _number_recruiter)

	# profit
	var profit = _boost_turnover * _profit * _number_developer
	if _mood_threshold > _mood_gauge:
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
func apply_effect(effect: SkillEffect) -> void:
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


func apply_skill(skill: Skill) -> void:
	for effect in skill.effects:
		apply_effect(effect)
