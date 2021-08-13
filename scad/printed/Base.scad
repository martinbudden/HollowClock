include <../global_defs.scad>

include <NopSCADlib/core.scad>
use <NopSCADlib/utils/fillet.scad>
include <NopSCADlib/vitamins/geared_steppers.scad>
include <NopSCADlib/vitamins/pcbs.scad>

include <../target.scad>

use <Clock.scad>


baseSize = _baseSize;
footSize = _footSize;
footBoltOffset = 5;
baseBoltOffset = 5;
picoOffsets = [ [9, 0, 1], [30, 0, 1] ];
//ZC_A0591_offset = [-33, 5, 0];
ZC_A0591_offset = [-38.5, -6, 0];

module baseTop(fillet=2) {
    difference() {
        translate([-baseSize.x/2, 0, 0])
            rounded_cube_xy([baseSize.x, baseSize.y, 25], fillet);
        h = 3*_clockFaceThickness + baseTopTolerance();
        translate([0, (baseSize.y + h)/2, clockHousingDiameter()/2])
            rotate([90, 0, 0])
                cylinder(r=clockHousingDiameter()/2, h = h);
        translate([0, baseSize.y + eps, clockHousingDiameter()/2])
            rotate([90, 0, 0])
                cylinder(r=_clockID/2, h = baseSize.y + 2*eps);
    }
}

module foot(fillet=2) {
    translate([-baseSize.x/2, baseSize.y - footSize.y, 0])
        difference() {
            rounded_cube_xy(footSize, fillet);
            for (x = [footBoltOffset, footSize.x - footBoltOffset])
                translate([x, footBoltOffset, 0])
                    screw_polysink(M3_cs_cap_screw, 2*footSize.z + 2*eps, sink = 0.2);
            picoSize = pcb_size(RPI_Pico);
            for (picoOffset = picoOffsets)
                translate(picoOffset + [picoSize.x/2, (picoSize.y + footSize.y)/2 - baseSize.y, footSize.z - picoOffset.z])
                    pcb_hole_positions(RPI_Pico)
                        vflip()
                            boltHole(M2_tap_radius*2, 4, twist=4);
        }
}

module Base_stl() {
    fillet = 2;

    *translate([0, 13.97, 29.77])
        #import("stlimport/body.stl");

    module cutout(size) {
        hull() {
            rotate([-90, 0, 0])
                cylinder(r=size.x/2, h=size.y);
            translate([-size.x/2, 0, 0])
                cube(size);
        }
    }

    color(pp4_colour)
        stl("Base") {
            foot(fillet);
            //rotate([2, 0, 0])
            difference() {
                union() {
                    translate_z(baseSize.z)
                        baseTop(fillet);
                    translate([-baseSize.x/2, 0, 0])
                        rounded_cube_xy(baseSize, fillet);
                }
                for (x = [-1, 1])
                    translate([x * (baseSize.x/2 - baseBoltOffset), 0, baseSize.z - baseBoltOffset])
                        rotate([90, 0, 180])
                            boltHole(M3_tap_radius*2, 8, horizontal=true, chamfer_both_ends=false);
                translate_z(driveGearPosZ()) {
                    translate([0, -eps, -0.25]) {
                        size = [gs_boss_d(28BYJ_48), 8, 25];
                        cutout(size);
                    }
                    translate([0, clockOffsetY() + _clockFaceThickness - 0.5, 0]) {
                        size = [44, gearStackSizeZ()+0.5, 24];
                            translate([0, -0.5, -2])
                                cutout(size);
                        translate([idlerGearOffset(), 0, 0]) {
                            rotate([0, -45, 0]) {
                                translate([0, gearThickness() - 0.5, 0])
                                    cutout([44, gearThickness() + 1, 24]);
                                translate([0, -1.5, 0])
                                    cutout([14, gearThickness() +1.5, 28]);
                                translate([0, -gearThickness() - 2.5, 0])
                                    cutout([idlerGearShaftDiameter() + 0.5, 8+1, 32]);
                            }
                        }
                    }
                    rotate([90, 0, 0]) {
                        geared_stepper_screw_positions(28BYJ_48)
                            vflip()
                                boltHole(M3_tap_radius*2, 5.5, horizontal=true, rotate=180, chamfer_both_ends=false);
                    translate(ZC_A0591_offset)
                        pcb_hole_positions(ZC_A0591)
                            vflip()
                                boltHole(M3_tap_radius*2, 6, horizontal=true, rotate=180, chamfer_both_ends=false);
                    }
                }
                translate([0, clockOffsetY() - baseTopTolerance()/2, clockPosZ()])
                    rotate([90, 0, 0])
                        hflip()
                            tenons(tolerance=0.5);
            }
        }
}

module Base_assembly()
assembly("Base") {
    stl_colour(pp4_colour)
        Base_stl();
    Gears_assembly();
    translate_z(driveGearPosZ())
        rotate([90, 0, 0]) {
            geared_stepper(28BYJ_48);
            geared_stepper_screw_positions(28BYJ_48)
            //translate([gs_pitch(28BYJ_48)/2, -gs_offset(28BYJ_48), gs_lug_t(28BYJ_48)])
                translate_z(gs_lug_t(28BYJ_48))
                    screw(M3_dome_screw, 6);
            translate(ZC_A0591_offset + [0, 0, gs_lug_t(28BYJ_48)]) {
                pcb(ZC_A0591);
                pcb_screw_positions(ZC_A0591)
                    translate_z(pcb_size(ZC_A0591).z)
                        screw(M3_dome_screw, 8);
            }
        }
    picoSize = pcb_size(RPI_Pico);
    translate(picoOffsets[0] + [(picoSize.x - footSize.x)/2, (picoSize.y - footSize.y)/2, footSize.z]) {
        pcb(RPI_Pico);
        pcb_screw_positions(RPI_Pico)
            translate_z(picoSize.z)
                screw(M2_cap_screw, 6);
    }
}
