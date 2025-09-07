class_name PlayerStateMachine extends EnumStateMachine


enum PlayerState {
	IDLE,
	WALKING,
	BUFFERING_JUMP,
	JUMPING,
	FALLING
}

@export var jump_buffer: float = 0.1
var _jump_buffer_timer: float


func _init() -> void:
	_states = PlayerState


func _enter(enter_state: int) -> bool:
	match enter_state:
		PlayerState.BUFFERING_JUMP:
			_jump_buffer_timer = jump_buffer
			return true
		_:
			return true


func _exit(exit_state: int) -> bool:
	match exit_state:
		PlayerState.BUFFERING_JUMP:
			_jump_buffer_timer = 0
			return true
		_:
			return true


func _is_valid_transition(to: int) -> bool:
	if not super(to):
		return false
	match to:
		PlayerState.IDLE:
			return true
		PlayerState.WALKING:
			return state == PlayerState.IDLE
		PlayerState.BUFFERING_JUMP:
			return state != PlayerState.JUMPING
		PlayerState.JUMPING:
			return state != PlayerState.FALLING
		PlayerState.FALLING:
			return state != PlayerState.BUFFERING_JUMP
		_:
			return true


func _physics_process(delta: float) -> void:
	# Jump states
	if Input.is_action_just_pressed("ui_accept"):
		transition_to(PlayerState.BUFFERING_JUMP)
	if state == PlayerState.BUFFERING_JUMP:
		_jump_buffer_timer -= delta
		if _jump_buffer_timer <= 0 and prev_state != -1:
			transition_to(prev_state)
	
	# Walk states
	if Input.get_axis("ui_left", "ui_right"):
		transition_to(PlayerState.WALKING)


func idle() -> void:
	transition_to(PlayerState.IDLE)


func fall() -> void:
	transition_to(PlayerState.FALLING)


func jump() -> void:
	transition_to(PlayerState.JUMPING)


func is_buffering_jump() -> bool:
	return state == PlayerState.BUFFERING_JUMP


func get_gravity_multiplier() -> float:
	match state:
		PlayerState.BUFFERING_JUMP, PlayerState.JUMPING:
			return 1.0
		PlayerState.FALLING:
			return 1.5
		_:
			return 0.0
