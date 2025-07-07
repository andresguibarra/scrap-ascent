class_name StateMachine extends Node

signal state_changed()

@export var initial_state: Node = null

@onready var state: Node = (func get_initial_state() -> Node:
	return initial_state if initial_state != null else get_child(0)
).call()

func _ready() -> void:
	for state_node in get_children():
		if state_node.has_signal("finished"):
			state_node.finished.connect(_transition_to_next_state)
	
	# Wait for owner to be ready before entering initial state
	if owner:
		await owner.ready
	
	# Initialize state
	if state:
		print("StateMachine: Entering initial state: ", state.name)
		state.enter("")
	else:
		print("StateMachine ERROR: No initial state found")

func _unhandled_input(event: InputEvent) -> void:
	if state:
		state.handle_input(event)

func _process(delta: float) -> void:
	if state:
		state.update(delta)

func _physics_process(delta: float) -> void:
	if state:
		state.physics_update(delta)

func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return
	
	if not state:
		printerr(owner.name + ": No current state to exit from.")
		return
	
	var previous_state_path: String = state.name
	print("StateMachine: Transitioning from ", previous_state_path, " to ", target_state_path)
	
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)
	state_changed.emit()

func transition_to(target_state_path: String, data: Dictionary = {}) -> void:
	_transition_to_next_state(target_state_path, data)
