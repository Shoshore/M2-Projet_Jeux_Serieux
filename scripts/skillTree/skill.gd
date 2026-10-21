class_name Skill
extends Resource

@export var id: String
@export var name: String
@export_multiline var description: String
@export var icone: Texture2D
@export_range(0, 10) var cout: int = 1
@export var requierment: Array[Skill] = []
@export var effects: Array[SkillEffect] = []
