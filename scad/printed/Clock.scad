include <../global_defs.scad>

include <NopSCADlib/core.scad>
use <NopSCADlib/utils/fillet.scad>
use <NopSCADlib/utils/gears.scad>
use <NopSCADlib/utils/tube.scad>
include <NopSCADlib/vitamins/geared_steppers.scad>

include <../target.scad>

//  Modulus
m = 1.3; // [0.1 : 0.1 : 5.0]
// Pressure angle
pa = 20; // [14.5, 20, 22.5, 25]
//teeth used: 120, 30, 10, 28, 7


handsToothCount = 120;
driveToothCount = handsToothCount/4;
gearTolerance = 0.1;
driveGearOffset = centre_distance(m, handsToothCount, driveToothCount, pa) + gearTolerance;
function driveGearPosZ() = clockPosZ() - driveGearOffset;
function idlerGearOffset() = centre_distance(m, 10, 28, pa);
function idlerGearShaftDiameter() = 7.5;
function idlerGearShaftLength() = 11;

driveShaftRadius = 8/2;
idlerToothCount = 28;
hourGearCenterRadius = driveShaftRadius + 0.25;
faceThickness = _clockFaceThickness;
function baseTopTolerance() = 1.2;// + 3.8 + eps;
function clockOffsetY() = (_baseSize.y - faceThickness*3)/2;
clockHousingTolerance = 0.2;
clockHousingSize = [1, 3*faceThickness + baseTopTolerance()];
function clockHousingDiameter() = _clockOD;// + clockHousingSize.x + clockHousingTolerance;
function clockPosZ() = _baseSize.z + clockHousingDiameter()/2;

function clockHandRingThickness() = 1;
gearThickness = 3;
function gearThickness() = gearThickness;
gearRotate = 90;
function gearStackSizeZ() = 2*gearThickness + 4;


module boltHole(diameter, length, horizontal = false, rotate = 0, chamfer = 0, chamfer_both_ends = true, cnc = false, twist = 0) {
    translate_z(-eps)
        if (cnc)
            cylinder(r = diameter/2, h = length + 2*eps);
        else if (horizontal)
            rotate(rotate)
                teardrop(length + 2*eps, diameter/2, center=false, chamfer=chamfer, chamfer_both_ends = chamfer_both_ends);

        else
            poly_cylinder(r = diameter/2, h = length + 2*eps, twist = twist);
}

module gear(teeth, centerRadius=0, thickness=gearThickness) {
    linear_extrude(thickness, center = false, convexity = 4)
        difference() {
            involute_gear_profile(m, teeth, pa);
            if (centerRadius)
                circle(r=centerRadius);
        }
}

module shaftCutout(height) {
    translate_z(-eps)
        difference() {
            poly_cylinder(r=5/2, h=height + 2*eps);
            for (x = [1.5, -1.5 - 3])
                translate([x, -3, -eps])
                    cube([3, 6, height + 4*eps]);
        }
}

module Drive_Gear_stl() {
    color(pp2_colour)
        stl("Drive_Gear") {
            gear(driveToothCount);
            translate_z(gearThickness)
                gear(10, centerRadius=5/2, thickness=3.5);
            difference() {
                cylinder(d=(gs_boss_d(28BYJ_48)-0.5), h =14.5, center=false);
                translate_z(gearThickness + 3.5)
                    shaftCutout(8);
                translate_z(gearThickness + 3.5 + 5)
                    poly_cylinder(r=5/2, h=3 + eps);
            }
        }
}

module Idler_Gear_stl() {
    color(pp1_colour)
        stl("Idler_Gear") {
            rotate(180/idlerToothCount)
                gear(idlerToothCount);
            rotate(0.5*180/(idlerToothCount/4))
                translate_z(gearThickness)
                    gear(idlerToothCount/4, thickness=3.5);
            cylinder(r=idlerGearShaftDiameter()/2, h=idlerGearShaftLength());
        }
}

module Hour_Gear_stl() {
    color(pp3_colour)
        stl("Hour_Gear")
            gear(30, centerRadius=hourGearCenterRadius);
}

module gears() {
    translate_z(-gearThickness() + 0.5) {
        stl_colour(pp3_colour)
            translate_z(0.1)
                Hour_Gear_stl();
        translate_z(-gearThickness()-3.5)
             stl_colour(pp2_colour)
                Drive_Gear_stl();
        rotate(gearRotate)
            translate([0, -idlerGearOffset(), -gearThickness() - 0.25])
                stl_colour(pp1_colour)
                    Idler_Gear_stl();
    }
    *translate_z(7.5)
        geared_stepper(28BYJ_48);
}

module tenons(tolerance=0) {
    for (tenonAngle = [30, -30]) {
        tenonPos = [(_clockID + _clockOD)/4*sin(tenonAngle), -(_clockID + _clockOD)/4*cos(tenonAngle), 0];
        tenonSize = [5 + tolerance,
            _clockOD/2 + tenonPos.y + 15 + (tolerance ? 2 : 0),
             4 + tolerance/2];
        translate(tenonPos -[tenonSize.x/2, tenonSize.y, 0])
            rounded_cube_xy(tenonSize, tolerance ? 0 : 1);
        if (tolerance)
            translate(tenonPos - [0, 3*tenonSize.y/4, 0])
                vflip()
                    boltHole(M3_tap_radius*2, 2, horizontal=true, rotate=180);
    }
}

module Clock_Face_stl() {
    color(pp1_colour)
        stl("Clock_Face") {
            // the face
            difference() {
                union() {
                    tube(or=_clockOD/2, ir=_clockID/2, h=faceThickness, center=false);
                    markerSize = [25, 4, 4];
                    for (a =[0 : 11])
                        rotate(a * 360/12)
                            translate([_clockOD/2 - markerSize.x, -markerSize.y/2, 0]) {
                                rounded_cube_xy(markerSize, 1);
                                translate([markerSize.x -(_clockOD-_clockID)/2, 0, 0]) {
                                    rotate(180)
                                        fillet(1, markerSize.z);
                                    translate([0, markerSize.y, 0])
                                        rotate(90)
                                            fillet(1, markerSize.z);
                                }
                            }
                }
                cutoutHeight = 1.5;
                translate([0, -driveGearOffset, faceThickness - cutoutHeight])
                    cylinder(r=21.5, h=cutoutHeight + eps, center=false);
            }
            // the housing
            housingAngle = 264;
            rotate(-90 + (360 - housingAngle)/2)
                rotate_extrude(angle=housingAngle) {
                    translate([_clockOD/2 + clockHousingTolerance, 0])
                        square(clockHousingSize);
                    translate([_clockOD/2 - 1, 0])
                        square([1.5, faceThickness]);
                }
            tenons();
        }
}

module Hour_Hand_stl(highlight=false) {
    color(pp2_colour)
        stl("Hour_Hand") {
            gear(handsToothCount, _clockID/2, faceThickness);
            translate_z(clockHandRingThickness()/2)
                if (highlight)
                    #tube(or=_clockOD/2, ir=_clockID/2, h=clockHandRingThickness());
                else
                    tube(or=_clockOD/2, ir=_clockID/2, h=clockHandRingThickness());
            rotate(180) {
                handSize = [_clockOD/2 - 25, 4, 4];
                translate([0, -handSize.y/2, 0])
                    cube(handSize);
                cylinder(r=handSize.y/2, h=handSize.z);
                handSize2 = [_clockID/2 + 0.5, 2, 4];
                translate([0, -handSize2.y/2, 0])
                    cube(handSize2, 0.5);
            }
        }
}

module Minute_Hand_stl(highlight=false) {
    color(pp3_colour)
        stl("Minute_Hand") {
            gear(handsToothCount, _clockID/2, faceThickness);
            translate_z(clockHandRingThickness()/2)
                if (highlight)
                    #tube(or=_clockOD/2, ir=_clockID/2, h=clockHandRingThickness());
                else
                    tube(or=_clockOD/2, ir=_clockID/2, h=clockHandRingThickness());
            handSize = [_clockID/2 + 0.5, 4, 4];
            rotate(90)
                translate([0, -handSize.y/2, 0])
                    cube(handSize);
            cylinder(r=handSize.y/2, h=handSize.z);
        }
}

module Clock_Face_assembly(clockFace=true, hourHand=true)
assembly("Clock_Face") {
    translate([0, clockOffsetY(), clockPosZ() + 4*eps])
        rotate([90, 0, 180]) {
            if (clockFace)
                stl_colour(pp1_colour)
                    Clock_Face_stl();
            if (hourHand)
                translate_z(2*faceThickness + baseTopTolerance()/4)
                    hflip()
                        stl_colour(pp2_colour)
                            Hour_Hand_stl(highlight=!clockFace);
            translate_z(3*faceThickness + 2*baseTopTolerance()/4)
                hflip()
                    stl_colour(pp3_colour)
                        Minute_Hand_stl(highlight=!hourHand);
        }
}

module Gears_assembly()
assembly("gears") {
    echo(clockOffsetY=clockOffsetY());
    translate([0, clockOffsetY() + faceThickness, driveGearPosZ()])
        rotate([90, 0, 0])
            gears();
}
