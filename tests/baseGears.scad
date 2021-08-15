//! Test if the gears fit in the base

include <NopSCADlib/core.scad>

use <../scad/printed/Clock.scad>
use <../scad/printed/Base.scad>

include <../scad/target.scad>


//$explode = 1;
//$pose = 1;
module Base_test() {
    offset = 5;
    offset2 = _baseSize.y - 6.6;
    //offset = 6;
    //offset = 10;
    //offset = 13.5;
    difference() {
        Base_stl(foot=false);
        baseSize = _baseSize;
        if (!is_undef(offset) && offset) {
            translate([-baseSize.x/2 - eps, -eps, -eps])
                cube([baseSize.x + 2* eps, offset, baseSize.z + 25 + 2*eps]);
            translate([-baseSize.x/2 - eps, offset2, -eps])
                cube([baseSize.x + 2* eps, baseSize.y - offset2 + eps, baseSize.z + 25 + 2*eps]);
        }
    }
    Gears_assembly();
    Clock_Face_assembly(clockFace=!true, hourHand=true, minuteHand=true);
}

if ($preview)
    Base_test();
