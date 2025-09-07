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
			return _state == PlayerState.IDLE
		PlayerState.BUFFERING_JUMP:
			return _state != PlayerState.JUMPING
		PlayerState.JUMPING:
			return _state != PlayerState.FALLING
		PlayerState.FALLING:
			return _state != PlayerState.BUFFERING_JUMP
		_:
			return true


func _physics_process(delta: float) -> void:
	if _state == PlayerState.BUFFERING_JUMP:
		_jump_buffer_timer -= delta
		if _jump_buffer_timer <= 0 and _prev_state != -1:
			set_state(_prev_state)


func idle() -> void:
	set_state(PlayerState.IDLE)


func walk() -> void:
	set_state(PlayerState.WALKING)


func fall() -> void:
	set_state(PlayerState.FALLING)


func buffer_jump() -> void:
	set_state(PlayerState.BUFFERING_JUMP)


func jump() -> void:
	set_state(PlayerState.JUMPING)


func is_buffering_jump() -> bool:
	return _state == PlayerState.BUFFERING_JUMP


func get_gravity_multiplier() -> float:
	match _state:
		PlayerState.BUFFERING_JUMP, PlayerState.JUMPING:
			return 1.0
		PlayerState.FALLING:
			return 1.5
		_:
			return 0.0
