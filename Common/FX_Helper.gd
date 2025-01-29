extends Node

class_name FX_Helper

enum FX_TYPE {
	DEFAULT_IMPACT = 0,
	SWITCH_COMBINATION = 1,
	JUMP = 2,
}
	
const FX_SCENES: Dictionary = {
	FX_TYPE.DEFAULT_IMPACT: "res://Actors/FX/impact.tscn",
	FX_TYPE.SWITCH_COMBINATION: "res://Actors/FX/switch_combination.tscn",
	FX_TYPE.JUMP: "res://Actors/FX/jump.tscn",
}

static func get_fx_path(in_fx: FX_TYPE) -> String:
	return FX_SCENES[in_fx]