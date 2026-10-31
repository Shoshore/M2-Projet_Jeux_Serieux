class_name SkillEffect
extends Resource

enum Operation { ADD, MUL, BOOL }

@export var variable_name: StringName
@export var operation: Operation
@export var value: float = 0.0
