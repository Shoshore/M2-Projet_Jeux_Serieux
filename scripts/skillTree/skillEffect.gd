class_name SkillEffect
extends Resource

enum Operation { ADD, MUL, BOOL, PO, PM, UNIT }

@export var variable_name: StringName
@export var operation: Operation
@export var value: float = 0.0
