extends Node3D
@export var cams: Array[Camera3D]
var index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event):
	if Input.is_action_just_pressed("next"):
		index = (index + 1) % len(cams)
		cams[index].make_current()
	elif Input.is_action_just_pressed("last"):
		index = (index - 1) % len(cams)
		cams[index].make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
