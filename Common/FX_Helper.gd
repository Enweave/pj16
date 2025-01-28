extends Node

class_name FX_Helper

enum FX_TYPE {
	DEFAULT_IMPACT = 0
}
	
const FX_SCENES: Dictionary = {
	FX_TYPE.DEFAULT_IMPACT: "res://Actors/FX/impact.tscn"
}

static func get_fx_path(in_fx: FX_TYPE) -> String:
	return FX_SCENES[in_fx]