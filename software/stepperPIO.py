from machine import Pin, Timer
from rp2 import PIO, StateMachine, asm_pio
from time import sleep
import utime
import sys


@asm_pio(set_init=(PIO.OUT_LOW,) * 4,
         out_init=(PIO.OUT_LOW,) * 4,
         out_shiftdir=PIO.SHIFT_RIGHT,
         in_shiftdir=PIO.SHIFT_LEFT)
def prog():
    pull() # pull from TX FIFO into OSR (Output Shift Register)
    mov(x, osr) # move stepCount into X register

    pull()
    mov(y, osr) # move bitPattern to Y register

    jmp(not_x, "end") # jump to end if X register (stepCount) is zero

    label("loop")
    jmp(not_osre, "step") # jump to step if there are still bits to shift in the OSR
    mov(osr, y) # all bits have been shifted out, so reload OSR from Y register

    label("step")
    out(pins, 4) [31] # shift out 4 bits from OSR to GPIO pins

    jmp(x_dec,"loop") # decrement X register (stepCount) and jump to loop if not zero

    label("end")
    irq(rel(0))

class Stepper_Motor_28BYJ_48_State_Machine(StateMachine):
    """A 28BYJ-48 geared stepper motor state machine."""

    SWITCHING_SEQUENCE_FULL_STEP = (
        (0b0001, 0b0010, 0b0100, 0b1000),
        (0b0010, 0b0100, 0b1000, 0b0001),
        (0b0100, 0b1000, 0b0001, 0b0010),
        (0b1000, 0b0001, 0b0010, 0b0100),
    )

    def __init__(self, irqHandler):
        super().__init__(0)
        #StateMachine.init(program, freq=- 1, *, in_base=None, out_base=None, set_base=None, jmp_pin=None, sideset_base=None, in_shiftdir=None, out_shiftdir=None, push_thresh=None, pull_thresh=None)
        # minimum freq is 1908
        self.init(prog, freq=2000, set_base=Pin(25), out_base=Pin(25))
        self.active(0)
        self.irq(irqHandler)
        self.timer = Timer()
        self.tickIntervalMs = 1000
        self.startTime = 0
        self.totalStepsRotated = 0
        self._switchingSequence = self.SWITCHING_SEQUENCE_FULL_STEP
        self._phaseCount = len(self._switchingSequence)
        self._phase = 0

    def start(self):
        self.startTime = utime.time()
        self.totalStepsRotated = 0


    def rotate(self, stepCount, debug=False):
        """Rotate the motor the given number of steps."""
        if debug:
            print("phase=", self._phase)
        self.totalStepsRotated += stepCount
        patterns = self._switchingSequence[self._phase]
        self._phase = (self._phase + stepCount) % self._phaseCount
        pattern = patterns[0] | (patterns[1] << 4) | (patterns[2] << 8) | (patterns[3] << 12)
        pattern |= pattern << 16
        self.put(stepCount) # Push stepCount onto the TX FIFO
        self.put(pattern) # Push stepCount onto TX FIFO
        self.active(1) # Start the state machine
        #stepperTimer.init(mode=Timer.ONE_SHOT, period=1000, callback=tick) # 1000ms

    def revolutionsToSteps(self, revolutions):
        """Return the number of steps required for the number of revolutions specified."""
        #return revolutions * self.STEPS_PER_REVOLUTION * self.GEAR_NUMERATOR / self.GEAR_DENOMINATOR
        return revolutions * 2048

# The clock's minute hand is geared 1/4, so one revolution of the 28BYJ-48 is 15 minutes, 15*60 seconds.
# So one second is 1 / (15 * 60) revolutions.
def secondsToSteps(stepper, seconds):
    """Return the number of steps required to advance the clock the given number of seconds."""
    return seconds * stepper.revolutionsToSteps(seconds) / (15 * 60)

def stepperIrqHandler(sm):
    sm.active(0) # Stop the state machine
    stepperSM.timer.init(mode=Timer.ONE_SHOT, period=stepperSM.tickIntervalMs, callback=tick)

def tick(timer):
    print("tick")
    elapsedTime = utime.time() - stepperSM.startTime
    totalStepsRequired = secondsToSteps(stepperSM, elapsedTime)
    stepsToRotate = int(totalStepsRequired - stepperSM.totalStepsRotated)
    print("elapsedTime={}, totalStepsRequired={}, totalStepsRotated={}, stepsToRotate={}".format(elapsedTime, totalStepsRequired, stepperSM.totalStepsRotated, stepsToRotate))
    stepperSM.rotate(stepsToRotate, debug=True)
    #stepperSM.rotate(1, debug=True)


stepperSM = Stepper_Motor_28BYJ_48_State_Machine(stepperIrqHandler)

def main():
    stepperSM.start()
    stepperSM.rotate(1, debug=True)


if __name__ == "__main__":
    main()
