from machine import Pin
from time import sleep
import utime

# pin assignment
pin1  = Pin(6, Pin.OUT) # Pico GPIO6 connected to stepper control pin IN1
pin2  = Pin(7, Pin.OUT) # Pico GPIO7 connected to stepper control pin IN2
pin3  = Pin(8, Pin.OUT) # Pico GPIO8 connected to stepper control pin IN3
pin4  = Pin(9, Pin.OUT) # Pico GPIO9 connected to stepper control pin IN4
led   = Pin(25, Pin.OUT) # Pico LED
pins = [pin1, pin2, pin3, pin4] # pin order for forward rotation
# pinsBackward = [pin4, pin3, pin2, pin1]
phase = 0

# half step gives greater precision at the cost of less torque
switchingSequenceHalfStep = [
    [ 0, 0, 0, 1 ],
    [ 0, 0, 1, 1 ],
    [ 0, 0, 1, 0 ],
    [ 0, 1, 1, 0 ],
    [ 0, 1, 0, 0 ],
    [ 1, 1, 0, 0 ],
    [ 1, 0, 0, 0 ],
    [ 1, 0, 0, 1 ]
]

# full step gives higher torque
switchingSequenceFullStep = [
    [ 0, 0, 1, 1 ],
    [ 0, 1, 1, 0 ],
    [ 1, 1, 0, 0 ],
    [ 1, 0, 0, 1 ],
]

def rotateMotor(steps):
    global pins
    global phase
    global switchingSequenceHalfStep, switchingSequenceFullStep

    switchingSequence = switchingSequenceFullStep
    phaseCount = len(switchingSequence)

    for step in range(steps):
        #for i in range(len(pins)):
            #pins[i].value(switchingSequence[phase][i])
        for i, pin in enumerate(pins):
            pin.value(switchingSequence[phase][i])
        phase = (phase + 1) % phaseCount
        utime.sleep_ms(3) # wait between phases of stepper for smoothness, 3ms according to datasheet, was 20ms
        led.toggle()

    # switch off power
    for pin in pins:
        pin.value(0)
    led.value(0) # Pico led off

# 28BYJ-48 has 32 steps per revolution in half step mode, 16 steps per revolution in full step mode.
# Gearing is 32/9 * 22/11 * 26/9 * 31/10 = 51584 / 810,
# that is 32 * 51584 / 810 half-steps per revolution.
# The clock's minute hand is geared 1/4, so one revolution of 28BYJ-48 is 15 minutes
# so one second is 32 * 51584 / (810 * 15 * 60) = 4 * 51584 / (405 * 15 * 15) half steps,
# that is 2 * 51584 / (405 * 15 * 15) full steps.
def secondsToSteps(seconds):
    return seconds * 2 * 51584 / (405 * 15 * 15) # full steps


debug = False
tickIntervalSeconds = 60 # so hands are moved every minute
led.value(0)
for pin in pins:
    pin.value(0)
sleep(1)
startTime = utime.time()
totalStepsRotated = 0
if debug:
    print("startTime={}".format(startTime))
    print("ss(60)={}".format(secondsToSteps(60)))

# rotate 10 steps at startup, so clock does not appear dead to user
initialRotate = 10
rotateMotor(initialRotate)
totalStepsRotated += initialRotate

while True:
    timeNow = utime.time()
    elapsedTime = timeNow - startTime
    totalStepsRequired = secondsToSteps(elapsedTime)
    stepsToRotate = int(totalStepsRequired - totalStepsRotated)
    if debug:
        print("elapsedTime={}, totalStepsRequired={}, totalStepsRotated={}, stepsToRotate={}".format(elapsedTime, totalStepsRequired, totalStepsRotated, stepsToRotate))
        print("phase={}".format(phase))
    rotateMotor(stepsToRotate)
    totalStepsRotated += stepsToRotate
    toSleep = tickIntervalSeconds - (utime.time() - timeNow)
    if debug:
        print("toSleep={}".format(toSleep))
    utime.sleep(toSleep)

