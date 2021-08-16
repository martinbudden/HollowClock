from machine import Pin
from time import sleep
import utime


class Stepper_Motor_28BYJ_48:
    """Represents a 28BYJ-48 geared stepper motor."""

    # The 28BYJ-48 has 32 full steps per revolution (so 64 half-steps per revolution).
    # Gearing is 32/9 * 22/11 * 26/9 * 31/10 = 51584 / 810 = 25792 / 405 (= 63.68395 ~ 64).
    # So there are 32 * 25792 / 405 (=2037.8864 ~ 2038) full steps per revolution.
    STEPS_PER_REVOLUTION = 32
    GEAR_NUMERATOR = 25792
    GEAR_DENOMINATOR = 405

    # half step gives greater precision at the cost of less torque
    SWITCHING_SEQUENCE_HALF_STEP = [
        [ 1, 0, 0, 0 ],
        [ 1, 1, 0, 0 ],
        [ 0, 1, 0, 0 ],
        [ 0, 1, 1, 0 ],
        [ 0, 0, 1, 0 ],
        [ 0, 0, 1, 1 ],
        [ 0, 0, 0, 1 ],
        [ 1, 0, 0, 1 ]
    ]

    # full step gives higher torque
    SWITCHING_SEQUENCE_FULL_STEP = [
        [ 1, 1, 0, 0 ],
        [ 0, 1, 1, 0 ],
        [ 0, 0, 1, 1 ],
        [ 1, 0, 0, 1 ],
    ]

    def __init__(self, pins, led, debug=False, powerSaving=False):
        self.pins = pins
        self.led = led
        self.debug = debug
        self.powerSaving = powerSaving
        self._switchingSequence = self.SWITCHING_SEQUENCE_FULL_STEP
        self._phaseCount = len(self._switchingSequence)
        self._phase = 0
        self.timeBetweenStepsMs = 10 # minimum before skipping steps = 3ms
        self.led.value(0)
        for pin in self.pins:
            pin.value(0)

    def rotate(self, steps):
        """Rotate the motor the given number of steps."""
        if self.debug:
            print("phase1={}".format(self._phase))
        for step in range(abs(steps)):
            if steps < 0:
                self._phase = (self._phase - 1) % self._phaseCount
            if self.debug:
                switchingSequence = self._switchingSequence[self._phase]
                print("pins=[{},{},{},{}]".format(switchingSequence[0], switchingSequence[1], switchingSequence[2], switchingSequence[3]))
            for i, pin in enumerate(self.pins):
                pin.value(self._switchingSequence[self._phase][i])
            if steps > 0:
                self._phase = (self._phase + 1) % self._phaseCount
            utime.sleep_ms(self.timeBetweenStepsMs)
            self.led.toggle()
        self.led.value(0) # Pico led off
        if self.debug:
            print("phase2={}".format(self._phase))
        # An attempt to save power by switching off motor between ticks.
        # Unfortunately if anything binds during a tick then when power is turned off
        # it may spring back, thus loosing steps.
        if self.powerSaving:
            for pin in self.pins:
                pin.value(0)

    def revolutionsToSteps(self, revolutions):
        """Return the number of steps required for the number of revolutions specified."""
        return revolutions * self.STEPS_PER_REVOLUTION * self.GEAR_NUMERATOR / self.GEAR_DENOMINATOR


# The clock's minute hand is geared 1/4, so one revolution of the 28BYJ-48 is 15 minutes, 15*60 seconds.
# So one second is 1 / (15 * 60) revolutions.
def secondsToSteps(stepper, seconds):
    """Return the number of steps required to advance the clock the given number of seconds."""
    return stepper.revolutionsToSteps(seconds) / (15 * 60)


def main():
    # pin assignment
    PIN_A = Pin(6, Pin.OUT) # Pico GPIO6 connected to stepper control pin IN1
    PIN_B = Pin(7, Pin.OUT) # Pico GPIO7 connected to stepper control pin IN2
    PIN_C = Pin(8, Pin.OUT) # Pico GPIO8 connected to stepper control pin IN3
    PIN_D = Pin(9, Pin.OUT) # Pico GPIO9 connected to stepper control pin IN4
    LED = Pin(25, Pin.OUT) # Pico LED

    PINS = [PIN_A, PIN_B, PIN_C, PIN_D] # pin order for clockwise rotation

    stepper = Stepper_Motor_28BYJ_48(PINS, LED, debug=False, powerSaving=False)
    sleep(1) # allow Pico to initialise
    startTime = utime.time()
    tickIntervalSeconds = 10 # so hands are moved every 10 seconds
    totalStepsRotated = 0
    if stepper.debug:
        print("startTime={}".format(startTime))
        print("ss(60)={}".format(secondsToSteps(stepper, 60)))

    # rotate 10 steps at startup, so clock does not appear dead to user
    #initialRotate = 10
    #rotateMotor(initialRotate)
    #totalStepsRotated += initialRotate

    while True:
        timeNow = utime.time()
        elapsedTime = timeNow - startTime
        totalStepsRequired = secondsToSteps(stepper, elapsedTime)
        stepsToRotate = int(totalStepsRequired - totalStepsRotated)
        if stepper.debug:
            print("elapsedTime={}, totalStepsRequired={}, totalStepsRotated={}, stepsToRotate={}".format(elapsedTime, totalStepsRequired, totalStepsRotated, stepsToRotate))
        stepper.rotate(stepsToRotate)
        totalStepsRotated += stepsToRotate
        toSleep = tickIntervalSeconds - (utime.time() - timeNow)
        if stepper.debug:
            print("toSleep={}".format(toSleep))
        utime.sleep(toSleep)


if __name__ == "__main__":
    main()
