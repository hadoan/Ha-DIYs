#!/usr/bin/env bash
# Stage 3 string-pull mounting prototype; leaves Stage 1/2 exports untouched.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p exports

for entry in \
  'holder:string_main_holder' \
  'servo_coupon:string_servo_ear_coupon' \
  'bolt_spacer:string_rear_bolt_spacer' \
  'corner_pad:string_rear_corner_pad'; do
  part="${entry%%:*}"
  stem="${entry#*:}"
  openscad --hardwarnings --export-format binstl \
    -D "part=\"${part}\"" -o "exports/${stem}.stl" string_main_holder.scad
  python3 check_stl.py "exports/${stem}.stl"
done

openscad --hardwarnings --export-format binstl \
  -D 'part="arm"' -o exports/string_guide_arm.stl string_guide_arm.scad
python3 check_stl.py exports/string_guide_arm.stl
openscad --hardwarnings --export-format binstl \
  -D 'part="standoff"' -o exports/string_guide_arm_standoff.stl string_guide_arm.scad
python3 check_stl.py exports/string_guide_arm_standoff.stl
openscad --hardwarnings --export-format binstl \
  -o exports/string_lid_anchor.stl string_lid_anchor.scad
python3 check_stl.py exports/string_lid_anchor.stl

openscad --hardwarnings --export-format binstl \
  -D 'part="batch"' -o exports/string_mount_batch.stl string_main_holder.scad
python3 check_stl.py exports/string_mount_batch.stl --shells 12
openscad --hardwarnings -D 'part="batch"' \
  -o exports/string_mount_batch.3mf string_main_holder.scad
openscad --hardwarnings -D 'part="batch"' \
  -o exports/string_mount_batch_preview.png --imgsize=1400,1100 \
  --viewall --autocenter --camera=0,0,0,55,0,35,220 string_main_holder.scad
openscad --hardwarnings -D 'part="preview"' \
  -o exports/string_mount_layout.png --imgsize=1600,1200 \
  --viewall --autocenter --camera=0,0,0,55,0,35,230 string_main_holder.scad
openscad --hardwarnings -D 'part="holder"' \
  -o exports/string_mount_drill_face.png --imgsize=1200,1200 \
  --viewall --autocenter --camera=0,0,0,0,0,0,160 string_main_holder.scad

# The supplied 10 mm lid tie and 22 mm eye height are assumptions. This only
# compares line travel; it cannot certify torque, collision or lid closing.
python3 string_motion_check.py
for angle in 0 45 90; do
  openscad --hardwarnings -D "lid_angle=${angle}" \
    -o "exports/string_motion_${angle}.png" --imgsize=1400,1050 \
    --viewall --autocenter --camera=0,0,0,70,0,35,480 \
    string_motion_preview.scad
done
