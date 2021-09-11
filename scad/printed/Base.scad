include <../global_defs.scad>

include <NopSCADlib/core.scad>
use <NopSCADlib/utils/fillet.scad>
use <NopSCADlib/utils/hanging_hole.scad>
include <NopSCADlib/vitamins/geared_steppers.scad>
include <NopSCADlib/vitamins/pcbs.scad>

include <../target.scad>

use <Clock.scad>


baseSize = _baseSize;
baseExtraY = 1; // add extraY to avoid print artifacts on front of base
baseBoltOffset = 5;
footSize = _footSize;
sideThickness = 5;
footBoltOffset = [10, 5];
coverHeight = 3;
coverDepth = 3;
coverOverlap = 2;
coverBoltOffset = [6.5, footSize.y - 4];
function coverColor() = [120/255, 120/255, 120/255];

//coverBoltOffset = [7.5, footSize.y - 2.5];
picoOffsets = [ [9, -2, 1] ];//, [30, -2, 1] ];
//ZC_A0591_offset = [-33, 5, 0];
ZC_A0591_offset = [-37, -11, 0];

ZC_A0591_X = ["ZC_A0591", "ZC-A0591 ULN2003 driver PCB",
    34.5, 32, 1.6,
    0, 2.5, 0, "green", false,
    [ [2.5, 2.5], [-2.5, 2.5], [2.5, -2.5], [-2.5, -2.5] ],
    [ [ 11.725, 8.3,  -90, "jst_xh", 5],
      [ -6.5,  10,      0, "2p54header", 1, 4],
      [ 20.4,  -4.5,    0, "2p54header", 4, 1],
      [ 20.4,  11,  180, "pdip", 16, "ULN2803AN", true],
      [  5.5,  6,       0, "led", LED3mm, [1,1,1, 0.5]],
      [  5.5,  10.5,    0, "led", LED3mm, [1,1,1, 0.5]],
      [  5.5,  15,      0, "led", LED3mm, [1,1,1, 0.5]],
      [  5.5,  19.5,    0, "led", LED3mm, [1,1,1, 0.5]],
      for(i = [0 : 3]) [5.5 + inch(0.1) * i, -5.5, -90, "ax_res", res1_8, 510, 5, 5.5]

    ],
    [], [], [], M2p5_pan_screw
];

module bolt(type, length) {
    if ($preview && (is_undef($hide_bolts) || $hide_bolts == false))
        screw(type, length);
}

module boltHoleHangingCounterbore(screw_type, length, boreDepth = undef, boltHeadTolerance = 0) {
    hanging_hole(is_undef(boreDepth) ? screw_head_height(screw_type) : boreDepth, ir = screw_clearance_radius(screw_type), h = length)
        poly_circle(r = screw_head_radius(screw_type) + boltHeadTolerance);
}

module boltHoleM3HangingCounterbore(length, boreDepth = undef, boltHeadTolerance = 0) {
    boltHoleHangingCounterbore(M3_cap_screw, length=length, boreDepth=boreDepth, boltHeadTolerance=boltHeadTolerance);
}

module Cover_stl() {
    size = [footSize.x - 2*sideThickness + 2*coverOverlap, footSize.y, coverHeight];
    fillet = 2;

    color(coverColor())
        stl("Cover")
            difference() {
                translate([-size.x/2, 0, 0])
                    union() {
                        cube(size);
                        translate([0, 2, 0])
                            cube([size.x, 1, baseSize.z - footSize.z + 1.5]);
                        cube([size.x, coverDepth, baseSize.z - footSize.z]);
                    }
                for (x = [coverBoltOffset.x, footSize.x - coverBoltOffset.x])
                    translate([x - footSize.x/2, coverBoltOffset.y, 0])
                        boltHole(M3_clearance_radius*2, size.z);
                *translate_z(-eps)
                    fillet(fillet, size.z + 2*eps);
                *translate([size.x, 0, -eps])
                    rotate(90)
                        fillet(fillet, size.z + 2*eps);
            }
}

module Cover_hardware() {
    for (x = [coverBoltOffset.x, footSize.x - coverBoltOffset.x])
        translate([x - footSize.x/2, coverBoltOffset.y, 0])
            bolt(M3_dome_screw, 8);
}

module foot(fillet=2) {
    translate([-baseSize.x/2, -footSize.y, 0]) {
        difference() {
            union() {
                rounded_cube_xy([footSize.x, baseSize.y + footSize.y, footSize.z], fillet);
                for (x = [0, footSize.x - sideThickness + coverOverlap])
                    translate([x, 0, 0])
                        cube([sideThickness - coverOverlap, baseSize.y + footSize.y - 2*fillet, baseSize.z]);
                for (x = [0, footSize.x - sideThickness])
                    translate([x, coverDepth, 0])
                        cube([sideThickness, baseSize.y + footSize.y - 2*fillet - coverDepth, baseSize.z - coverHeight]);
                lugSize = [5.75, footSize.y - coverBoltOffset.y + 4, 4];
                lugFillet = 1;
                translate([0, footSize.y - lugSize.y + lugFillet, baseSize.z - coverHeight - lugSize.z]) {
                    translate([sideThickness - lugFillet, 0, 0])
                        hull() {
                            rounded_cube_xy(lugSize, lugFillet);
                            translate([0, lugSize.y, -max(lugSize.x, lugSize.y)])
                                cube([eps, eps, eps]);
                        }
                    translate([footSize.x - lugSize.x - sideThickness + lugFillet, 0, 0])
                        hull() {
                            rounded_cube_xy(lugSize, lugFillet);
                            translate([lugSize.x, lugSize.y, -lugSize.x])
                                cube([eps, eps, eps]);
                        }
                }
            }
            for (x = [coverBoltOffset.x, footSize.x - coverBoltOffset.x])
                translate([x, coverBoltOffset.y, baseSize.z - coverHeight])
                    vflip()
                        boltHole(M3_tap_radius*2, 4);

            translate_z(-eps)
                fillet(fillet, baseSize.z + 2*eps);
            translate([footSize.x, 0, -eps])
                rotate(90)
                    fillet(fillet, baseSize.z + 2*eps);

            picoSize = pcb_size(RPI_Pico);
            for (picoOffset = picoOffsets)
                translate(picoOffset + [picoSize.x/2, footSize.y - picoSize.y/2, footSize.z - picoOffset.z]) {
                    pcb_hole_positions(RPI_Pico)
                        vflip()
                            boltHole(M2_tap_radius*2, 4);
                    headerCutoutSize = [picoSize.x, 2, 1.5];
                    for (y = [picoSize.y/2 - 2, -picoSize.y/2 + 2])
                        translate([-picoSize.x/2, y - headerCutoutSize.y/2, -headerCutoutSize.z + eps])
                            rounded_cube_xy(headerCutoutSize, 0.5);
                }
            translate([2, 1.75, footSize.z - 2 + eps])
                rounded_cube_xy([footSize.x - 4, 1.25, 2]);
        }
    }
}

module baseTop(fillet=2) {
    difference() {
        translate([-baseSize.x/2, 0, 0])
            rounded_cube_xy([baseSize.x, baseSize.y + baseExtraY, 25], fillet);
        h = 3*_clockFaceThickness + baseTopTolerance();
        translate([0, (baseSize.y + h)/2, clockHousingDiameter()/2])
            rotate([90, 0, 0])
                cylinder(r=clockHousingDiameter()/2, h = h);
        translate([0, -eps, clockHousingDiameter()/2])
            rotate([-90, 0, 0])
                cylinder(r=_clockID/2, h = baseSize.y + baseExtraY + 2*eps);
    }
}

module Base_stl(main=true, foot=true) {
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

    module pivot(r, d) {
        //translate_z(d)
        rotate([90, 0, 0])
            cylinder(r2=r, r1=r+d, h=d, center=false);
    }

    color(pp4_colour)
        stl("Base")
            // rotate for alignment of rear seam when printing
            rotate(180) {
                translate([reductionGearOffset(), baseSize.y - 5.5, driveGearPosZ()])
                    difference() {
                        d = 1;
                        pivot(2.25, d);
                        rotate([90, 0, 0])
                            boltHole(M3_tap_radius*2, d, horizontal=true, chamfer=0);
                    }
                translate([0, baseSize.y, driveGearPosZ()])
                    pivot(2, 3.25);
                difference() {
                    union() {
                        if (foot)
                            foot(fillet);
                        translate_z(baseSize.z)
                            baseTop(fillet);
                        if (main)
                            translate([-baseSize.x/2, 0, 0])
                                rounded_cube_xy(baseSize + [0, baseExtraY, 0], fillet);
                    }
                    *for (x = [-1, 1])
                        translate([x * (baseSize.x/2 - baseBoltOffset), 0, baseSize.z - baseBoltOffset])
                            rotate([90, 0, 180])
                                boltHole(M3_tap_radius*2, 8, horizontal=true, chamfer_both_ends=false);
                    translate_z(driveGearPosZ()) {
                        translate([reductionGearOffset(), 0, 0])
                            rotate([90, 0, 180]) {
                                boltHole(M3_tap_radius*2, baseSize.y - 2, horizontal=true, chamfer_both_ends=false);
                                boltHole(M3_clearance_radius*2, 10, horizontal=true, chamfer_both_ends=false);
                            }
                        translate([0, -eps, -0.25]) {
                            size = [gs_boss_d(28BYJ_48), 8, 25];
                            cutout(size);
                        }
                        translate([0, clockOffsetY() + _clockFaceThickness, 0]) {
                            translate([0, -1, -2])
                                cutout([44, gearStackSizeZ() + 1.5, 24]);
                            translate([reductionGearOffset(), 0, 0]) {
                                rotate([0, -45, 0]) {
                                    translate([0, gearThickness() - 0.5, 0])
                                        cutout([44, gearThickness() + 1.5, 24]);
                                    translate([0, -1.5, 0])
                                        cutout([14, gearThickness() + 1.5, 28]);
                                    translate([0, 5.75 - reductionGearShaftLength(), 0])
                                        cutout([reductionGearShaftDiameter() + 0.5, reductionGearShaftLength(), 32]);
                                }
                            }
                        }
                        rotate([90, 0, 0]) {
                            geared_stepper_screw_positions(28BYJ_48)
                                vflip()
                                    boltHole(M3_tap_radius*2, 5.5, horizontal=true, rotate=180, chamfer_both_ends=false);
                        translate(ZC_A0591_offset)
                            rotate(-90)
                                pcb_hole_positions(ZC_A0591_X)
                                    vflip()
                                        boltHole(M3_tap_radius*2, 6, horizontal=true, rotate=90, chamfer_both_ends=false);
                        }
                    }
                    translate([0, clockOffsetY(), clockPosZ()])
                        rotate([90, 0, 180])
                            tenons(tolerance=0.5);
                    usbCutoutSize = [9, 14, 9];
                    translate([-baseSize.x/2 - eps, -usbCutoutSize.y/2 + picoOffsets[0].y - pcb_size(RPI_Pico).y/2, footSize.z - 1])
                        cube(usbCutoutSize);
                } // end difference
            } // end rotate
}

module Base_Stage_1_assembly()
assembly("Base_Stage_1", ngb=true) {
    rotate(180)
        stl_colour(pp4_colour)
            Base_stl();
    gearReduction();
    translate([reductionGearOffset(), 0, driveGearPosZ()])
        rotate([90, 0, 0])
            bolt(M3_cap_screw, 16);
    translate_z(driveGearPosZ())
        rotate([90, 0, 0])
            translate(ZC_A0591_offset + [0, 0, gs_lug_t(28BYJ_48)])
                explode(5, true)
                    rotate (-90) {
                        pcb(ZC_A0591_X);
                        pcb_screw_positions(ZC_A0591_X)
                            translate_z(pcb_size(ZC_A0591_X).z)
                                bolt(M3_dome_screw, 8);
                    }
    picoSize = pcb_size(RPI_Pico);
    //#translate(picoOffset + [picoSize.x/2, footSize.y - picoSize.y/2, footSize.z - picoOffset.z])
    translate(picoOffsets[0] + [(picoSize.x - footSize.x)/2, -picoSize.y/2, footSize.z]) {
        pcb(RPI_Pico);
        pcb_screw_positions(RPI_Pico)
            translate_z(picoSize.z)
                bolt(M2_cap_screw, 6);
    }
}

module Base_assembly()
assembly("Base") {
    Base_Stage_1_assembly();
    explode(50)
        Gears_assembly();
    translate_z(driveGearPosZ())
        rotate([90, 0, 0])
            //geared_stepper(28BYJ_48);
            geared_stepper_screw_positions(28BYJ_48)
            //translate([gs_pitch(28BYJ_48)/2, -gs_offset(28BYJ_48), gs_lug_t(28BYJ_48)])
                translate_z(gs_lug_t(28BYJ_48))
                    bolt(M3_dome_screw, 6);
}
