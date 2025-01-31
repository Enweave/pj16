extends Node2D

class_name ScoreFx

var score: int = 0

func _ready() -> void:
	%Label.text = str(score)
