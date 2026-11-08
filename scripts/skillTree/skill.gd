class_name Skill
extends Resource

@export var id: String
@export var name: String
@export_multiline var description: String
@export var icone: Texture2D
@export var requierment: Array[Skill] = []
@export var effects: Array[SkillEffect] = []
@export var conditions: Conditions
@export var blanks: Array[SkillBlank] = []
@export var color: Color = Color.WHITE
