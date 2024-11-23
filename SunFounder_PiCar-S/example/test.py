import Ultrasonic as u
import Kalman as k
import json
from SunFounder_Line_Follower import Line_Follower
import time
import numpy as np
from picar import front_wheels
from picar import back_wheels
import picar

picar.setup()

u.setup()
lf = Line_Follower.Line_Follower()
dic = {}
N = 10
buffer = []
drivingDataPath = "/home/pi/godot_out.json"
lastDrivingData = {"steering": 0, "speed": 0}
drivingData = {}
fw = front_wheels.Front_Wheels(db='config')
bw = back_wheels.Back_Wheels(db='config')
fw.ready()
bw.ready()
fw.turning_max = 45
try:
	while True:
		fi = open(drivingDataPath)
		try:
			drivingData = json.load(fi)
		except Exception:
			drivingData = lastDrivingData
			print("error caught: OH SHIT!!!!!!!!!!!")
		lastDrivingData = drivingData
		fw.turn(int(90 + (drivingData["steering"]*45)))
		if drivingData["speed"] < 0:
			bw.forward()
			bw.speed = int((-drivingData["speed"]+0.3)*100)
		else:
			bw.backward()
			bw.speed = int((drivingData["speed"]+0.3)*100)
		print("STEERING: ", int((drivingData["speed"]+0.3)*100))
		#print("steering: ", drivingData["steering"], "speed: ", drivingData["speed"])
		buffer.insert(0, u.dist())
		if len(buffer) > N:
			buffer.pop()

		dic["distance"] = np.mean(buffer)
		#print("distance:", dic["distance"])
		#print(k.kalman_single_measurement(dic["distance"]))
		dic["line"] = lf.read_analog()
		with open("/home/pi/sensors.json", "w") as f:
			json.dump(dic, f)

except KeyboardInterrupt:
	print("Mesure arrete")
finally:
	bw.speed = 0
	fw.turn_straight()
	u.cleanup()
