extends Node2D

class_name PlayerSprite
var player_character: PlayerCharacter = null
@onready var body_sprite: AnimatedSprite2D = %SpriteBody
@onready var head_sprite: AnimatedSprite2D = %SpriteHead

func _ready() -> void:
	if owner != null and owner is PlayerCharacter:
		player_character = owner

		
func _process(delta: float) -> void:
	if player_character != null:
		var flip: bool = player_character.get_latent_control_direction().x < 0
		body_sprite.flip_h = flip
		head_sprite.flip_h = flip
