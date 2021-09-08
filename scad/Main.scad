//!# Hollow Clock Assembly Instructions
//!
//!
//!![Main Assembly](assemblies/main_assembled.png)
//!
//!
include <global_defs.scad>

include <NopSCADlib/core.scad>

include <target.scad>

use <printed/Base.scad>
use <printed/Clock.scad>

module main_assembly()
rotate(180)
assembly("main") {
    Base_assembly();
    explode(100)
    translate_z(0)
        Clock_Face_assembly();
    translate([0, -_footSize.y, _baseSize.z + 2*eps]) {
        explode([0, -100, 20], true) {
            hflip()
                stl_colour(coverColor())
                    Cover_stl();
            Cover_hardware();
        }
    }
}

if ($preview)
    main_assembly();
