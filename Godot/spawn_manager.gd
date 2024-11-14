extends Node3D

@export var car: Node3D
@export var bille: RigidBody3D
@export var carSpawnPoint: Node3D
@export var billeSpawnPoint: Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed('ui_accept'):
		car.desiredSpeed = 0
		car.currentSpeed = 0
		car.movement_vector = Vector3.ZERO
		car.position = carSpawnPoint.position
		car.rotation = carSpawnPoint.rotation
		bille.linear_velocity = Vector3.ZERO
		bille.position = billeSpawnPoint.position
