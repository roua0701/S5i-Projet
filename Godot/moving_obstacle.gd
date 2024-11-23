extends CSGBox3D

enum orientation { Forward , Sides }
@export var speed = 0.5
@export var Type:orientation = orientation.Forward

var initialPos
var directionVector:Vector3
@export var maxOffset = 50
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialPos = position
	if (Type == orientation.Sides):
		directionVector = Vector3.FORWARD
	elif (Type == orientation.Forward):
		directionVector = Vector3.LEFT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Type == orientation.Sides):
		if (position.z >= (initialPos.z + maxOffset)):
			speed = -speed
		elif (position.z <= (initialPos.z - maxOffset)):
			speed = -speed
	elif (Type == orientation.Forward):
		if (position.x >= (initialPos.x + maxOffset)):
			speed = -speed
		elif (position.x <= (initialPos.x - maxOffset)):
			speed = -speed
	
	translate(directionVector * delta * speed)
