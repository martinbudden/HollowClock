from machine import Pin
from time import sleep
import utime

# pin assignment
PIN_A = Pin(6, Pin.OUT) # Pico GPIO6 connected to stepper control pin IN1
PIN_B = Pin(7, Pin.OUT) # Pico GPIO7 connected to stepper control pin IN2
PIN_C = Pin(8, Pin.OUT) # Pico GPIO8 connected to stepper control pin IN3
PIN_D = Pin(9, Pin.OUT) # Pico GPIO9 connected to stepper control pin IN4
LED = Pin(25, Pin.OUT) # Pico LED
PINS_CLOCKWISE = [PIN_D, PIN_C, PIN_B, PIN_A] # pin order for clockwise rotation
# PINS_ANTI_CLOCKWISE = [PIN_A, PIN_B, PIN_C, PIN_D]
phase = 0

# half step gives greater precision at the cost of less torque
SWITCHING_SEQUENCE_HALF_STEP = [
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
SWITCHING_SEQUENCE_FULL_STEP = [
    [ 0, 0, 1, 1 ],
    [ 0, 1, 1, 0 ],
    [ 1, 1, 0, 0 ],
    [ 1, 0, 0, 1 ],
]

def rotateMotor(steps):
    global PINS_CLOCKWISE
    global phase
    global SWITCHING_SEQUENCE_HALF_STEP, SWITCHING_SEQUENCE_FULL_STEP
    global powerSaving

    switchingSequence = SWITCHING_SEQUENCE_FULL_STEP
    pins = PINS_CLOCKWISE
    phaseCount = len(switchingSequence)

    if debug:
        print("phase1={}".format(phase))
    for step in range(steps):
        #for i in range(len(pins)):
        #    pins[i].value(switchingSequence[phase][i])
        if debug:
            print("pins=[{},{},{},{}]".format(switchingSequence[phase][0],switchingSequence[phase][1],switchingSequence[phase][2],switchingSequence[phase][3]))
        for i, pin in enumerate(pins):
            pin.value(switchingSequence[phase][i])
        phase = (phase + 1) % phaseCount
        utime.sleep_ms(10) # wait between phases of stepper for smoothness, 3ms according to datasheet, was 20ms
        LED.toggle()
    if debug:
        print("phase2={}".format(phase))

    # An attempt to save power by switching off motor between ticks.
    # Unfortunately if anything binds during a tick then when power is turned off
    # it may spring back, thus loosing steps.
    if powerSaving:
        for pin in pins:
            pin.value(0)
    LED.value(0) # Pico led off

# The 28BYJ-48 has 32 full steps per revolution, alternatively 64 half-steps per revolution.
# Gearing is 32/9 * 22/11 * 26/9 * 31/10 = 51584 / 810 = 25792 / 405 (= 63.68395).
# So there are is 32 * 25792 / 405 (=2037.8864 ~ 2038) full steps per revolution.
# The clock's minute hand is geared 1/4, so one revolution of 28BYJ-48 is 15 minutes, 15*60 seconds.
# so one second is 32 * 25792 / (405 * 15 * 60) = 8 * 25792 / (405 * 15 * 15) full steps,
# that is 8 * 51584 / (405 * 15 * 15) half steps.
GEAR_NUMERATOR = 25792
GEAR_DENOMINATOR = 405
def secondsToSteps(seconds):
    return seconds * 8 * GEAR_NUMERATOR / (GEAR_DENOMINATOR * 15 * 15) # full steps


debug = False
powerSaving = False
tickIntervalSeconds = 10 # so hands are moved every 10 seconds
LED.value(0)
for pin in PINS_CLOCKWISE:
    pin.value(0)
sleep(1)
startTime = utime.time()
totalStepsRotated = 0
if debug:
    print("startTime={}".format(startTime))
    print("ss(60)={}".format(secondsToSteps(60)))

# rotate 10 steps at startup, so clock does not appear dead to user
#initialRotate = 10
#rotateMotor(initialRotate)
#totalStepsRotated += initialRotate

while True:
    timeNow = utime.time()
    elapsedTime = timeNow - startTime
    totalStepsRequired = secondsToSteps(elapsedTime)
    stepsToRotate = int(totalStepsRequired - totalStepsRotated)
    #if debug:
     #   print("elapsedTime={}, totalStepsRequired={}, totalStepsRotated={}, stepsToRotate={}".format(elapsedTime, totalStepsRequired, totalStepsRotated, stepsToRotate))
    rotateMotor(stepsToRotate)
    totalStepsRotated += stepsToRotate
    toSleep = tickIntervalSeconds - (utime.time() - timeNow)
    if debug:
        print("toSleep={}".format(toSleep))
    utime.sleep(toSleep)
