//! Display the base

include <NopSCADlib/core.scad>

use <../scad/printed/Base.scad>

include <../scad/target.scad>


//$explode = 1;
//$pose = 1;
module Base_test() {
    //Base_stl();
    Base_assembly();
    //Base_Stage_1_assembly();
}

if ($preview)
    Base_test();
