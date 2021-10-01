# Hollow Clock

This **Hollow Clock** is a remix of the [Hollow clock 2 - silent and smooth](https://www.thingiverse.com/thing:4761858)
by [Shinsaku Hiura "shiura"](https://www.thingiverse.com/shiura/designs) and licensed under the same
Creative Commons - Attribution - Non-Commercial - Share Alike license [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

![Main Assembly](HC160/assemblies/main_assembled.png)

## Assembly instructions

The assembly instructions and the BOM (parts list) are [here](HC160/readme.md).

The STL files are on [thingiverse](https://www.thingiverse.com/thing:4947971).

## Improvements to original design

I was having problems with the clock keeping time, mainly due to two reasons:

1. The gears sometimes skipped
2. The Arduino itself does not keep particularly good time

To solve these problems I made the following changes:

1. Changed the gearing to use involute gears
2. Added an axel to the reduction gear
3. Added a housing to the main clock face
4. Used a mortice and tenon joint to connect the clock face to the base
5. Recessed the gears to reduce friction
6. Used a Raspberry Pi Pico instead of an Arduino - this has a build in real time clock and so keeps much better time

Items 3 and 4 stop the clock face from "jumping" and skipping a tooth.

Additionally I changed the design of the base and cover, and the new cover can be printed without supports.
