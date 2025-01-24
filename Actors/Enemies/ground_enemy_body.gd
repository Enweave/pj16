extends CollisionShape2D

@onready var body_sprite: AnimatedSprite2D = %AnimatedSprite2D
var character: CharacterBase = null

func _ready() -> void:
	if get_parent() is CharacterBase:
		character = get_parent()

		
func _process(_delta: float) -> void:
	if character != null:
		if character.get_latent_control_direction().x < 0:
			body_sprite.flip_h = true
		else:
			body_sprite.flip_h = false
			
		if character.velocity.length() > 0:
			body_sprite.play("walk")
		else:
			body_sprite.play("idle")
