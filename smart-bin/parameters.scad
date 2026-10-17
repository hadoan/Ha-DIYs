// Smart-bin CAD parameters, millimetres.
// PROVISIONAL: these are catalogue values, not measurements of the user's servo.
// Measure the actual unit and adjust before printing the fit test.
servo_model = "SG90"; // "SG90" or "MG90S"
servo_body_x = servo_model == "MG90S" ? 22.8 : 23.0;
servo_body_y = 12.2;
servo_body_z = servo_model == "MG90S" ? 28.5 : 29.0;

// PROVISIONAL: measure across the two mounting-ear hole centres.
servo_ear_hole_pitch = 28.0;
// PROVISIONAL: verify that an M2 screw passes through the actual ears.
servo_ear_screw_d = 2.2;

// Fit-test coupon parameters. Tune clearance from the printed test, not a nominal CAD fit.
body_clearance_per_side = 0.30;
coupon_end_margin = 8.0;
coupon_side_margin = 4.0;
coupon_thickness = 3.2; // 16 layers at 0.2 mm
coupon_corner_radius = 2.0;

// Bin envelope. The 3 mm value was measured on one wall only; the side-rim
// cross-section has NOT been measured.
bin_outer_width = 140;
bin_outer_depth = 140;
bin_outer_height = 200;
rim_thickness = 3.0; // MEASURED at the earlier test location, not the whole side rim
clamp_gap = 3.4; // requested first-prototype clearance, before added soft liner
rim_vertical_grip_depth = 15.0; // PROVISIONAL
rim_top_z = -6.0; // PROVISIONAL below hinge; verify lid clearance
rim_underlip_depth = 0; // PROVISIONAL; profile unknown
clamp_width = 22;
clamp_wall = 4.0;
clamp_bridge = 4.0;
clamp_screw_d = 3.4; // M3 clearance
clamp_nut_af = 5.8; // M3 nut pocket, tune to actual nut
clamp_nut_depth = 2.8;

// Side mounting concept, all side-rim dimensions PROVISIONAL until measured.
mount_side = "right"; // "right" or "left", viewed from the front of the bin
side_rim_wall_thickness = 3.0; // PROVISIONAL; do not infer from rim_thickness
side_rim_top_width = 10.0; // PROVISIONAL outer edge to opening
side_clamp_wall_center_from_outer_edge = 1.5; // PROVISIONAL, measured on side rim
side_rim_grip_depth = 15.0; // PROVISIONAL available straight wall below top
side_clamp_gap = side_rim_wall_thickness + 0.4; // PROVISIONAL unlined fit
side_clamp_wall = 4.0;
side_clamp_bridge = 3.0;
side_clamp_length = 22.0; // along depth X
side_clamp_start_x = 12.0; // PROVISIONAL distance inward from hinge plane
side_rim_top_z = -6.0; // PROVISIONAL relative to hinge axis
side_clamp_nut_af = 5.8;
side_clamp_nut_depth = 2.8;
side_clamp_screw_d = 3.4;
side_servo_plate_outset = 4.0; // PROVISIONAL outward from outside jaw
side_servo_shaft_x = 35.0; // PROVISIONAL inward from hinge plane
side_servo_shaft_z = -34.0; // PROVISIONAL below hinge axis
side_servo_plate_thickness = 4.0;
side_servo_plate_margin = 6.0;
lid_edge_inset = 10.0; // PROVISIONAL lid edge from bin outer side
hinge_side_inset = 4.0; // PROVISIONAL hinge-knuckle centre from outer side
hinge_knuckle_radius = 2.5; // PROVISIONAL
hinge_knuckle_length = 5.0; // PROVISIONAL along hinge axis

// LEGACY linkage/attachment study below. These values do not locate the new
// side mount and must be remeasured/recalculated before linkage export.
// Servo axis is parallel to bin width (world Y).
servo_ear_pilot_d = 1.6; // PROVISIONAL for original self-tapping screws
servo_shaft_offset_x = -7.0; // PROVISIONAL, from body centre to shaft
servo_shaft_x = 28.0; // PROVISIONAL, inward from rear hinge plane
servo_shaft_z = -32.0; // PROVISIONAL, below hinge axis
servo_plate_thickness = 4.0;
servo_plate_margin = 6.0;
servo_plate_center_z = servo_shaft_z;

// Planar linkage. World X points into bin, Z points upward.
hinge_axis_x = 0; // PROVISIONAL datum, not measured on bin
hinge_axis_y = 30; // PROVISIONAL lateral placement
hinge_axis_z = 0; // PROVISIONAL datum
// CONFIRMED by user: lid seats inside the top opening. Its exact inset depth
// relative to hinge axis is still UNMEASURED; assembly uses a hinge-datum plane.
lid_thickness = 3.5; // PROVISIONAL
lid_open_angle = 90; // ESTIMATED maximum
commanded_lid_open_angle = 85; // PROVISIONAL target short of estimated stop
lid_pivot_x = 14.0; // PROVISIONAL, in closed-lid local coordinates
lid_pivot_z = -8.0; // PROVISIONAL, below closed lid underside
horn_pivot_radius = 14.0; // PROVISIONAL; must match a hole in the original horn
link_length = 39.0; // PROVISIONAL centre-to-centre, computed for this layout
link_width = 10.4; // full dogbone width; 5.2 mm reinforced end radius
link_thickness = 3.2;
pivot_hole_d = 2.4; // M2 loose-running hole; tune after print
lid_existing_hole_x = 25.0; // PROVISIONAL, relative to hinge
lid_existing_hole_d = 2.4; // PROVISIONAL, verify existing hole
lid_attachment_y = 30.0; // PROVISIONAL, from rear-corner hinge along width
lid_pad_thickness = 3.2;
horn_plane_y = 25.0; // PROVISIONAL, first face of original horn
horn_preview_thickness = 1.5; // PROVISIONAL
rod_outer_y = 32.0; // PROVISIONAL, far face of the printed rod
lid_tab_near_offset_y = 4.0; // first lid-tab face beyond lid_attachment_y

// Stage 2A six-bar bell-crank feasibility study, all values PROVISIONAL.
// World X points into the bin; X<0 is behind it. Z=0 is the hinge axis.
bell_lid_pivot_x = 25.0; // local to original lid, above the closed lid
bell_lid_pivot_z = 9.0;
bell_pivot_x = -26.0;
bell_pivot_z = 36.0;
bell_upper_arm_radius = 25.0;
bell_lower_arm_radius = 16.0;
bell_arm_included_angle = -98.0; // signed clockwise from upper to lower arm
bell_upper_rod_length = 40.0;
bell_servo_x = -60.0;
bell_servo_z = -23.0;
servo_body_front_y = -9.0; // PROVISIONAL current holder case-face plane
holder_shaft_at_positive_y = true; // USER FIT FEEDBACK: servo fits this holder only reversed
// This physical orientation is not yet coupled to the stage2 planar solver.
bell_horn_radius = 14.0; // must match a real original-horn hole
bell_lower_rod_length = 65.0;
bell_upper_solution_branch = 1; // +acos branch; 1 or -1
bell_servo_solution_branch = 1; // +acos branch; 1 or -1
bell_target_open_angle = 90.0; // approximate, verify physical stop
bell_verified_servo_travel = -1.0; // UNVERIFIED; replace after bench testing SG90
bell_mechanism_y = -2.5; // crank occupies Y=-4.5..-0.5 beside support cheek
bell_crank_thickness = 4.0;
bell_lower_rod_plane_y = -7.0;
bell_upper_rod_plane_y = 7.0;
bell_rod_thickness = 4.0; // matches the printed stage2 rods
horn_case_gap = 6.0; // USER REPORTED 2026-10-13, underside of installed horn to servo case
// Measurement method and clearance over the raised output boss are unverified.

// Stage 2B rear mounting measurements received 2026-10-12.
rear_flat_width = 100.0; // MEASURED available flat mounting width
rear_flat_height = 100.0; // MEASURED available flat mounting height
rear_rib_height = 5.0; // MEASURED approximate protrusion; position/width unknown
rear_available_mount_width = 120.0; // MEASURED width, NOT a verified strap route
rear_back_surface_x = 0.0; // PROVISIONAL plane relative to hinge datum
rear_plate_width = 70.0; // PROPOSED, within measured 100 mm region
rear_plate_height = 80.0; // PROPOSED, within measured 100 mm region
rear_plate_thickness = 5.0; // PROPOSED
rear_plate_center_z = -55.0; // PROVISIONAL: hinge-to-flat-region datum unknown
rear_plate_standoff = 6.0; // PROPOSED: measured ~5 mm rib + 1 mm nominal relief
rear_plate_corner_radius = 4.0;
rear_plate_slot_pitch = 50.0; // PROPOSED between two optional strap slots
rear_plate_slot_width = 4.0;
rear_plate_slot_height = 21.0; // for PROVISIONAL 20 mm webbing
rear_plate_mount_hole_pitch = 36.0; // PROVISIONAL M3 structure interface
rear_plate_mount_hole_d = 3.4;

// Small clearance gauge: bridge the rib with feet before making the full plate.
rear_rib_test_width = 50.0; // PROPOSED; rib width still unknown
rear_rib_test_height = 24.0;
rear_rib_test_bridge_width = 28.0; // PROPOSED open span; measure actual rib width
rear_rib_test_foot_width = 11.0;
rear_rib_test_base_thickness = 3.2;
stage2_pivot_hole_d = 3.4; // PROVISIONAL FDM M3 running clearance
stage2_rod_width = 9.0;
stage2_rod_thickness = 4.0;
stage2_crank_center_d = 14.0;
stage2_spacer_outer_d = 7.0;
stage2_spacer_height = 2.0;

// Earlier removable rear strap-saddle test, retained unchanged.
rear_pad_width = 56.0; // along bin width
rear_pad_height = 32.0;
rear_pad_thickness = 4.0;
rear_pad_center_z = -55.0;
rear_strap_width = 20.0; // common webbing, confirm actual strap
rear_strap_slot_width = 4.0; // for strap thickness/clearance
rear_strap_slot_height = rear_strap_width + 1.0;
rear_strap_slot_pitch = 38.0;
rear_pad_corner_radius = 3.0;
rear_liner_thickness = 1.0; // PROVISIONAL thin soft liner
