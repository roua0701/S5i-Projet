extends Node3D

@export var car: Node3D
@export var isSeparate: bool
var offsetx
var offsetz 
var offsety

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	offsetx = position.x - car.position.x
	offsetz = position.z - car.position.z
	offsety = position.y - car.position.y
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (isSeparate):
		rotation_degrees.y = car.rotation_degrees.y
		position = Vector3(car.position.x + offsetx, car.position.y + offsety, car.position.z + offsetz)
