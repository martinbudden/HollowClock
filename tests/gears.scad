//! Test if the gears mesh correctly

include <NopSCADlib/core.scad>

use <../scad/printed/Clock.scad>


//$explode = 1;
//$pose = 1;
module Gears_test() {
    gears(stepper=false, idler=true);
}

if ($preview)
    Gears_test();
