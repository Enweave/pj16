extends CharacterWithHealth

class_name GroundEnemyBase

func _ready() -> void:
    super._ready()
    health_component.OnDeath.connect(_on_death)
    
func _on_death() -> void:
    call_deferred("queue_free")