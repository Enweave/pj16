extends Control

class_name IngameUI

var health_label: Label
var mana_label: Label
var current_element_label: Label
var score: int = 0
var player_character: PlayerCharacter

func toggle_visibility(in_visible: bool) -> void:
	visible = in_visible

func assign_player_character(in_player_character: PlayerCharacter = null) -> void:
	player_character = in_player_character
	player_character.health_component.OnDamage.connect(_update_health_display)
	player_character.health_component.OnHeal.connect(_update_health_display)

	player_character.ability_inventory.CombinationSwitched.connect(update_elements_ui)	

	health_label = %HPValue	
	mana_label = %MPValue
	current_element_label = %CurrentElement
	
	_update_health_display()
	update_elements_ui()
	
func update_elements_ui() -> void:
	match player_character.ability_inventory._current_combination:
		AbilityInventory.ElementCombinations.FIRE:
			current_element_label.text = "Fire"
		AbilityInventory.ElementCombinations.WATER:
			current_element_label.text = "Water"
		AbilityInventory.ElementCombinations.EARTH:
			current_element_label.text = "Earth"
		AbilityInventory.ElementCombinations.FIRE_WATER:
			current_element_label.text = "Fire/Water"
		AbilityInventory.ElementCombinations.FIRE_EARTH:
			current_element_label.text = "Fire/Earth"
		AbilityInventory.ElementCombinations.WATER_EARTH:
			current_element_label.text = "Water/Earth"
	
func _update_health_display(_amount: float = 0, _in_element = null) -> void:
	health_label.text = str(player_character.health_component.current_health)

func set_score(in_score: int) -> void:
	score = in_score
	%ScoreValue.text = str(score)