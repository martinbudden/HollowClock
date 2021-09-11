//! Test if the gears fit in the base

include <NopSCADlib/core.scad>

use <../scad/printed/Clock.scad>
use <../scad/printed/Base.scad>

include <../scad/target.scad>


//$explode = 1;
//$pose = 1;
module Base_test() {
    //offset = 1.9+eps;
    offset = 3.7;
    //offset = 6;
    //offset = 10;
    //offset = 13.5;
    offset2 = _baseSize.y - 3.7;
    difference() {
        rotate(180)
            Base_stl(main=true, foot=false);
        baseSize = _baseSize;
        if (!is_undef(offset) && offset) {
            translate([-baseSize.x/2 - eps, -eps, -eps])
                cube([baseSize.x + 2* eps, offset, baseSize.z + 25 + 2*eps]);
            baseExtraY = 1;
            translate([-baseSize.x/2 - eps, offset2 + baseExtraY, -eps])
                cube([baseSize.x + 2*eps, baseSize.y - offset2 + eps, baseSize.z + 25 + 2*eps]);
        }
    }
    Gears_assembly(stepper=false, transparent=true);
    gearReduction();
    rotate(180)
        Clock_Face_assembly(clockFace=true, hourHand=true, minuteHand=true, transparent=true);
}

if ($preview)
    Base_test();
