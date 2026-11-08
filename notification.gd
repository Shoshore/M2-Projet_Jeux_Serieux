extends CanvasLayer

@onready var mid: Panel = $Mid
@onready var side: VBoxContainer = $Side

@export var side_label_node : PackedScene = preload("res://Scenes/SideLabel.tscn")

var mid_tween_reference = null

func show_side(message):
	var side_label : Label = side_label_node.instantiate()
	side_label.text = message
	side.add_child(side_label)
	
	var tween : Tween = side_label.create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(side_label.queue_free)


func show_mid(message):
	if mid_tween_reference:
		mid_tween_reference.kill()
		
	mid.find_child("Label").text = message
	mid.modulate = Color(1,1,1,1)
	
	mid_tween_reference = create_tween()
	mid_tween_reference.tween_interval(2)
	mid_tween_reference.tween_property(mid,"modulate",Color(1,1,1,0),0.5)
