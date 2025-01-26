extends Node2D

class_name PlayerSprite
var player_character: PlayerCharacter = null


func _ready() -> void:
    if owner != null and owner is PlayerCharacter:
        player_character = owner
