// Parameters for the box dimensions
box_length = 14;  // Length of the box (cm)
box_width = 7.5;    // Width of the box (cm)
box_height = 5; // Height of the box (cm)
wall_thickness = 0.2; // Thickness of the walls (cm)

// Parameters for the camera module (unused for holes, kept for reference)
camera_size = 4;    // Width and height of the camera module (cm)
camera_depth = 2.8;   // Depth of the lens protrusion (cm)
camera_offset_z = box_height / 2; // Center the camera vertically on the front face

// Tolerance for fitting parts
tolerance = 0.002; // Small tolerance for snug fit (cm)

// Parameters for the camera mounts (ledges)
ledge_thickness = 0.2; // Thickness of the supporting ledges (cm)
ledge_depth = 1.0;     // Depth of the ledges (cm)

// Parameters for the access holes on the side walls (for mounts)
hole_width = 1.0;      // Width of the hole along the X-axis (cm)
hole_height = 2.0;     // Height of the hole along the Z-axis (cm)
hole_depth = wall_thickness + tolerance; // Depth to cut through the wall (Y-axis)

// Parameters for the large holes on the side walls
large_hole_length = (box_length - 2 * wall_thickness) * 0.4; // 40% of internal length (approx. 5.44 cm)
large_hole_height = (box_height - 2 * wall_thickness - 2 * tolerance) / 2; // Half of the original height (approx. 2.29 cm)

// Parameters for the snap-on lid
lid_thickness = 0.2; // Thickness of the lid (cm)
snap_clearance = 0.05; // Clearance for the lid to fit over the walls (cm)
snap_hook_width = 1.0; // Width of the snap hooks (cm)
snap_hook_depth = 0.1; // Depth of the snap hooks (protrusion inward, cm)
snap_hook_height = 0.2; // Height of the snap hooks (cm)
snap_recess_depth = snap_hook_depth + tolerance; // Depth of the recess in the walls (cm)
snap_recess_height = snap_hook_height + tolerance; // Height of the recess (cm)
snap_recess_width = snap_hook_width + tolerance; // Width of the recess (cm)

// Parameters for the I/O port hole on the back wall
io_port_width = 3.0; // Width of the I/O port hole (cm) - increased from 2.0 to 3.0
io_port_height = 1.5; // Height of the I/O port hole (cm) - increased from 1.0 to 1.5
io_port_offset_z = wall_thickness + 0.5; // Distance from the bottom of the enclosure (cm)

// Parameters for the PCB
pcb_length = 8.0;     // Length of the PCB (cm)
pcb_width = 6.0;      // Width of the PCB (cm)
pcb_thickness = 0.16; // Thickness of the PCB (cm)
pcb_offset_x = 5.0;   // Distance from the front wall (where camera is) to PCB front edge (cm)
pcb_offset_y = (box_width - pcb_width) / 2; // Center the PCB along the width
pcb_height = 1.0;     // Height from the bottom of the enclosure to bottom of PCB (cm)

// Parameters for PCB mounting posts
post_diameter = 0.5;  // Diameter of the mounting posts (cm)
post_height = pcb_height;  // Height of the mounting posts (cm)
mounting_hole_diameter = 0.3; // Diameter of the mounting holes in PCB (cm)
mounting_hole_inset = 0.5; // Distance from edge of PCB to center of mounting hole (cm)

// Parameters for the antennas
antenna_hole_diameter = 0.6; // Diameter of the hole for the antenna connector (cm)
antenna_spacing = 2.0; // Spacing between the two antennas (cm)
antenna_height = box_height - wall_thickness - 0.5; // Position antennas near the top of the back wall (cm)
antenna_length = 5.0; // Length of the antenna for visualization (cm)
antenna_diameter = 0.2; // Diameter of the antenna rod for visualization (cm)

// Main module to assemble the entire design
module webcam_enclosure() {
    // Color the box silver
    color("silver") {
        difference() {
            // Create the outer shell of the box (without top)
            outer_box();
            
            // Hollow out the interior (without top)
            translate([wall_thickness, wall_thickness, wall_thickness])
                inner_box();
            
            // Cutout for the camera on the front face
            camera_cutout();
            
            // Large cutout for the left side wall
            large_left_hole();
            
            // Large cutout for the right side wall
            large_right_hole();
            
            // Add smaller holes on both side walls to see/access the mounts
            side_holes();
            
            // Add recesses for the snap hooks
            snap_recesses();
            
            // Add I/O port hole on the back wall
            io_port_hole();
            
            // Add antenna holes on the back wall
            antenna_holes();
        }
    }
    
    // Add internal mounting structure for the camera (yellow)
    color("yellow")
        camera_mount();
    
    // Add PCB mounting posts (yellow)
    color("yellow")
        pcb_mounting_posts();
}

// Module for the outer shell of the box (without top)
module outer_box() {
    difference() {
        // Full cube
        cube([box_length, box_width, box_height]);
        // Remove the top face by cutting out a block above the top edge
        translate([-tolerance, -tolerance, box_height - tolerance])
            cube([box_length + 2 * tolerance, box_width + 2 * tolerance, tolerance + 1]);
    }
}

// Module for the inner hollow part of the box (without top)
module inner_box() {
    cube([box_length - 2 * wall_thickness, 
          box_width - 2 * wall_thickness, 
          box_height]); // Extend past box_height to ensure the top is open
}

// Module for the camera cutout on the front face
module camera_cutout() {
    translate([-tolerance, 
               (box_width - camera_size) / 2, 
               camera_offset_z - camera_size / 2])
        cube([wall_thickness + 2 * tolerance, 
              camera_size, 
              camera_size]);
}

// Module for the internal camera mounting structure (colored yellow)
module camera_mount() {
    // Internal height of the box (from floor to top of side walls)
    internal_height = box_height - wall_thickness; // Since top is open, only bottom wall thickness matters
    
    // Left ledge
    translate([wall_thickness, 
               (box_width - camera_size) / 2 - ledge_thickness, 
               wall_thickness]) // Start at the floor
        cube([ledge_depth, 
              ledge_thickness, 
              internal_height - wall_thickness]); // Stop at the top of the side walls
    
    // Right ledge
    translate([wall_thickness, 
               (box_width + camera_size) / 2, 
               wall_thickness]) // Start at the floor
        cube([ledge_depth, 
              ledge_thickness, 
              internal_height - wall_thickness]); // Stop at the top of the side walls
}

// Module for the large hole on the left side wall (Y=0 face)
module large_left_hole() {
    translate([wall_thickness + (box_length - large_hole_length - 2 * wall_thickness) / 2, 
               -tolerance, 
               wall_thickness]) // Aligned to the bottom (Z=wall_thickness)
        cube([large_hole_length, 
              wall_thickness + 2 * tolerance, 
              large_hole_height]);
}

// Module for the large hole on the right side wall (Y=box_width face)
module large_right_hole() {
    translate([wall_thickness + (box_length - large_hole_length - 2 * wall_thickness) / 2, 
               box_width - wall_thickness, // Adjusted to start at the outer edge
               wall_thickness]) // Aligned to the bottom (Z=wall_thickness)
        cube([large_hole_length, 
              wall_thickness + 2 * tolerance, // Ensure it cuts through the wall
              large_hole_height]);
}

// Module for the smaller access holes on both side walls (for mounts)
module side_holes() {
    // Left side hole (Y=0 face)
    translate([wall_thickness, 
               -tolerance, 
               camera_offset_z - hole_height / 2])
        cube([hole_width, 
              hole_depth, 
              hole_height]);
    
    // Right side hole (Y=box_width face)
    translate([wall_thickness, 
               box_width - hole_depth + tolerance, 
               camera_offset_z - hole_height / 2])
        cube([hole_width, 
              hole_depth, 
              hole_height]);
}

// Module to add recesses for the snap hooks on the outer walls
module snap_recesses() {
    // Front wall (X=0 face)
    translate([(box_length - snap_recess_width) / 2, -tolerance, box_height - snap_recess_height])
        cube([snap_recess_width, wall_thickness + 2 * tolerance, snap_recess_height + tolerance]);
    
    // Back wall (X=box_length face)
    translate([(box_length - snap_recess_width) / 2, box_width - wall_thickness - tolerance, box_height - snap_recess_height])
        cube([snap_recess_width, wall_thickness + 2 * tolerance, snap_recess_height + tolerance]);
    
    // Left wall (Y=0 face)
    translate([-tolerance, (box_width - snap_recess_width) / 2, box_height - snap_recess_height])
        cube([wall_thickness + 2 * tolerance, snap_recess_width, snap_recess_height + tolerance]);
    
    // Right wall (Y=box_width face)
    translate([box_length - wall_thickness - tolerance, (box_width - snap_recess_width) / 2, box_height - snap_recess_height])
        cube([wall_thickness + 2 * tolerance, snap_recess_width, snap_recess_height + tolerance]);
}

// Module for the I/O port hole on the back wall (X=box_length face)
module io_port_hole() {
    translate([box_length - wall_thickness - tolerance, 
               (box_width - io_port_width) / 2, 
               io_port_offset_z])
        cube([wall_thickness + 2 * tolerance, 
              io_port_width, 
              io_port_height]);
}

// Module for the antenna holes on the back wall (X=box_length face)
module antenna_holes() {
    antenna_y_offset = (box_width - antenna_spacing) / 2; // Center the two antennas
    
    // Left antenna hole
    translate([box_length - wall_thickness - tolerance, 
               antenna_y_offset, 
               antenna_height])
        rotate([0, 90, 0]) // Rotate to cut through the wall
        cylinder(h=wall_thickness + 2 * tolerance, d=antenna_hole_diameter, $fn=20);
    
    // Right antenna hole
    translate([box_length - wall_thickness - tolerance, 
               antenna_y_offset + antenna_spacing, 
               antenna_height])
        rotate([0, 90, 0]) // Rotate to cut through the wall
        cylinder(h=wall_thickness + 2 * tolerance, d=antenna_hole_diameter, $fn=20);
}

// Module to visualize the antennas (for reference only)
module antenna_visualization() {
    antenna_y_offset = (box_width - antenna_spacing) / 2; // Same offset as the holes
    
    // Left antenna
    translate([box_length, 
               antenna_y_offset, 
               antenna_height])
        color("black")
        cylinder(h=antenna_length, d=antenna_diameter, $fn=20);
    
    // Right antenna
    translate([box_length, 
               antenna_y_offset + antenna_spacing, 
               antenna_height])
        color("black")
        cylinder(h=antenna_length, d=antenna_diameter, $fn=20);
}

// Module for PCB mounting posts (colored yellow)
module pcb_mounting_posts() {
    // Front-left post
    translate([pcb_offset_x + mounting_hole_inset, 
               pcb_offset_y + mounting_hole_inset, 
               wall_thickness])
        cylinder(h=post_height, d=post_diameter, $fn=20);
    
    // Front-right post
    translate([pcb_offset_x + mounting_hole_inset, 
               pcb_offset_y + pcb_width - mounting_hole_inset, 
               wall_thickness])
        cylinder(h=post_height, d=post_diameter, $fn=20);
    
    // Back-left post
    translate([pcb_offset_x + pcb_length - mounting_hole_inset, 
               pcb_offset_y + mounting_hole_inset, 
               wall_thickness])
        cylinder(h=post_height, d=post_diameter, $fn=20);
    
    // Back-right post
    translate([pcb_offset_x + pcb_length - mounting_hole_inset, 
               pcb_offset_y + pcb_width - mounting_hole_inset, 
               wall_thickness])
        cylinder(h=post_height, d=post_diameter, $fn=20);
}

// Module to visualize the PCB (already green)
module pcb_visualization() {
    translate([pcb_offset_x, pcb_offset_y, wall_thickness + post_height])
        color("green")
        cube([pcb_length, pcb_width, pcb_thickness]);
}

// NEW: Module to visualize the camera with a lens
module camera_visualization() {
    // Position the camera at the same location as before
    translate([wall_thickness, (box_width - camera_size) / 2, camera_offset_z - camera_size / 2]) {
        // Camera body (blue cube)
        color("blue")
            cube([camera_depth, camera_size, camera_size]);
        
        // Lens (black cylinder) on the front face
        lens_diameter = camera_size * 0.4; // Lens diameter is 40% of camera width for proportion
        lens_length = 1; // Lens protrudes 0.5 cm from the front
        translate([camera_depth, camera_size / 2, camera_size / 2]) // Center the lens on the front face
            rotate([0, 90, 0]) // Rotate to protrude outward along X-axis
            color("black")
            cylinder(h=lens_length, d=lens_diameter, $fn=30);
    }
}

// Module for the snap-on lid (keeping it silver to match the box)
module lid() {
    color("silver") {
        // Main lid body
        difference() {
            // Basic lid plate
            translate([-snap_clearance, -snap_clearance, 0])
                cube([box_length + 2 * snap_clearance, box_width + 2 * snap_clearance, lid_thickness]);
            
            // Optional: Add a small chamfer or fillet on the edges for aesthetics (not implemented here)
        }
        
        // Add snap hooks on the underside of the lid
        // Front snap hook
        translate([(box_length - snap_hook_width) / 2, -snap_clearance, lid_thickness])
            cube([snap_hook_width, snap_hook_depth, snap_hook_height]);
        
        // Back snap hook
        translate([(box_length - snap_hook_width) / 2, box_width + snap_clearance - snap_hook_depth, lid_thickness])
            cube([snap_hook_width, snap_hook_depth, snap_hook_height]);
        
        // Left snap hook
        translate([-snap_clearance, (box_width - snap_hook_width) / 2, lid_thickness])
            cube([snap_hook_depth, snap_hook_width, snap_hook_height]);
        
        // Right snap hook
        translate([box_length + snap_clearance - snap_hook_depth, (box_width - snap_hook_width) / 2, lid_thickness])
            cube([snap_hook_depth, snap_hook_width, snap_hook_height]);
    }
}

// Render the entire design
webcam_enclosure();

// Render the PCB for visualization (already green)
pcb_visualization();

// Render the antennas for visualization
antenna_visualization();

// Render the lid (positioned along the Y-axis, to the side of the enclosure for visualization)
translate([0, box_width + 2, 0]) // Move the lid along the Y-axis with a 2cm gap
    lid();

// NEW: Visualize the camera with a lens
camera_visualization();