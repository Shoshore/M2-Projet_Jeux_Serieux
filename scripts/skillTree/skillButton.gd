extends Button

@export var skill: Skill

func _ready() -> void:
	if skill:
		text = skill.name
		tooltip_text = skill.description
