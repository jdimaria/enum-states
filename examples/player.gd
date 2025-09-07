extends CharacterBody2D


@export var tween_duration: float = 0.2

@onready var sprite: Sprite2D = $Sprite2D
@onready var psm: PlayerStateMachine = $PlayerStateMachine

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -600.0
const JUMP_SQUASH: Vector2 = Vector2(1.05, 0.8)
const JUMP_STRETCH: Vector2 = Vector2(0.8, 1.05)
const GROUNDED_SQUASH: Vector2 = Vector2(1.025, 0.95)
const GROUNDED_STRETCH: Vector2 = Vector2(0.95, 1.025)

var tween: Tween


func _ready() -> void:
	psm.state_entered.connect(_on_state_entered)


func _on_state_entered(state: PlayerStateMachine.PlayerState) -> void:
	match state:
		PlayerStateMachine.PlayerState.IDLE:
			tween = create_tween().set_loops()
			tween.tween_property(sprite, "scale", GROUNDED_SQUASH, tween_duration * 3.0)
			tween.tween_property(sprite, "scale", GROUNDED_STRETCH, tween_duration * 1.5)
		PlayerStateMachine.PlayerState.WALKING:
			tween = create_tween().set_loops()
			tween.tween_property(sprite, "scale", GROUNDED_SQUASH, tween_duration * 1.5)
			tween.tween_property(sprite, "scale", GROUNDED_STRETCH, tween_duration * 0.75)
		PlayerStateMachine.PlayerState.JUMPING:
			tween = create_tween()
			tween.tween_property(sprite, "scale", JUMP_SQUASH, tween_duration)
			velocity.y = JUMP_VELOCITY
			move_and_slide()
			tween.tween_property(sprite, "scale", JUMP_STRETCH, tween_duration)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		psm.buffer_jump()
	if is_on_floor():
		if psm.is_buffering_jump():
			psm.jump()
	else:
		if not psm.is_jumping() or Input.is_action_just_released("ui_accept"):
			psm.fall()
		velocity += get_gravity() * delta * psm.get_gravity_multiplier()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		psm.walk()
		velocity.x = direction * SPEED
	else:
		if is_on_floor():
			psm.idle()
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
