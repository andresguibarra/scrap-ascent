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
		var state_display = _format_state_name(state.name)
		print_rich("[color=cyan]🚀 StateMachine:[/color] [color=lime]Entering initial state:[/color] [color=yellow]%s[/color]" % state_display)
		state.enter("")
	else:
		print_rich("[color=red]❌ StateMachine ERROR:[/color] [color=white]No initial state found[/color]")

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
	var from_display = _format_state_name(previous_state_path)
	var to_display = _format_state_name(target_state_path)
	print_rich("[color=cyan]🔄 StateMachine:[/color] [color=yellow]%s[/color] → [color=yellow]%s[/color]" % [from_display, to_display])
	
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)
	state_changed.emit()

func _format_state_name(state_name: String) -> String:
	# Remove "State" suffix if present
	var clean_name = state_name.replace("State", "")
	
	# Handle different state types with emojis and colors
	if clean_name.begins_with("Controlled"):
		var action = clean_name.replace("Controlled", "")
		return _get_controlled_state_display(action)
	elif clean_name.begins_with("AI"):
		var action = clean_name.replace("AI", "")
		return _get_ai_state_display(action)
	elif clean_name.begins_with("Inert"):
		var action = clean_name.replace("Inert", "")
		return _get_inert_state_display(action)
	else:
		return "[color=white]❓ %s[/color]" % clean_name

func _get_controlled_state_display(action: String) -> String:
	match action:
		"Idle":
			return "[color=gray]🪨 Idle[/color]"
		"Move":
			return "[color=yellow]🏃 Move[/color]"
		"Jump":
			return "[color=lime]⬆️ Jump[/color]"
		"DoubleJump":
			return "[color=lime]⬆️⬆️ DoubleJump[/color]"
		"Fall":
			return "[color=gray]⬇️ Fall[/color]"
		"Dash":
			return "[color=lightblue]💨 Dash[/color]"
		"WallSlide":
			return "[color=orange]🧗 WallSlide[/color]"
		"JustLeftWallSlide":
			return "[color=orange]🕐 JustLeftWallSlide[/color]"
		_:
			return "[color=lime]🎮 %s[/color]" % action

func _get_ai_state_display(action: String) -> String:
	match action:
		"Idle":
			return "[color=orange]🤖 Idle[/color]"
		"Move":
			return "[color=orange]🤖 Move[/color]"
		"Jump":
			return "[color=orange]🤖 Jump[/color]"
		"Fall":
			return "[color=orange]🤖 Fall[/color]"
		_:
			return "[color=orange]🤖 %s[/color]" % action

func _get_inert_state_display(action: String) -> String:
	match action:
		"Idle":
			return "[color=gray]💀 Idle[/color]"
		"Fall":
			return "[color=gray]💀 Fall[/color]"
		_:
			return "[color=gray]💀 %s[/color]" % action

func transition_to(target_state_path: String, data: Dictionary = {}) -> void:
	_transition_to_next_state(target_state_path, data)
