extends Node3D

var vector
@export var currentSpeed: float
@export var desiredSpeed: float
var acceleration = 0.7
var friction = 0.9
var maxSpeed = 0.5

var wheel_base = 0.13
var desiredSteering = 0
var steeringSpeed = 4
var steering_angle = PI/6
var steer_direction: float

var capteurCD: RayCast3D
var capteurCG: RayCast3D
var capteurC: RayCast3D
var capteurG: RayCast3D
var capteurD: RayCast3D
var capteurOB: RayCast3D

var thonking

@export var movement_vector: Vector3 = Vector3.ZERO
@export var is_manual_control: bool = true

var avoidingObstacle = false
var step = 0
var twoLastStates = [null, null]
var courseEnded: bool = false
var lineNotFound: bool = true

var jsonSensorReadFilePath = "/home/pi/sensors.json"
var jsonSensorWriteFilePath = "/home/pi/godot_out.json"
var lastJsonData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	capteurCD = $Capteurs/capteur1
	capteurCG = $Capteurs/capteur2
	capteurC = $Capteurs/capteur3
	capteurG = $Capteurs/capteur5
	capteurD = $Capteurs/capteur4
	capteurOB = $Capteurs/capteurOb
	#thonkingLabel = $thonkingText

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float):
	if is_manual_control:
		get_input()
	else:
		print("thonking:", thonking)
		if getJsonObstacleInfo() < 15 && getJsonObstacleInfo() != 0 || avoidingObstacle:
			avoidObstacle()
			steer_direction = lerp(steer_direction, desiredSteering * steering_angle, steeringSpeed * delta)
		elif !avoidingObstacle:
			lineFollower()
			#followbackwards()
			steer_direction = lerp(steer_direction, desiredSteering * steering_angle, steeringSpeed * delta)
	calculate_steering(delta)
	calculate_acceleration(delta)
	saveState()
	
	movement_vector = Vector3.FORWARD * currentSpeed
	
	translate(movement_vector * delta)

func get_input():
	var drive_input := Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT) - Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT)
	var turn_input := Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	steer_direction = turn_input * steering_angle
	desiredSpeed = drive_input
	
func calculate_acceleration(delta):
	if (desiredSpeed != 0):
		currentSpeed = lerp(currentSpeed, desiredSpeed * maxSpeed, acceleration * delta)
	else:
		currentSpeed = lerp(currentSpeed, desiredSpeed, friction * delta)
	
	# Check if currentSpeed is close enough to the desired speed
	if abs(currentSpeed - desiredSpeed * maxSpeed) < 0.01:  # Adjust the threshold as needed
		currentSpeed = desiredSpeed * maxSpeed

func calculate_steering(delta):
	var rear_wheel = position - Vector3(0,0,(wheel_base / 2))
	var front_wheel = position + Vector3(0,0,(wheel_base / 2))
	rear_wheel += movement_vector * delta
	front_wheel += movement_vector.rotated(Vector3.UP, steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	#movement_vector = new_heading * movement_vector

	rotate(Vector3.UP, tan(new_heading.x/new_heading.z))

func setDesiredSpeed(_desiredSpeed: float):
	desiredSpeed = _desiredSpeed

func setDesiredSteering(_desiredSteering: float):
	desiredSteering = _desiredSteering
	#if !avoidingObstacle:
		#if (desiredSteering > 0):
			#setThonking("🫨")
		#elif(desiredSteering < 0):
			#setThonking("🫨")
		#else:
			#setThonking("🙂")

func getCapteurInfo():
	var info = [capteurG.is_colliding(), 
				capteurCG.is_colliding(), 
				capteurC.is_colliding(),
				capteurCD.is_colliding(),
				capteurD.is_colliding()]
	return info

func getCapteurObstacleInfo():
	if capteurOB.is_colliding():
		var collision_point = capteurOB.get_collision_point()
		var distance = (position - collision_point).length()
		return distance
	else:
		return 0

func getJsonObstacleInfo():
	return getJsonInfo().get("distance")

func getJsonLineInfo():
	var lineData = getJsonInfo().get("line")
	var info = []
	
	for i in range(lineData.size()):
		if lineData[(lineData.size()- 1) - i] < 70:
			info.insert(0, true)
		else:
			info.insert(0, false)
	return info

func getJsonInfo():
	var json_as_text = FileAccess.get_file_as_string(jsonSensorReadFilePath)
	var json_as_dict = JSON.parse_string(json_as_text)
	if (json_as_dict == null):
		return lastJsonData
		
	lastJsonData = json_as_dict
	return json_as_dict

func lineFollower():
	var info = getJsonLineInfo()

	print("line:", info)
	
	twoLastStates.insert(0, info)
	if twoLastStates.size() > 3:
		twoLastStates.pop_back()
	
	if !courseEnded:
		#cas ou la ligne est au milieu
		if (info == [false, false, true, false, false]):
			setDesiredSpeed(0.45)
			setDesiredSteering(0)
			lineNotFound = false
			
		#cas ou on se prepare a entrer dans une courbe vers la gauche
		elif (info == [false, true, true, false, false]):
			setDesiredSpeed(0.3)
			setDesiredSteering(-0.25)
			lineNotFound = false
			
		#cas ou on commence la courbe vers la gauche
		elif (info == [false, true, false, false, false]):
			setDesiredSpeed(0.3)
			setDesiredSteering(-0.5)
			lineNotFound = false
		
		#cas ou on prepare le gros virage dans la courbe vers la gauche
		elif (info == [true, true, false, false, false]):
			setDesiredSpeed(0.2)
			setDesiredSteering(-0.75)
			lineNotFound = false
			
		#cas ou on est dans la courbe vers la gauche
		elif (info == [true, false, false, false, false]):
			setDesiredSpeed(0.2)
			setDesiredSteering(-1)
			lineNotFound = false
			
		#cas ou on se prepare a entrer dans une courbe vers la droite
		elif (info == [false, false, true, true, false]):
			setDesiredSpeed(0.3)
			setDesiredSteering(0.25)
			lineNotFound = false
		
		#cas ou on prepare le gros virage dans la courbe vers la droite
		elif (info == [false, false, false, true, true]):
			setDesiredSpeed(0.2)
			setDesiredSteering(0.75)
			lineNotFound = false
		
		#cas ou on commence la courbe vers la droite
		elif (info == [false, false, false, true, false]):
			setDesiredSpeed(0.3)
			setDesiredSteering(0.5)
			lineNotFound = false
		
		#cas ou on est dans la courbe vers la droite
		elif (info == [false, false, false, false, true]):
			setDesiredSpeed(0.2)
			setDesiredSteering(1)
			lineNotFound = false
		
		elif (info == [false, false, false, false, false] && lineNotFound):
			setDesiredSpeed(0.2)
			setDesiredSteering(0)
		
		#cas ou on a un angle droit vers la gauche
		elif (twoLastStates == [[true, true, true, false, false], [true, true, true, false, false]]):
			setDesiredSpeed(0.1)
			setDesiredSteering(-0.8)
		
		#cas ou on a un angle droit vers la droite
		elif (twoLastStates == [[false, false, true, true, true], [false, false, true, true, true]]):
			setDesiredSpeed(0.1)
			setDesiredSteering(1)
			
		# T est detecte
		elif (twoLastStates == [[true, true, false, true, true], [true, true, false, true, true], [false, false, true, false, false]]):
			setDesiredSpeed(0)
			setDesiredSteering(0)
			courseEnded = true
			setThonking("🥳")

func followbackwards():
	var info = getCapteurInfo()
	print(info)
	
	#cas ou la ligne est au milieu
	if (info == [false, false, true, false, false]):
		setDesiredSpeed(-0.45)
		setDesiredSteering(0)
		
	#cas ou on se prepare a entrer dans une courbe vers la gauche
	elif (info == [false, true, true, false, false]):
		setDesiredSpeed(-0.3)
		setDesiredSteering(0.25)
		
	#cas ou on commence la courbe vers la gauche
	elif (info == [false, true, false, false, false]):
		setDesiredSpeed(-0.3)
		setDesiredSteering(0.5)
	
	#cas ou on prepare le gros virage dans la courbe vers la gauche
	elif (info == [true, true, false, false, false]):
		setDesiredSpeed(-0.2)
		setDesiredSteering(0.75)
		
	#cas ou on est dans la courbe vers la gauche
	elif (info == [true, false, false, false, false]):
		setDesiredSpeed(-0.2)
		setDesiredSteering(1)
		
	#cas ou on se prepare a entrer dans une courbe vers la droite
	elif (info == [false, false, true, true, false]):
		setDesiredSpeed(-0.3)
		setDesiredSteering(-0.25)
	
	#cas ou on prepare le gros virage dans la courbe vers la droite
	elif (info == [false, false, false, true, true]):
		setDesiredSpeed(-0.2)
		setDesiredSteering(-0.75)
	
	#cas ou on commence la courbe vers la droite
	elif (info == [false, false, false, true, false]):
		setDesiredSpeed(-0.3)
		setDesiredSteering(-0.5)
	
	#cas ou on est dans la courbe vers la droite
	elif (info == [false, false, false, false, true]):
		setDesiredSpeed(-0.2)
		setDesiredSteering(-1)
		
	# T est detecte
	elif (info == [true, true, true, true, true]):
		setDesiredSpeed(0)
		setDesiredSteering(0)
	
	# plus sur le parcours
	elif (info == [false, false, false, false, false]):
		setDesiredSpeed(0)
		setDesiredSteering(0)
		
	elif (info == [true, true, false, true, true]):
		setDesiredSpeed(0)
		setDesiredSteering(0)

func avoidObstacle():
	avoidingObstacle = true
	
	if (step == 0):
		setThonking("🤨")
		setDesiredSpeed(0)
		await get_tree().create_timer(2).timeout
		step = 1
	elif (step == 1):
		setThonking("🫥")
		setDesiredSteering(0)
		setDesiredSpeed(-0.2)
		if (getJsonObstacleInfo() > 15):
			step = 2
	elif (step == 2):
		setThonking("🎯")
		setDesiredSpeed(0.3)
		setDesiredSteering(0.7)
		await get_tree().create_timer(3.5).timeout
		step = 3
	elif (step == 3):
		setThonking("✌️")
		setDesiredSpeed(0.3)
		setDesiredSteering(-0.25)
		if (getJsonLineInfo() != [false, false, false, false, false]):
			setDesiredSpeed(0)
			await get_tree().create_timer(0.5).timeout
			step = 0
			avoidingObstacle = false

func setThonking(_text):
	thonking = _text

func saveState():
	var dict: Dictionary
	dict["steering"] = steer_direction
	dict["speed"] = currentSpeed
	
	var file = FileAccess.open(jsonSensorWriteFilePath, FileAccess.WRITE)
	file.store_line(var_to_str(dict))
	file.close()
