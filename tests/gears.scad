//! Test if the gears mesh correctly

include <NopSCADlib/core.scad>

use <../scad/printed/Clock.scad>


//$explode = 1;
//$pose = 1;
module Gears_test() {
    translate_z(-gearThickness() + 0.5) {
        Hour_Gear_stl();
        translate_z(-gearThickness()-3.5)
            Drive_Gear_stl();
        rotate(90)
            translate([0, -idlerGearOffset(), -gearThickness() - 0.25])
                Idler_Gear_stl();
    }
}

if ($preview)
    Gears_test();
