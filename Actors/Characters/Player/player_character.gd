extends CharacterBase

class_name PlayerCharacter


func _ready() -> void:
    super._ready()
    FlowControllerAutoload.set_player_character(self)