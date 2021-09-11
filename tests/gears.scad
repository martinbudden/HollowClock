//! Test if the gears mesh correctly

include <NopSCADlib/core.scad>

use <../scad/printed/Clock.scad>


//$explode = 1;
//$pose = 1;
module Gears_test() {
    gearReduction();
    //gears(stepper=false, transparent=true);
    Gears_assembly(stepper=false, transparent=true);
}

if ($preview)
    rotate(-60)
        Gears_test();
