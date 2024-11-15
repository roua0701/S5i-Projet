import RPi.GPIO as GPIO
import time

SIG = 20  # Utilise le numero de broche GPIO pour SIG (adapte pour le Raspberry Pi)
def setup():
	GPIO.setmode(GPIO.BCM)  # Utilise le mode BCM pour les numeros de broche
	GPIO.setup(SIG, GPIO.OUT)

def cleanup():
	GPIO.cleanup()

def pulse_in(pin, level, timeout=1.0):
    start_time = time.time()
    while GPIO.input(pin) != level:
        if time.time() - start_time > timeout:
            return 0
    start_pulse = time.time()
    while GPIO.input(pin) == level:
        if time.time() - start_pulse > timeout:
            return 0
    end_pulse = time.time()
    return end_pulse - start_pulse

def measure_distance():
    # Configure SIG en sortie pour envoyer le signal de declenchement
    GPIO.setup(SIG, GPIO.OUT)

    # Envoie le signal de declenchement
    GPIO.output(SIG, GPIO.HIGH)
    time.sleep(0.00002)  # Pulse de 20mus
    GPIO.output(SIG, GPIO.LOW)

    # Configure SIG en entree pour lire le signal de retour
    GPIO.setup(SIG, GPIO.IN)

    # Calcule la duree du signal et la distance
    # elapsed_time = stop_time - start_time
    elapsed_time = pulse_in(SIG, GPIO.HIGH, timeout=0.04)
    distance = (elapsed_time * 34300) / 2  # Convertit le temps en distance en cm

    # Limite la distance entre 2 et 800 cm
    if distance < 2 or distance > 800:
        distance = 0
    return distance

def dist():
    setup()
    distance = measure_distance()
    distance += measure_distance()
    print('distance', distance, 'cm')
    return distance

