from machine import Pin, Timer
from rp2 import PIO, StateMachine, asm_pio
from time import sleep
import utime
import micropython


class Stepper_Motor_28BYJ_48_PIO:
    """A 28BYJ-48 geared stepper motor driven by Raspberry Pi Pico PIO."""

    # The 28BYJ-48 has 32 full steps per revolution (so 64 half-steps per revolution).
    # Gearing is 32/9 * 22/11 * 26/9 * 31/10 = 51584 / 810 = 25792 / 405 (= 63.68395 ~ 64).
    # So there are 32 * 25792 / 405 (=2037.8864 ~ 2038) full steps per revolution.
    # See https://lastminuteengineers.com/28byj48-stepper-motor-arduino-tutorial/
    STEPS_PER_REVOLUTION = 32
    GEAR_NUMERATOR = 25792
    GEAR_DENOMINATOR = 405

    SWITCHING_SEQUENCE_FULL_STEP = (
        (0b0001, 0b0010, 0b0100, 0b1000),
        (0b0010, 0b0100, 0b1000, 0b0001),
        (0b0100, 0b1000, 0b0001, 0b0010),
        (0b1000, 0b0001, 0b0010, 0b0100),
    )

    def __init__(self, id=0, basePin=25, tickIntervalMs=1000, gearing=1, debug=False):
        self.tickIntervalMs = tickIntervalMs
        self.gearing = gearing
        self.debug = debug
        self.sm = StateMachine(id)
        # StateMachine.init(program, freq=- 1, *, in_base=None, out_base=None, set_base=None, jmp_pin=None, sideset_base=None, in_shiftdir=None, out_shiftdir=None, push_thresh=None, pull_thresh=None)
        # minimum freq is 1908
        self.sm.init(self.prog, freq=2000, out_base=Pin(basePin))
        self.sm.active(0)
        self.sm.irq(self.irqHandler)
        self.timer = Timer()
        self._startTime = 0
        self._totalStepsRotated = 0
        self._switchingSequence = self.SWITCHING_SEQUENCE_FULL_STEP
        self._phaseCount = len(self._switchingSequence)
        self._phase = 0

    # https://docs.micropython.org/en/latest/library/rp2.html#rp2.asm_pio
    @asm_pio(out_init=(PIO.OUT_LOW,) * 4, out_shiftdir=PIO.SHIFT_RIGHT)
    def prog():
        pull()  # pull from TX FIFO into OSR (Output Shift Register)
        mov(x, osr)  # move stepCount into X register

        pull()
        mov(y, osr)  # move bitPattern to Y register

        jmp(not_x, "end")  # jump to end if X register (stepCount) is zero

        label("loop")
        jmp(not_osre, "step")  # jump to step if OSR not empty
        mov(osr, y)  # all bits have been shifted out, so reload OSR from Y register

        label("step")
        out(pins, 4)[26]  # shift out 4 bits from OSR to GPIO pins and delay 26 clock cycles, total looptime = (4 + 26)*0.5ms = 15ms

        jmp(x_dec, "loop")  # jump to loop if X register (stepCount) not zero, post decrement X register

        label("end")
        # set irq number 0 relative to state machine and don't wait.
        # Relative irq number is calclated by replacing the low two bits of the irq number with the low two bits of the sum irq_num + sm_id
        irq(rel(0))

    def irqHandler(self, sm):
        sm.active(0)  # Stop the state machine
        self.timer.init(mode=Timer.ONE_SHOT, period=self.tickIntervalMs, callback=self.tick)

    def tick(self, tm):
        elapsedTime = utime.time() - self._startTime
        totalStepsRequired = self.revolutionsToSteps(elapsedTime) * self.gearing
        stepsToRotate = int(totalStepsRequired - self._totalStepsRotated)
        if self.debug:
            print("elapsedTime={}, totalStepsRequired={}, totalStepsRotated={}, stepsToRotate={}".format(elapsedTime, totalStepsRequired, self._totalStepsRotated, stepsToRotate))
        if not self.debug or self._totalStepsRotated < 50:
            self.rotate(stepsToRotate)

    def resetTime(self):
        self._startTime = utime.time()
        self._totalStepsRotated = 0

    def rotate(self, stepCount):
        """Rotate the motor the given number of steps."""
        if self.debug:
            print("phase=", self._phase)
        patterns = self._switchingSequence[self._phase]
        pattern = patterns[0] | (patterns[1] << 4) | (patterns[2] << 8) | (patterns[3] << 12)
        pattern |= pattern << 16
        self.sm.put(stepCount)  # Push stepCount onto the TX FIFO
        self.sm.put(pattern)  # Push stepCount onto TX FIFO
        self.sm.active(1)  # Start the state machine
        self._totalStepsRotated += stepCount
        self._phase = (self._phase + stepCount) % self._phaseCount

    def revolutionsToSteps(self, revolutions):
        """Return the number of steps required for the number of revolutions specified."""
        # return revolutions * self.STEPS_PER_REVOLUTION * self.GEAR_NUMERATOR / self.GEAR_DENOMINATOR
        return revolutions * 2048


def main():
    micropython.alloc_emergency_exception_buf(100)
    stepper = Stepper_Motor_28BYJ_48_PIO(id=0, basePin=25, tickIntervalMs=2000, gearing=1 / (15 * 60), debug=False)
    stepper.resetTime()
    stepper.rotate(1)


if __name__ == "__main__":
    main()
