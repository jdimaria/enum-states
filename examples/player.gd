extends CharacterBody2D


@onready var psm: PlayerStateMachine = $PlayerStateMachine

const SPEED = 300.0
const JUMP_VELOCITY = -500.0


func _ready() -> void:
	psm.state_entered.connect(_on_state_entered)


func _on_state_entered(state: PlayerStateMachine.PlayerState) -> void:
	if state == PlayerStateMachine.PlayerState.JUMPING:
		velocity.y = JUMP_VELOCITY
		move_and_slide()


func _physics_process(delta: float) -> void:
	if is_on_floor():
		if psm.is_buffering_jump():
			psm.jump()
		else:
			psm.idle()
	else:
		psm.fall()
		velocity += get_gravity() * delta * psm.get_gravity_multiplier()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
