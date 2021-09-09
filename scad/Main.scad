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
assembly("main") {
    rotate(180)
        Base_assembly();
    explode(100)
        Clock_Face_assembly();
    rotate(180)
        translate([0, -_footSize.y, _baseSize.z + 2*eps])
            explode([0, -100, 20], true) {
                hflip()
                    stl_colour(coverColor())
                        Cover_stl();
                Cover_hardware();
        }
}

if ($preview)
    main_assembly();
