extends CharacterBody2D


const SPEED: float = 300.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED * (1.0 + delta)
	move_and_slide()
