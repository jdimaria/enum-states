class_name Enemy extends CharacterBody2D


@onready var area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var shape_cast: ShapeCast2D = $ShapeCast2D
@onready var esm: EnemyStateMachine = $EnemyStateMachine

@export var turn_speed: float = 0.5
@export var move_speed: float = 200
@export var chase_speed: float = 300

var _tween: Tween


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	esm.state_entered.connect(_on_state_entered)


func _on_body_entered(body: Node2D) -> void:
	esm.alert()
	_turn_toward(body.global_position)


func _on_state_entered(state: EnemyStateMachine.State) -> void:
	match state:
		EnemyStateMachine.State.IDLE:
			if global_position != esm.get_patrol_origin():
				_turn_toward(esm.get_patrol_origin())
		EnemyStateMachine.State.PATROLLING:
			if global_position != esm.get_patrol_direction():
				_turn_toward(esm.get_patrol_direction())


func _physics_process(delta: float) -> void:
	if shape_cast.is_colliding() and esm.chase():
		velocity = velocity.move_toward(shape_cast.get_collision_point(0), chase_speed * delta)
		move_and_slide()
		return
	
	match esm.get_state():
		EnemyStateMachine.State.IDLE:
			if global_position != esm.get_patrol_origin():
				velocity = velocity.move_toward(esm.get_patrol_origin(), move_speed * delta)
			else:
				_survey()
		EnemyStateMachine.State.PATROLLING:
			if global_position != esm.get_patrol_direction():
				velocity = velocity.move_toward(esm.get_patrol_direction(), move_speed * delta)
			else:
				_survey()
		EnemyStateMachine.State.CHASING:
			# Lost track of player during chase
			_survey()
	
	move_and_slide()


func _survey() -> void:
	_turn_toward(global_position.rotated(randf_range(-PI, PI)))


func _turn_toward(direction: Vector2) -> void:
	if _tween:
		if _tween.get_meta("state", -1) != esm.get_state():
			_tween.kill()
		else:
			return
	
	_tween = create_tween().parallel()
	_tween.set_meta("state", esm.get_state())
	_turn_node(sprite, direction)
	_turn_node(shape_cast, direction)


func _turn_node(node: Node2D, direction: Vector2) -> void:
	var angle_to := node.get_angle_to(direction)
	_tween.tween_method(node.rotate, node.rotation, angle_to, turn_speed * abs(angle_to / TAU))
