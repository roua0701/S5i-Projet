from SunFounder_Line_Follower import Line_Follower
from Ultrasonic import Ultrasonic
import time

lf = Line_Follower.Line_Follower()
while True:
	print(lf.read_analog())
	print(lf.read_digital())
	print('')
	time.sleep(0.5)

