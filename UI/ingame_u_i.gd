extends Control

class_name IngameUI

var health_label: Label
var mana_label: Label
var current_element_label: Label

var player_character: PlayerCharacter

func toggle_visibility(in_visible: bool) -> void:
	visible = in_visible

func assign_player_character(in_player_character: PlayerCharacter = null) -> void:
	player_character = in_player_character
	player_character.health_component.OnDamage.connect(_update_health_display)
	player_character.health_component.OnHeal.connect(_update_health_display)

	health_label = %HPValue	
	mana_label = %MPValue
	current_element_label = %CurrentElement
	
	_update_health_display()
	
	
func _update_health_display() -> void:
	health_label.text = str(player_character.health_component.current_health)
