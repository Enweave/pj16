extends FeatureBase

class_name WaterAbility
var player_character: PlayerCharacter = null

@export var slide_speed: float = 900


func _ready() -> void:
	super._ready()
	if owner != null and owner is PlayerCharacter:
		player_character = owner
		initialize(
			0.01, 
			0.6, 
			0, 
			false, 
			"water_slide")
		
		self.Activation.connect(_on_water_activation)
		self.CooldownPassed.connect(_on_water_cooldown_passed)
		player_character.LowCeilingChanged.connect(_on_player_low_ceiling_changed)

func _on_water_activation() -> void:
	var slide_velocity: Vector2 = Vector2.ZERO
	slide_velocity.x = player_character.get_latent_control_direction().x * slide_speed
	player_character.velocity = slide_velocity
	player_character.toggle_blob(true)
	lock()
		
func _on_water_cooldown_passed() -> void:
	if !player_character._low_ceiling:
		player_character.toggle_blob(false)
		unlock(false)
			
func _on_player_low_ceiling_changed() -> void:
	if !player_character._low_ceiling and !_active:
		player_character.toggle_blob(false)
		unlock(false)
