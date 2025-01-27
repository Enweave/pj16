extends Node2D
class_name PlayerSprite
var player_character: PlayerCharacter = null

@onready var body_sprite: AnimatedSprite2D = %SpriteBody
@onready var head_sprite: AnimatedSprite2D = %SpriteHead

var _prev_state_string: String = ""
var _current_state_string: String = ""
var _current_action: AnimationStateKeys = AnimationStateKeys.IDLE

enum AnimationStateKeys {
	IDLE,
	WALK,
	JUMP,
	ACTION
}

const ANIMATION_ACTION_PARAM_NAMES: Dictionary = {
	AnimationStateKeys.IDLE: "idle",
	AnimationStateKeys.WALK: "walk",
	AnimationStateKeys.JUMP: "jump",
	AnimationStateKeys.ACTION: "action"
}

const COMBINATION_BODY_HEAD_MAP: Dictionary = {
	AbilityInventory.ElementCombinations.FIRE: {
		"body": "fire",
		"head": "fire"
	},
	AbilityInventory.ElementCombinations.WATER: {
		"body": "water",
		"head": "water"
	},
	AbilityInventory.ElementCombinations.EARTH: {
		"body": "earth",
		"head": "earth"
	},
	AbilityInventory.ElementCombinations.FIRE_WATER: {
		"body": "fire",
		"head": "water"
	},
	AbilityInventory.ElementCombinations.FIRE_EARTH: {
		"body": "fire",
		"head": "earth"
	},
	AbilityInventory.ElementCombinations.WATER_EARTH: {
		"body": "water",
		"head": "earth"
	}
}


func _ready() -> void:
	if owner != null and owner is PlayerCharacter:
		player_character = owner


func _update_body_sprite() -> void:
	if _current_action == AnimationStateKeys.ACTION:
		return
	else:
		body_sprite.play(
			"%s_%s" % [
				COMBINATION_BODY_HEAD_MAP[player_character.ability_inventory._current_combination]["body"], 
				ANIMATION_ACTION_PARAM_NAMES[_current_action]
			]
		)

func _update_head_sprite() -> void:
	if _current_action == AnimationStateKeys.ACTION:
		head_sprite.visible = false
		return
	else:
		head_sprite.visible = true
	head_sprite.play(
		"%s_%s" % [
			COMBINATION_BODY_HEAD_MAP[player_character.ability_inventory._current_combination]["head"], 
			ANIMATION_ACTION_PARAM_NAMES[_current_action]
		]
	)


func _on_state_changed() -> void:
	_update_head_sprite()
	_update_body_sprite()



func _calc_action_state() -> AnimationStateKeys:
	if player_character.using_ability:
		return AnimationStateKeys.ACTION
	if player_character.is_on_floor():
		if player_character.get_control_direction().x != 0:
			return AnimationStateKeys.WALK
	else:
		return AnimationStateKeys.JUMP
	return AnimationStateKeys.IDLE

func _make_state_string() -> String:
	var state_string: String = "%s_%s"  % [
	_current_action,
	player_character.ability_inventory._current_combination
	]
	return state_string

func _process(_delta: float) -> void:
	if player_character != null:
		var flip: bool = player_character.get_latent_control_direction().x < 0
		body_sprite.flip_h = flip
		head_sprite.flip_h = flip

	_current_action = _calc_action_state()
	_current_state_string = _make_state_string()
	if _current_state_string != _prev_state_string:
		_prev_state_string = _current_state_string
		_on_state_changed()
