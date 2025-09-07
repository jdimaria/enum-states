class_name EnumStateMachine extends Node


signal state_changed(from: int, to: int)
signal state_entered(state: int)
signal state_exited(state: int)

@export var push_warnings: bool

var _states: Dictionary
var prev_state: int = -1
var state: int:
	set(to):
		var from := state
		if _try_transition(to):
			prev_state = from
			state = to
			state_changed.emit(from, to)


func _init() -> void:
	push_error("EnumStateMachine._init() should be overriden to assign '_states' to a named enum")


#region Internal State Methods
func _enter(enter_state: int) -> bool:
	return true


func _exit(exit_state: int) -> bool:
	return true


func _is_valid_transition(to: int) -> bool:
	if to < 0 or to >= _states.size():
		push_error("State %d is out of bounds" % to)
		return false
	return to != state


func _try_transition(to: int) -> bool:
	if not _is_valid_transition(to):
		if push_warnings and state != to:
			push_warning("Invalid state transition from %s to %s" % [get_state_name(state), get_state_name(to)])
		return false
		
	var from := state
	
	if _exit(from):
		state_exited.emit(from)
	else:
		push_error("Error exiting state: %s" % get_state_name(from))
		return false
	if _enter(to):
		state_entered.emit(to)
	else:
		push_error("Error entering state: %s" % get_state_name(to))
		return false
	return true
#endregion


#region Public State Methods
func get_state_name(state_idx: int = state) -> String:
	if state_idx >= 0 and state_idx < _states.size():
		return _states.keys()[state_idx]
	return ""


func start(initial_state: int = 0) -> void:
	state = initial_state


func transition_to(to: int) -> bool:
	state = to
	return prev_state != state
#endregion
