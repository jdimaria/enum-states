class_name EnumFSM extends Node


signal state_changed(from: int, to: int)
signal state_entered(state: int)
signal state_exited(state: int)

@export var push_warnings: bool = true

var _states: Array[int]
var state: int:
	set(val):
		transition_to(val)


#region Internal State Methods
func _enter(enter_state: int) -> bool:
	return true


func _exit(exit_state: int) -> bool:
	return true


func _is_valid_transition(to: int) -> bool:
	return to != state
#endregion


#region Public State Methods
func start(states: Array[int], initial_state: int = 0) -> void:
	if not states:
		push_error("Empty or nil states array passed to EnumFSM.start()!")
		return
	state = initial_state


func transition_to(to: int) -> bool:
	if not _is_valid_transition(to):
		if push_warnings:
			push_warning("Invalid state transition from %d to %d" % [state, to])
		return false
		
	var from := state
	
	if _exit(from):
		state_exited.emit(from)
	else:
		push_error("Error exiting state: %d" % from)
		return false
	if _enter(to):
		state_entered.emit(to)
	else:
		push_error("Error entering state: %d" % to)
		return false
	
	state = to
	state_changed.emit(from, to)
	
	return true
#endregion
