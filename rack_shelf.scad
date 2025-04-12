/**
    Universal(?) Rack shelf builder
    * Create a shelf for any size box you want to fit into a rack
    * Optional notch on top to make room for top-mounted status leds on your box
    * Optional screw holes to fasten your box to the shelf
    * Optional holes for routing cables or attaching keystones on the side of your box
    * Optimized for 10'' racks, but should work with any size as long as you can print it
    License: CC BY-NC-SA 4.0 https://creativecommons.org/licenses/by-nc-sa/4.0/
    Copyright: Dan Malm 2024
    URL: https://github.com/wildegnux/universal-rack-shelf
   
    Inspired from:
        https://www.printables.com/model/128644-unifi-us-8-10-rack-mount
    
    Honeycomb library by Gael Lafond:
        https://www.thingiverse.com/thing:2484395
 */

/* [Rack] */
// Rack size (inches)
rack_size = 10; // [5:20]
// Thickness of front plate
front_plate_thickness = 3.5;
// Corner radius for front plate (0 for no rounded corners)
front_plate_corder_radius = 0;
// Width of overlap over the rail
rail_overlap = 15.875;
// Depth of overlap over the rail
rail_overlap_depth = 0.5;
// Diameter of screwholes for attaching to rack
rail_hole_diameter = 6.1;
// Position of screwholes for attaching to rack
rail_hole_position = "corner"; // ["corner", "center"]
// Elongated rail holes for attaching to racks that are not to spec
rail_hole_elongated = false; // [true, false]

/* [Shelf] */
// width, height, depth
shelf_size = [148, 30.5, 100];
// Radius for shelf hole corners
shelf_hole_corner_radius = 0;
// Thickness of shelf walls
shelf_thickness = 3;
// Size of holes in hexagonal pattern
shelf_hex_diameter = 8;
// Width of walls in hexagonal pattern
shelf_hex_wall = 2;
// X / Y Offset of holes in hexagonal pattern
shelf_hex_offset = [0, 1];
// Depth of shelf ceiling
shelf_top_depth = 20;
// Thickness of shelf ceiling
shelf_top_thickness = 7;

/* [Notch] */
// Notch in top of shelf to display any top status lights
notch = "right"; // ["none", "left", "right", "center"]
// width, height, depth
notch_size = [110, 5, 15];

/* [Shelf screw holes] */
// Amount of screw holes to use
shelf_screw = 0; // [0:5]
// Screw hole position X/Y and size inner / outer
shelf_screw_1 = [10, 15, 3, 8]; // [0:0.1:1000]
// Screw hole position X/Y and size inner / outer
shelf_screw_2 = [70, 15, 3, 8]; // [0:0.1:1000]
// Screw hole position X/Y and size inner / outer
shelf_screw_3 = [10, 10, 3, 8]; // [0:0.1:1000]
// Screw hole position X/Y and size inner / outer
shelf_screw_4 = [10, 10, 3, 8]; // [0:0.1:1000]
// Screw hole position X/Y and size inner / outer
shelf_screw_5 = [10, 10, 3, 8]; // [0:0.1:1000]

/* [Right side keystone / cable holes] */
// Amount of right side keystone holes
keystone_right_count = 0;
// Shape of keystone hole
keystone_right_format = "square"; // ["square", "circle", "hex"]
// Position of right side keystone holes
keystone_right_position = "edge"; // ["shelf", "edge"]
// Width of right side keystone holes
keystone_right_width = 14.7;
// Height of right side square keystone holes (ignored for circle/hex)
keystone_right_height = 19.6;
// Spacing between right side keystone holes
keystone_right_spacing = 10;
// width of indent around right side keystone holes
keystone_right_indent_width = 4;
// Thickness of front plate in right side keystone indents
keystone_right_indent_thickness = 1.5;

/* [Left side keystone / cable holes] */
// Amount of left side keystone holes
keystone_left_count = 0;
// Shape of keystone hole
keystone_left_format = "circle"; // ["square", "circle", "hex"]
// Position of left side keystone holes
keystone_left_position = "shelf"; // ["shelf", "edge"]
// Width of left side keystone holes
keystone_left_width = 8;
// Height of left side square keystone holes (ignored for circle/hex)
keystone_left_height = 8;
// Spacing between left side keystone holes
keystone_left_spacing = 5;
// width of indent around left side keystone holes
keystone_left_indent_width = 0;
// Thickness of front plate in left side keystone indents
keystone_left_indent_thickness = 1.5;

/* [Hidden] */
rack_width = rack_size * 25.4;
u_height = 44.5;
usable_width = rack_width - rail_overlap * 2;
units = ceil(shelf_size.y / (u_height-shelf_thickness*2));
rack_height = u_height * units;

include <honeycomb.scad>

module cuboid(top, bottom, y, z, center=false) {
    p0 = top > bottom ? [(top - bottom)/2, 0] : [0 ,0];
    p1 = top > bottom ? [0, z] : [(bottom - top)/2, z];
    p2 = top > bottom ? [top, z] : [(bottom - top)/2 + top, z];
    p3 = top > bottom ? [(top - bottom)/2 + bottom, 0] : [bottom, 0];
    longest = top > bottom ? top : bottom;
    t = center ? [-longest/2, y/2, 0] : [0, y, 0];
    translate(t) {
        rotate([90, 0, 0]) {
            linear_extrude(y) {
                polygon([p0, p1, p2, p3]);
            }
        }
    }
}

module honey_shape(wall, honey_dia, honey_wall, honey_offset=[0, 0], honey_max=[700,700]) {
    difference() {
        children();
        difference() {
            offset(r=-wall) {
                children();
            }
            translate([-honey_offset.x, -honey_offset.y]) {
                honeycomb(honey_max.x, honey_max.y, honey_dia, honey_wall);
            }
        }
    }
}

module rsquare(size=[10, 10], radius=2, center=false, $fn=100) {
    if(radius > 0) {
        tx = center == true ? radius - (size.x / 2) : radius;
        ty = center == true ? radius - (size.y / 2) : radius;
        translate( [ tx, ty, 0 ] ) {
            minkowski() {
                square([size.x - 2 * radius, size.y - 2 * radius]);
                circle( radius );
            }
        }
    } else {
        square(size, center=center);
    }
}

difference() {
    union() {
        // Baseplate and holes
        difference() {
            linear_extrude(front_plate_thickness) {
                difference() {
                    // Baseplate
                    rsquare([rack_width, rack_height], front_plate_corder_radius);
                    // Screwholes
                    for (i = [0 : units - 1]) {
                        y_offset = i * u_height;
                        for (y = rail_hole_position == "corner" ? [6.375, 38.125] : [22.25]) {
                            for (x = [7.938, rack_width-7.938]) {
                                translate([x, y_offset + y, 0]) {
                                    if (rail_hole_elongated)
                                    {
                                        hull(){
                                            translate([-2.75,0,0])
                                            circle(d=rail_hole_diameter, $fn=200);
                                            translate([2.75,0,0])
                                            circle(d=rail_hole_diameter, $fn=200);
                                        }
                                    } 
                                    else
                                    {
                                        #circle(d=rail_hole_diameter, $fn=200);
                                    }
                                }
                            }
                        }
                    }
                    // Hole for shelf
                    translate([rack_width / 2, rack_height / 2, 0]) {
                        rsquare([shelf_size.x, shelf_size.y], shelf_hole_corner_radius, center=true);
                    }
                }
            }
            // Rail overlap cutouts
            for(offset=[0,rack_width - rail_overlap]) {
                translate([offset, 0, shelf_thickness - rail_overlap_depth]) {
                    color("red") cube([rail_overlap, units * u_height, front_plate_thickness]);
                }
            }
            // Keystone / cable holes
            for (a = ["left", "right"]) {
                center_offset = a == "left" ? (rack_width + shelf_size.x + keystone_left_width)/2 + shelf_thickness + keystone_left_spacing : rack_width / 2 - shelf_size.x / 2 - keystone_right_width / 2 - keystone_right_spacing;
                edge_offset = a == "left" ? rack_width - rail_overlap - keystone_left_width/2 - keystone_left_spacing/2 : rail_overlap + keystone_right_width/2 + keystone_right_spacing/2;
                position = a == "left" ? keystone_left_position : keystone_right_position;
                base_offset = position == "edge" ? edge_offset : center_offset;
                i_base_offset = a == "left" ? keystone_left_width + keystone_left_spacing : keystone_right_width + keystone_right_spacing;
                i_offset = a == "left" ? (position == "edge" ? i_base_offset * -1 : i_base_offset) : (position == "edge" ? i_base_offset : i_base_offset * -1);
                count = a == "left" ? keystone_left_count : keystone_right_count;
                format = a == "left" ? keystone_left_format : keystone_right_format;
                width = a == "left" ? keystone_left_width : keystone_right_width;
                height = a == "left" ? keystone_left_height : keystone_right_height;
                padding = a == "left" ? keystone_left_indent_width : keystone_right_indent_width;
                thickness = a == "left" ? keystone_left_indent_thickness : keystone_right_indent_thickness;
                if (count > 0) {
                    for (i = [0 : count - 1]) {
                        x_offset = base_offset + i * i_offset;
                        translate([x_offset, rack_height / 2, thickness]) {
                            if(format == "square") {
                                color("red") cube([width, height, front_plate_thickness*2], center=true);
                                if(padding > 0) {
                                    translate([0, 0, front_plate_thickness/2]) {
                                        color("blue") cube([width + padding*2, height + padding*2, front_plate_thickness], center=true);
                                    }
                                }
                            }
                            if(format == "circle") {
                                color("red") cylinder(front_plate_thickness*2, d=width, center=true, $fn=200);
                                if(padding > 0) {
                                    translate([0, 0, front_plate_thickness/2]) {
                                        color("blue") cylinder(front_plate_thickness, d=width + padding*2, center=true, $fn=200);
                                    }
                                }
                            }
                            if(format == "hex") {
                                rotate(90) color("red") cylinder(front_plate_thickness*2, d=width, center=true, $fn=6);
                                if(padding > 0) {
                                    translate([0, 0, front_plate_thickness/2]) {
                                        rotate(90) color("blue") cylinder(front_plate_thickness, d=width + padding*2, center=true, $fn=6);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        translate([0, 0, front_plate_thickness]) {
            // Top shelf
            y_padding = (rack_height - shelf_size.y) / 2;
            x_padding = rack_width/2 - shelf_size.x/2;
            top_thickness = shelf_top_thickness <= y_padding ? shelf_top_thickness : y_padding;
            top_width = shelf_size.x + shelf_thickness * 2;
            top_width2 = top_width * 2.2 < usable_width ? top_width * 2.2 : usable_width;
            translate([
                rack_width/2 - top_width2 / 2,
                y_padding + shelf_size.y,
                0
            ]) {
                cuboid(top_width, top_width2, top_thickness, shelf_top_depth);
            }
            // Bottom shelf
            translate([x_padding - shelf_thickness, y_padding, 0]) {
                rotate([90, 0, 0]) {
                    union() {
                        difference() {
                            linear_extrude(shelf_thickness) {
                                honey_shape(shelf_thickness, shelf_hex_diameter, shelf_hex_wall, honey_offset=shelf_hex_offset) {
                                    square([shelf_size.x+shelf_thickness*2, shelf_size.z]);
                                }
                            }
                            // Screw hole holes
                            if(shelf_screw > 0) {
                                for(i = [1:shelf_screw]) {
                                    h = i == 1 ? shelf_screw_1 : i == 2 ? shelf_screw_2 : i == 3 ? shelf_screw_3 : i == 4 ? shelf_screw_4 : shelf_screw_5;
                                    translate([h.x + shelf_thickness, h.y - front_plate_thickness, shelf_thickness/2]) {
                                        color("red") cylinder(h=shelf_thickness, d=h[3], center=true, $fn=200);
                                    }
                                }
                            }
                        }
                    }
                    // Screw holes
                    // Screw hole holes
                    if(shelf_screw > 0) {
                        for(i = [1:shelf_screw]) {
                            h = i == 1 ? shelf_screw_1 : i == 2 ? shelf_screw_2 : i == 3 ? shelf_screw_3 : i == 4 ? shelf_screw_4 : shelf_screw_5;
                            translate([h.x + shelf_thickness, h.y - front_plate_thickness, shelf_thickness/2]) {
                                color("green") {
                                    difference() {
                                        cylinder(h=shelf_thickness, d=h[3], center=true, $fn=200);
                                        cylinder(h=shelf_thickness, d=h[2], center=true, $fn=200);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // Sides
            for(a = [0:1]) {
                d = a*shelf_size.x + a*shelf_thickness;
                translate([x_padding + d, y_padding, 0]) {
                    rotate([0, -90, 0]) {
                        linear_extrude(shelf_thickness) {
                            honey_shape(shelf_thickness, shelf_hex_diameter, shelf_hex_wall, honey_offset=shelf_hex_offset) {
                                polygon([[0, 0],[0, shelf_size.y], [shelf_top_depth, shelf_size.y], [shelf_size.z, 0]]);
                            }
                        }
                    }
                }
                // Support triangles
                t1 = y_padding - shelf_thickness;
                t1_l = t1*4 <= shelf_size.z ? t1*4 : shelf_size.z;
                translate([x_padding + d, 0, 0]) {
                    rotate([0, -90, 0]) {
                        linear_extrude(shelf_thickness) {
                            polygon([[0, 0], [0, t1], [t1_l, t1]]);
                        }
                    }
                }
                t2_lmax = (usable_width - shelf_size.x - shelf_thickness*2) / 2;
                t2 = shelf_size.z * 0.7 >= 25 ? shelf_size.z * 0.7 : shelf_size.z;
                t2_l = 25 <= t2_lmax ? 25 : t2_lmax;
                t2_offset = a * (t2_l * 2 + shelf_thickness * 2 + shelf_size.x);
                translate([x_padding - t2_l - shelf_thickness +t2_offset, y_padding, 0]) {
                    mirror([0,a,0]) {
                        rotate([a?-90:90, 180*a, 0]) {
                            linear_extrude(shelf_thickness) {
                                honey_shape(shelf_thickness, shelf_hex_diameter, shelf_hex_wall, honey_offset=shelf_hex_offset) {
                                    polygon([[0, 0], [t2_l, t2], [t2_l, 0]]);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    // Notch
    if(notch != "none") {
        notch_offset = 
            notch == "left" ? rack_width/2 + shelf_size.x/2 - notch_size.x - shelf_hole_corner_radius : 
            notch == "right" ? rack_width/2 - shelf_size.x/2 + shelf_hole_corner_radius :
            /*center*/ rack_width/2 - notch_size.x/2;
        translate([notch_offset, rack_height/2 + shelf_size.y/2, notch_size.z]) {
            color("red") rotate([0, 90, 0]) linear_extrude(notch_size.x) polygon([[0,0], [notch_size.z, notch_size.y], [notch_size.z, 0]]);
        }
    }
}
