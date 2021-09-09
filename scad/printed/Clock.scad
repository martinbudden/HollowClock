include <../global_defs.scad>

include <NopSCADlib/core.scad>
use <NopSCADlib/utils/fillet.scad>
use <NopSCADlib/utils/gears.scad>
include <NopSCADlib/vitamins/geared_steppers.scad>

include <../target.scad>

//  Modulus
gearModulus = 1.3; // [0.1 : 0.1 : 5.0]
// Pressure angle
gearPressureAngle = 20; // [14.5, 20, 22.5, 25]
//teeth used: 120, 30, 10, 28, 7


handsToothCount = 120;
driveToothCount = handsToothCount/4;
reductionToothCount = 28;

gearTolerance = 0.1;
driveGearOffset = centre_distance(gearModulus, handsToothCount, driveToothCount, gearPressureAngle) + gearTolerance;
function driveGearPosZ() = clockPosZ() - driveGearOffset;
function reductionGearOffset() = centre_distance(gearModulus, 10, 28, gearPressureAngle);
function reductionGearShaftDiameter() = 7.5;
function reductionGearShaftLength() = 9;

driveShaftRadius = (gs_boss_d(28BYJ_48) - 0.5)/2;
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

module gear(toothCount, centerRadius=0, thickness=gearThickness, recessDepth=0) {
    linear_extrude(thickness - recessDepth, center = false, convexity = 4)
        difference() {
            involute_gear_profile(gearModulus, toothCount, gearPressureAngle);
            if (centerRadius)
                circle(r=centerRadius, $fn = toothCount > 60 ? 360 : r2sides4n(centerRadius));
        }
    base_d = toothCount * gearModulus * cos(gearPressureAngle);
    if (recessDepth)
        translate_z(thickness - recessDepth) {
            linear_extrude(recessDepth/2, center = false, convexity = 4)
                difference() {
                    involute_gear_profile(gearModulus, toothCount, gearPressureAngle);
                    circle(d=base_d - 4);
                }
            linear_extrude(recessDepth, center = false, convexity = 4)
                difference() {
                    circle(d=base_d - 1);
                    circle(d=base_d - 4);
                }
        }
}

module shaftCutout(height) {
    translate_z(-eps)
        difference() {
            poly_cylinder(r=5/2, h=height + 2*eps);
            cubeSize = [3, 6, height + 4*eps];
            offset = 1.55;
            for (x = [offset, -offset - cubeSize.x])
                translate([x, -cubeSize.y/2, -eps])
                    cube(cubeSize);
        }
}

module driveGear(totalHeight) {
    recessDepth = 0.5;
    difference() {
        union() {
            gear(driveToothCount, recessDepth=recessDepth);
            translate_z(gearThickness - recessDepth) {
                bossHeight = 0.25;
                gear(10, centerRadius=5/2, thickness=3.5 + recessDepth - bossHeight);
                cylinder(r=driveShaftRadius + 1.25, h=3.5 + recessDepth, center=false);
            }
            cylinder(r=driveShaftRadius, h=totalHeight, center=false);
        }
    }
}

module Drive_Gear_stl() {
    color(pp2_colour)
        stl("Drive_Gear") {
            totalHeight = 14.5;
            difference() {
                driveGear(totalHeight);
                translate_z(1)
                    shaftCutout(totalHeight - 1);
                translate_z(gearThickness + 3.5 + 5)
                    poly_cylinder(r=5/2, h=3 + eps);
            }
        }
}

module Drive_Gear_Hex_stl() {
    color(pp2_colour)
        stl("Drive_Gear_Hex") {
            totalHeight = 20;
            difference() {
                driveGear(totalHeight);
                translate_z(gearThickness)
                    cylinder($fn=6, r=5/2, h=totalHeight - gearThickness + eps, center=false);
            }
        }
}

module Reduction_Gear_stl() {
    color(pp1_colour)
        stl("Reduction_Gear") {
            recessDepth = 0.5;
            difference() {
                union() {
                    rotate(180/reductionToothCount)
                        gear(reductionToothCount, recessDepth=recessDepth);
                    rotate(0.5*180/(reductionToothCount/4))
                        translate_z(gearThickness - recessDepth)
                            gear(reductionToothCount/4, thickness=3.5 + recessDepth);
                    cylinder(r=reductionGearShaftDiameter()/2, h=reductionGearShaftLength());
                }
                translate_z(-eps)
                    cylinder(r=M3_clearance_radius, h=reductionGearShaftLength() + 2*eps);
            }
        }
}

module Hour_Gear_stl() {
    color(pp3_colour)
        stl("Hour_Gear") {
            centerRadius = driveShaftRadius + 0.25;
            gear(30, centerRadius=centerRadius, thickness=gearThickness, recessDepth=0.5);
            tube(or=centerRadius + 2, ir=centerRadius, h=gearThickness + 0.5, center=false);
        }
}

module tenons(tolerance=0) {
    for (tenonAngle = [30, -30]) {
        tenonPos = [(_clockID + _clockOD)/4*sin(tenonAngle), -(_clockID + _clockOD)/4*cos(tenonAngle), 0];
        tenonSize = [6 + tolerance,
            _clockOD/2 + tenonPos.y + 15 + (tolerance ? 2 : 0),
             4 + tolerance/2];
        translate(tenonPos)
            difference() {
                translate([-tenonSize.x/2, -tenonSize.y, 0])
                    rounded_cube_xy(tenonSize, tolerance ? 0 : 1);
                if (tolerance==0  && tenonAngle == -30)
                    translate([0, -8, 0])
                        boltHole(M3_tap_radius*2, 3.5, twist=4);
            }
        if (tolerance && tenonAngle == -30)
            translate(tenonPos - [0, 8, 0])
                vflip()
                    hull() {
                        for (y = [0.75, -0.75])
                            translate([0, y, 0])
                                boltHole(M3_clearance_radius*2, 2.5 + eps, horizontal=true, rotate=180);
                    }
    }
}

module tube(or, ir, h, center = true) {
    linear_extrude(h, center = center, convexity = 5)
        difference() {
            circle(or, $fn=360);
            circle(ir, $fn=360);
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
                rotate_extrude(angle=housingAngle, $fn=360) {
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
            gear(handsToothCount, _clockID/2, faceThickness - 0.5);
            tube(or=_clockID/2 + 1, ir=_clockID/2, h=faceThickness, center=false);
            if (highlight)
                #tube(or=_clockOD/2, ir=_clockID/2, h=clockHandRingThickness(), center=false);
            else
                tube(or=_clockOD/2, ir=_clockID/2, h=clockHandRingThickness(), center=false);
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
            gear(handsToothCount, _clockID/2, faceThickness - 0.5);
            tube(or=_clockID/2 + 1, ir=_clockID/2, h=faceThickness, center=false);
            if (highlight)
                #tube(or=_clockOD/2, ir=_clockID/2, h=clockHandRingThickness(), center=false);
            else
                tube(or=_clockOD/2, ir=_clockID/2, h=clockHandRingThickness(), center=false);
            handSize = [_clockID/2 + 0.5, 4, 4];
            rotate(90)
                translate([0, -handSize.y/2, 0])
                    cube(handSize);
            cylinder(r=handSize.y/2, h=handSize.z);
        }
}

module Clock_Face_assembly(clockFace=true, hourHand=true, minuteHand=true, transparent=false)
assembly("Clock_Face") {

    explode = 40;
    translate([0, -clockOffsetY(), clockPosZ() + 4*eps])
        rotate([90, 0, 0]) {
            if (hourHand)
                translate_z(2*faceThickness + baseTopTolerance()/4)
                    hflip()
                        explode(-explode)
                            stl_colour(pp2_colour)
                                Hour_Hand_stl(highlight=!clockFace);
            if (minuteHand)
                translate_z(3*faceThickness + 2*baseTopTolerance()/4)
                    hflip()
                        explode(-2*explode)
                            stl_colour(pp3_colour)
                                Minute_Hand_stl(highlight=!hourHand);
            if (clockFace)
                if (transparent)
                    color(pp1_colour, 0.7)
                        Clock_Face_stl();
                else
                    stl_colour(pp1_colour)
                        Clock_Face_stl();
        }
}

module gears(stepper=true, reduction=false, transparent=false) {
    explode = 20;
    *hidden()
        Drive_Gear_Hex_stl();
    if (reduction)
        rotate(gearRotate)
            translate([0, -reductionGearOffset(), -2*gearThickness() + 0.25])
                stl_colour(pp1_colour)
                    Reduction_Gear_stl();
    translate_z(-gearThickness() + 0.5) {
        explode(-2*explode)
            translate_z(-gearThickness()-3.5)
                 stl_colour(pp2_colour)
                    Drive_Gear_stl();
        explode(-explode)
            translate_z(0.1)
                if (transparent)
                    color(pp3_colour, 0.4)
                        Hour_Gear_stl();
                else
                    stl_colour(pp3_colour)
                        Hour_Gear_stl();
    }
    if (stepper)
        translate_z(7.5)
            geared_stepper(28BYJ_48);
}

module gearReduction() {
    translate([0, clockOffsetY() + faceThickness, driveGearPosZ()])
        rotate([90, 0, 0])
            rotate(gearRotate)
                translate([0, -reductionGearOffset(), -2*gearThickness() + 0.25])
                    explode([40, 40, 0])
                    stl_colour(pp1_colour)
                        Reduction_Gear_stl();
}

module Gears_assembly(stepper=true, reduction=false, transparent=false)
assembly("Gears") {
    translate([0, clockOffsetY() + faceThickness, driveGearPosZ()])
        rotate([90, 0, 0])
            gears(stepper=stepper, reduction=reduction, transparent=transparent);
}
