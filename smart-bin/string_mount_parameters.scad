// Stage 3 string-pull redesign. Millimetres. Edit after physical fit checks.
// The earlier rigid bell-crank files remain unchanged for reference.
include <parameters.scad>

sm_plate_w = 96; // PROPOSED, within measured 100 mm flat rear width
sm_plate_h = 96; // PROPOSED, within measured 100 mm flat rear height
sm_plate_t = 4;
sm_plate_corner_r = 5;
sm_rear_gap = 6; // PROPOSED, ~5 mm rib plus nominal 1 mm clearance
sm_bin_mount_x = 41; // PROVISIONAL: plate becomes rear-wall drilling template
sm_bin_mount_y = 0; // PROVISIONAL: vertical hole datum
sm_bin_slot_d = 3.5; // M3 clearance, tune to real bolt/print
sm_bin_slot_length = 3.5; // round M3 hole; use plate to mark drill positions
sm_bin_wall_t = rim_thickness; // 3 mm measured elsewhere; verify here
sm_m3_clearance = 3.5;
sm_m3_nut_af = 5.8; // PROVISIONAL, check actual nut
sm_m3_nut_pocket_depth = 2.5;

// Component layout on ONE integrated main holder. PROVISIONAL until fitted.
sm_servo_cx = -26;
sm_nano_cx = 20;
sm_nano_cy = 25;
sm_cell_cx = 0;
sm_cell_cy = -26.5;

// Servo shelf: catalogue body envelope from TowerPro; ear pitch UNMEASURED.
sm_servo_body_slot_x = servo_body_x + 0.7;
sm_servo_body_slot_z = servo_body_y + 0.7;
sm_servo_ear_pitch = servo_ear_hole_pitch;
sm_servo_ear_hole_d = servo_ear_screw_d;
sm_servo_finger_t = 5; // along Y
sm_servo_finger_z1 = 33; // from component-facing plate base Z=4
sm_servo_axis_z = 17;
sm_servo_string_radius = 14; // PROVISIONAL horn hole radius
sm_horn_plane_y = 30; // PROVISIONAL distance up plate to the horn plane
sm_horn_closed_deg = 90; // PROVISIONAL, not bench verified
sm_plate_center_world_z = 150; // PROVISIONAL placement on measured rear flat
sm_hinge_world_z = 200; // simplified bin-height hinge datum

// Nano Classic board is published as 45 x 18 mm. The user's board appears
// mounted on another carrier, whose full envelope has NOT been measured.
sm_nano_board_l = 45;
sm_nano_board_w = 18;
sm_nano_pad_h = 3; // clearance for underside solder joints
sm_nano_strap_slot_w = 3.2;

// 21700 dimensions vary by exact cell and holder. This only supports a
// separate insulated cell holder or protected mechanical retention setup.
sm_cell_reference_d = 21.8; // PROVISIONAL generous cell envelope
sm_cell_reference_l = 71.5; // PROVISIONAL generous cell envelope
sm_cell_saddle_l = 82; // PROPOSED integrated rail length
sm_cell_saddle_w = 25;
sm_cell_side_rail_h = 7;
sm_cell_strap_slot_w = 3.2;

// Removable fixed guide arm. This extends above the rear plate; its full
// clearance to the lid has NOT been measured. It is a string guide, not a
// rotating load-bearing lever. The board holes also use M3 hardware.
sm_arm_center_x = sm_servo_cx + sm_servo_string_radius;
sm_arm_base_y = 34;
sm_arm_bolt_pitch = 14;
sm_arm_bolt_y = sm_arm_base_y + 8;
sm_arm_standoff_h = 8; // plate 4 + standoff 8 + arm centre 5 = horn Z 17
sm_arm_t = 10;
sm_arm_tip_y = 72; // PROVISIONAL, 24 mm above 96 mm plate upper edge
sm_string_guide_hole_d = 4;
// String lid anchor position, hinge height and lid mass are UNMEASURED.
// These values only generate a marked hand-fit tab, not a powered design.
sm_lid_anchor_hole_spacing = 40; // PROVISIONAL; fit to the existing lid holes
sm_lid_rear_hole_from_hinge = 20; // PROVISIONAL location of rear existing hole
sm_lid_tie_from_hinge = 10; // PROVISIONAL line tie; travel feasibility depends on it
sm_lid_tie_above_lid = 3; // top-side eye; underside eye crosses lid
sm_lid_anchor_hole_d = 3.5; // only if real holes accept suitable fasteners
sm_lid_anchor_plate_t = 3.2;
sm_lid_anchor_string_d = 2.2; // for ~1 mm nonstretch line; polish printed bore
