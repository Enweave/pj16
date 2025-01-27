extends FeatureBase

class_name WeaponBase

@export_group("Weapon base")
@export var damage: float = 1
@export var element: Constants.Elements = Constants.Elements.None
@export var windup_time: float = 0.1
@export var cooldown_time: float = 0.3
@export var full_auto: bool = false

var instigator: CharacterBase = null

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
	_update_status_label("Charging...")
	
func _on_activation() -> void:
	_update_status_label("ATAC!")
	
func _on_cooldown_passed() -> void:
	_update_status_label("")
	
	
func _update_status_label(in_text: String = "") -> void:
	if %StatusLabel:
		%StatusLabel.text = in_text
