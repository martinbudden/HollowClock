//! Test if the gears fit in the base

include <NopSCADlib/core.scad>

use <../scad/printed/Clock.scad>
use <../scad/printed/Base.scad>

include <../scad/target.scad>


//$explode = 1;
//$pose = 1;
module Base_test() {
    offset = 5;
    //offset = 6;
    //offset = 10;
    //offset = 13.5;
    difference() {
        Base_stl();
        baseSize = _baseSize;
        if (!is_undef(offset) && offset)
            translate([-baseSize.x/2 - eps, -eps, -eps])
                cube([baseSize.x + 2* eps, offset, baseSize.z + 25 + 2*eps]);
    }
    Gears_assembly();
    Clock_Face_assembly(clockFace=!true, hourHand=true);
}

if ($preview)
    Base_test();
