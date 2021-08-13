//!# Hollow Clock Assembly Instructions
//!
//!
//!![Main Assembly](assemblies/main_assembled.png)
//!
//!
include <global_defs.scad>

include <NopSCADlib/core.scad>

use <printed/Base.scad>
use <printed/Clock.scad>


module main_assembly() assembly("main") {
    Base_assembly();
    Clock_Face_assembly();
}

if ($preview)
    main_assembly();
