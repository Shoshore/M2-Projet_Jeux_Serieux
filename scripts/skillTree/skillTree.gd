class_name SkillTree
extends Resource

@export var skills: Array[Skill] = []

func get_skill(id: StringName) -> Skill:
	for s in skills:
		if s.id == id:
			return s
	return null
