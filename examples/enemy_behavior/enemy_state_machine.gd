class_name EnemyStateMachine extends EnumStateMachine


enum State {
	IDLE,
	PATROLLING,
	ALERT,
	CHASING
}

@export var patrol_radius: float = 256.0
@export var patrol_time_min: float = 1.5
@export var patrol_time_max: float = 3.0
var _patrol_direction: Vector2
var _patrol_origin: Vector2
var _patrol_timer: float

@export var alert_time: float = 1.5
var _alert_timer: float

@export var chase_time: float = 4.5
var _chase_timer: float


func _init() -> void:
	_states = State


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent = get_parent()
	if parent is Node2D:
		_patrol_origin = parent.global_position


func _enter(enter_state: int) -> bool:
	match enter_state:
		State.IDLE:
			_patrol_timer = randf_range(patrol_time_min, patrol_time_max)
			return _patrol_timer != 0
		State.PATROLLING:
			var patrol_x := randf_range(-1.0, 1.0) * patrol_radius
			var patrol_y := randf_range(-1.0, 1.0) * patrol_radius
			_patrol_direction = _patrol_origin + Vector2(patrol_x, patrol_y)
			return true
		State.ALERT:
			_alert_timer = alert_time
			return _alert_timer != 0
		State.CHASING:
			_chase_timer = chase_time
			return _chase_timer != 0
		_:
			return true


func _exit(exit_state: int) -> bool:
	match exit_state:
		State.IDLE:
			_patrol_timer = 0
			return true
		State.PATROLLING:
			_patrol_direction = Vector2.ZERO
			return true
		State.ALERT:
			_alert_timer = 0
			return true
		State.CHASING:
			_chase_timer = 0
			return true
		_:
			return true


func _is_valid_transition(to: int) -> bool:
	if not super(to):
		return false
	match to:
		State.IDLE:
			return _state == State.PATROLLING or _state == State.ALERT
		State.PATROLLING:
			return _state == State.IDLE or _state == State.ALERT
		State.ALERT:
			return true
		State.CHASING:
			return true
		_:
			return true


func _physics_process(delta: float) -> void:
	match _state:
		State.IDLE:
			_patrol_timer -= delta
			if _patrol_timer <= 0:
				set_state(State.PATROLLING)
		State.ALERT:
			_alert_timer -= delta
			if _alert_timer <= 0:
				set_state(State.IDLE)
		State.CHASING:
			_chase_timer -= delta
			if _chase_timer <= 0:
				set_state(State.ALERT)


## Transition to [enum State].ALERT or reset alert timer if already alert
func alert() -> bool:
	if _state != State.ALERT:
		return set_state(State.ALERT)
	
	_alert_timer = alert_time
	return true


## Transition to [enum State].CHASING or reset chase timer if already chasing
func chase() -> bool:
	if _state != State.CHASING:
		return set_state(State.CHASING)
	
	_chase_timer = chase_time
	return true


func is_alert() -> bool: return _state == State.ALERT


func get_patrol_direction() -> Vector2: return _patrol_direction


func get_patrol_origin() -> Vector2: return _patrol_origin
