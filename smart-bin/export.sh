#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
mkdir -p exports

python3 mechanism_solver.py
python3 check_horn_clearance.py

for part in servo_fit_test rear_mount_test rear_rib_clearance_test \
            rear_servo_mount bell_crank_support bell_crank \
            pushrod_servo pushrod_lid lid_attachment rear_servo_holder \
            servo_holder_cap rear_stack_pin spacers pivot_fit_pin \
            printed_joint_pin printed_joint_clip horn_fit_gauge horn_gap_gauge; do
  openscad --hardwarnings --export-format binstl \
    -o "exports/$part.stl" "$part.scad"
  python3 check_stl.py "exports/$part.stl"
done

openscad --hardwarnings --export-format binstl \
  -o exports/horn_saddle_test.stl horn_saddle_test.scad
python3 check_stl.py exports/horn_saddle_test.stl --shells 2
openscad --hardwarnings --export-format binstl \
  -o exports/horn_tapered_saddle_test.stl horn_tapered_saddle_test.scad
python3 check_stl.py exports/horn_tapered_saddle_test.stl --shells 2

# Compact horn-connection fit plate, excluding parts the user already printed.
# It is a hand-fit prototype and cannot resolve rod-plane or lid fixing errors.
openscad --hardwarnings --export-format binstl \
  -o exports/remaining_fit_parts.stl remaining_fit_parts.scad
python3 check_stl.py exports/remaining_fit_parts.stl --shells 12
openscad --hardwarnings -o exports/remaining_fit_parts.3mf \
  remaining_fit_parts.scad
openscad --hardwarnings -o exports/remaining_fit_parts_preview.png \
  --imgsize=1000,800 --viewall --autocenter \
  --camera=0,0,0,55,0,35,160 remaining_fit_parts.scad

# Earlier inventory variant, kept reproducible: holder/cap plus horn saddle.
openscad --hardwarnings --export-format binstl \
  -o exports/remaining_holder_horn_fit.stl remaining_holder_horn_fit.scad
python3 check_stl.py exports/remaining_holder_horn_fit.stl --shells 41
openscad --hardwarnings -o exports/remaining_holder_horn_fit.3mf \
  remaining_holder_horn_fit.scad
openscad --hardwarnings -o exports/remaining_holder_horn_fit_preview.png \
  --imgsize=1400,1000 --viewall --autocenter \
  --camera=0,0,0,55,0,35,430 remaining_holder_horn_fit.scad

# Earlier inventory variant, kept reproducible: cap plus horn saddle.
openscad --hardwarnings --export-format binstl \
  -o exports/remaining_cap_horn_fit.stl remaining_cap_horn_fit.scad
python3 check_stl.py exports/remaining_cap_horn_fit.stl --shells 40
openscad --hardwarnings -o exports/remaining_cap_horn_fit.3mf \
  remaining_cap_horn_fit.scad
openscad --hardwarnings -o exports/remaining_cap_horn_fit_preview.png \
  --imgsize=1200,900 --viewall --autocenter \
  --camera=0,0,0,55,0,35,280 remaining_cap_horn_fit.scad

# Corrected inventory: the horn saddle is printed; the servo holder is not.
openscad --hardwarnings --export-format binstl \
  -o exports/remaining_servo_holder_fit.stl remaining_servo_holder_fit.scad
python3 check_stl.py exports/remaining_servo_holder_fit.stl --shells 39
openscad --hardwarnings -o exports/remaining_servo_holder_fit.3mf \
  remaining_servo_holder_fit.scad
openscad --hardwarnings -o exports/remaining_servo_holder_fit_preview.png \
  --imgsize=1200,900 --viewall --autocenter \
  --camera=0,0,0,55,0,35,320 remaining_servo_holder_fit.scad

openscad --hardwarnings -o exports/servo_fit_test_preview.png \
  --imgsize=1000,800 --viewall --autocenter \
  --camera=0,0,0,55,0,35,110 servo_fit_test.scad
openscad --hardwarnings -o exports/servo_ear_fit_instruction.png \
  --imgsize=1200,900 --viewall --autocenter \
  --camera=0,0,0,65,0,35,100 servo_ear_fit_instruction.scad
openscad --hardwarnings -o exports/servo_ear_fit_instruction_top.png \
  --imgsize=1000,800 --viewall --autocenter \
  --camera=0,0,0,0,0,0,90 servo_ear_fit_instruction.scad
openscad --hardwarnings -o exports/rear_mount_test_preview.png \
  --imgsize=1000,800 --viewall --autocenter \
  --camera=0,0,0,55,0,35,110 rear_mount_test.scad
openscad --hardwarnings -o exports/rear_rib_clearance_test_preview.png \
  --imgsize=1000,800 --viewall --autocenter \
  --camera=0,0,0,55,0,35,110 rear_rib_clearance_test.scad
openscad --hardwarnings -o exports/rear_servo_mount_preview.png \
  --imgsize=1000,800 --viewall --autocenter \
  --camera=0,0,0,55,0,35,160 rear_servo_mount.scad
openscad --hardwarnings -o exports/pivot_fit_pin_preview.png \
  --imgsize=800,800 --viewall --autocenter \
  --camera=0,0,0,55,0,35,60 pivot_fit_pin.scad
openscad --hardwarnings -o exports/horn_gap_gauge_preview.png \
  --imgsize=900,900 --viewall --autocenter \
  --camera=0,0,0,55,0,35,120 horn_gap_gauge.scad

# Multi-shell STL for one black-filament prototype plate. Each component
# above is checked individually; this plate must contain exactly 35 shells.
openscad --hardwarnings --export-format binstl \
  -o exports/batch_remaining.stl batch_remaining.scad
python3 check_stl.py exports/batch_remaining.stl --shells 35
openscad --hardwarnings -o exports/batch_remaining_preview.png \
  --imgsize=1400,1000 --viewall --autocenter \
  --camera=0,0,0,55,0,35,560 batch_remaining.scad

# Second prototype plate: servo cradle/cap, corrected lid pad and the printed
# fasteners sized for the three-layer rear stack. This is geometry-only 3MF;
# slicer material, supports and printer settings must be checked in Studio.
openscad --hardwarnings --export-format binstl \
  -o exports/batch_servo_holder_lid.stl batch_servo_holder_lid.scad
python3 check_stl.py exports/batch_servo_holder_lid.stl --shells 84
openscad --hardwarnings -o exports/batch_servo_holder_lid.3mf \
  batch_servo_holder_lid.scad
openscad --hardwarnings -o exports/batch_servo_holder_lid_preview.png \
  --imgsize=1400,1000 --viewall --autocenter \
  --camera=0,0,0,55,0,35,430 batch_servo_holder_lid.scad
openscad --hardwarnings -o exports/horn_saddle_assembly_preview.png \
  --imgsize=1200,900 --viewall --autocenter \
  --camera=0,0,0,65,0,35,240 horn_saddle_assembly_preview.scad
openscad --hardwarnings -o exports/horn_clearance_closed.png \
  --imgsize=1200,900 --viewall --autocenter \
  --camera=0,0,0,60,0,35,240 horn_clearance_study.scad
openscad --hardwarnings -D 'study_angle=90' \
  -o exports/horn_clearance_open.png \
  --imgsize=1200,900 --viewall --autocenter \
  --camera=0,0,0,60,0,35,240 horn_clearance_study.scad
openscad --hardwarnings -D 'exploded=true' \
  -o exports/horn_saddle_exploded_preview.png \
  --imgsize=1200,900 --viewall --autocenter \
  --camera=0,0,0,65,0,35,240 horn_saddle_assembly_preview.scad
openscad --hardwarnings -o exports/servo_holder_assembly_preview.png \
  --imgsize=1200,900 --viewall --autocenter \
  --camera=0,0,0,55,0,35,170 servo_holder_assembly_preview.scad
openscad --hardwarnings -o exports/lid_joint_preview.png \
  --imgsize=1000,800 --viewall --autocenter \
  --camera=0,0,0,60,0,35,150 lid_joint_preview.scad

python3 render_motion.py
