extends Node

const HEX_SIZE := 100
var game_result := Result.new()
signal company_ask_map_tile(id: int)
signal company_fire_employee(position: Vector2i)
#Faire le système de sauvegardes entre scène 
