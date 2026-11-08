extends Node

const HEX_SIZE := 100
const outline_default_color = Color(0, 0, 0, 0)
const outline_selected_color = Color(1, 0, 0, 1)
const FOG_COLOR := Color(0, 0, 0, 1)
const outline_selected_width = 5.0
var game_result := Result.new()
signal company_fire_employee(position: Vector2i)
signal recruitement_give_employee(id: int, ressource: Recruitement_building.Ressources)
