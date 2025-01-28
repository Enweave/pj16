extends FeatureBase

class_name WeaponBase

@export_group("Combat parameters")
@export var damage: float = 1
@export var element: Constants.Elements = Constants.Elements.None
@export var windup_time: float = 0.1
@export var cooldown_time: float = 0.3
@export var full_auto: bool = false

@export_group("Weapon Animation")
@export var weapon_sprite_origin: Node2D = null
@export var weapon_sprite: AnimatedSprite2D = null
@export var weapon_sprite_animation_idle: String = "default"
@export var weapon_sprite_animation_windup: String = "windup"
@export var weapon_sprite_animation_attack: String = "attack"

var instigator: CharacterBase = null

func _process(_delta: float) -> void:
	super._process(_delta)
	if weapon_sprite_origin != null and instigator != null:
		weapon_sprite_origin.scale.x = instigator.get_latent_control_direction().x
	

func _ready():
	super._ready()
	initialize(windup_time, cooldown_time, 0, full_auto)
	_update_status_label()
	
	Windup.connect(_on_windup)  
	Activation.connect(_on_activation)
	CooldownPassed.connect(_on_cooldown_passed)
	if owner != null:
		instigator = owner

func _on_windup() -> void:
	if weapon_sprite != null:
		weapon_sprite.play(weapon_sprite_animation_windup)
	_update_status_label("Charging...")
	
func _on_activation() -> void:
	if weapon_sprite != null:
		weapon_sprite.play(weapon_sprite_animation_attack)
	_update_status_label("ATAC!")
	
func _on_cooldown_passed() -> void:
	if weapon_sprite != null:
		weapon_sprite.play(weapon_sprite_animation_idle)
	_update_status_label("")
	
	
func _update_status_label(in_text: String = "") -> void:
	if %StatusLabel:
		%StatusLabel.text = in_text
