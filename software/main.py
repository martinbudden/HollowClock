from time import sleep
from machine import Pin
import utime
from micropython import const


class Stepper_Motor_28BYJ_48:
    """A 28BYJ-48 geared stepper motor."""

    # The 28BYJ-48 has 32 full steps per revolution (so 64 half-steps per revolution).
    # Gearing is 32/9 * 22/11 * 26/9 * 31/10 = 51584 / 810 = 25792 / 405 (= 63.68395 ~ 64).
    # So there are 32 * 25792 / 405 (=2037.8864 ~ 2038) full steps per revolution.
    # See https://lastminuteengineers.com/28byj48-stepper-motor-arduino-tutorial/
    STEPS_PER_REVOLUTION = const(32)
    GEAR_NUMERATOR = const(25792)
    GEAR_DENOMINATOR = const(405)
    GEARED_STEPS_PER_REVOLUTION = const(2048)

    # half step gives greater precision at the cost of less torque
    SWITCHING_SEQUENCE_HALF_STEP = (
        (1, 0, 0, 0),
        (1, 1, 0, 0),
        (0, 1, 0, 0),
        (0, 1, 1, 0),
        (0, 0, 1, 0),
        (0, 0, 1, 1),
        (0, 0, 0, 1),
        (1, 0, 0, 1),
    )

    # full step gives higher torque
    SWITCHING_SEQUENCE_FULL_STEP = (
        (1, 1, 0, 0),
        (0, 1, 1, 0),
        (0, 0, 1, 1),
        (1, 0, 0, 1),
    )

    def __init__(self, pins, led=None):
        self.pins = pins
        self.led = led
        self._switchingSequence = self.SWITCHING_SEQUENCE_FULL_STEP
        self._phaseCount = len(self._switchingSequence)
        self._phase = 0
        self.totalStepsRotated = 0
        self.timeBetweenStepsMs = 10  # minimum before skipping steps = 3ms
        self.led.value(0)
        for pin in self.pins:
            pin.value(0)

    def rotate(self, steps, debug=False):
        """Rotate the motor the given number of steps."""
        if debug:
            print("phase1=", self._phase)
        for _ in range(abs(steps)):
            if steps < 0:
                self._phase = (self._phase - 1) % self._phaseCount
            if debug:
                print("pins=", self._switchingSequence[self._phase])
            for i, pin in enumerate(self.pins):
                pin.value(self._switchingSequence[self._phase][i])
            if steps > 0:
                self._phase = (self._phase + 1) % self._phaseCount
            utime.sleep_ms(self.timeBetweenStepsMs)
            if self.led is not None:
                self.led.toggle()
        if self.led is not None:
            self.led.value(0)  # Pico led off
        if debug:
            print("phase2=", self._phase)
        self.totalStepsRotated += steps

    def powerOff(self):
        for pin in self.pins:
            pin.value(0)

    def revolutionsToSteps(self, revolutions):
        """Return the number of steps required for the number of revolutions specified."""
        # return revolutions * self.STEPS_PER_REVOLUTION * self.GEAR_NUMERATOR / self.GEAR_DENOMINATOR
        # calculated value is 2037.886
        # However this value gains time with the stepper motor I purchased, 2048 gives the correct time.
        return revolutions * self.GEARED_STEPS_PER_REVOLUTION


# The clock's minute hand is geared 1/4, so one revolution of the 28BYJ-48 is 15 minutes=  15*60 seconds.
# So one second is 1 / (15 * 60) revolutions.
def secondsToSteps(stepper, seconds):
    """Return the number of steps required to advance the clock the given number of seconds."""
    return stepper.revolutionsToSteps(seconds / (15 * 60))


def main():
    # pin assignment
    PIN_A = Pin(6, Pin.OUT)  # Pico GPIO6 connected to stepper control pin IN1
    PIN_B = Pin(7, Pin.OUT)  # Pico GPIO7 connected to stepper control pin IN2
    PIN_C = Pin(8, Pin.OUT)  # Pico GPIO8 connected to stepper control pin IN3
    PIN_D = Pin(9, Pin.OUT)  # Pico GPIO9 connected to stepper control pin IN4
    LED = Pin(25, Pin.OUT)  # Pico LED

    PINS = (PIN_A, PIN_B, PIN_C, PIN_D)  # pin order for clockwise rotation

    calibrate = False
    debug = False

    stepper = Stepper_Motor_28BYJ_48(PINS, LED)
    # The clock's minute hand is geared 1/4, so one revolution of the 28BYJ-48 is 15 minutes=  15*60 seconds.
    # So one second is 1 / (15 * 60) revolutions.
    secondsPerStepperRevolution = 15 * 60
    motorOffBetweenTicks = False
    sleep(1)  # allow Pico to initialise

    startTime = utime.time()
    tickIntervalSeconds = 10  # so hands are moved every 10 seconds
    totalStepsRotated = 0
    if debug:
        print("startTime=", startTime)
        print("s1=", stepper.revolutionsToSteps(1))
        # print("ss(60)=", secondsToSteps(stepper, 60))
        print("ss(60)=", stepper.revolutionsToSteps(60 / secondsPerStepperRevolution))

    if calibrate:
        # stepper.rotate(secondsToSteps(stepper, 3 * 3600))
        print("sc=", stepper.revolutionsToSteps(2 * 4))
        stepper.rotate(stepper.revolutionsToSteps(2 * 4))

    # rotate 10 steps at startup, so clock does not appear dead to user
    # initialRotate = 10
    # rotateMotor(initialRotate)
    # totalStepsRotated += initialRotate

    while True and calibrate == False:
        timeNow = utime.time()
        elapsedTime = timeNow - startTime
        # totalStepsRequired = secondsToSteps(stepper, elapsedTime)
        totalStepsRequired = stepper.revolutionsToSteps(elapsedTime / secondsPerStepperRevolution)
        stepsToRotate = int(totalStepsRequired - stepper.totalStepsRotated)
        if debug:
            print("elapsedTime={}, totalStepsRequired={}, totalStepsRotated={}, stepsToRotate={}".format(elapsedTime, totalStepsRequired, totalStepsRotated, stepsToRotate))
        stepper.rotate(stepsToRotate, debug)

        # Experimental feature to save power by switching off motor between ticks.
        # Unfortunately if anything binds during a tick then when power is turned off
        # it may spring back, thus loosing steps.
        if motorOffBetweenTicks:
            stepper.powerOff()

        toSleep = tickIntervalSeconds - (utime.time() - timeNow)
        if debug:
            print("toSleep=", toSleep)
        utime.sleep(toSleep)


if __name__ == "__main__":
    main()
