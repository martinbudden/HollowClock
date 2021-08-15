//! Display the clockface

include <NopSCADlib/core.scad>

use <../scad/printed/Clock.scad>

include <../scad/target.scad>


//$explode = 1;
//$pose = 1;
module Clock_test() {
    Clock_Face_assembly(clockFace=true, hourHand=true, minuteHand=true);
    //Clock_Face_stl();
    //Hour_Hand_stl();
    //Minute_Hand_stl();
}

if ($preview)
    Clock_test();
