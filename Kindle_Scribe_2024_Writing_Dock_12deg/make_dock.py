"""Kindle Scribe 2024 writing dock: parametric, no supports, printable on QIDI Plus5.
Run: python make_dock.py
Requires cadquery. All measurements in millimetres.
"""
import cadquery as cq
from pathlib import Path
import math

OUTPUT=Path(__file__).resolve().parent
# Kindle Scribe 2024 (64GB, Metallic Jade), 196 x 230 x 5.7 mm
KINDLE_W=196.0
KINDLE_L=230.0
KINDLE_T=5.7
PEN_L=162.0
PEN_D=8.8

# Adjust for comfort: default 12-degree writing slope
ANGLE_DEG=12.0
FRONT_RISE=8.0
SUPPORT_COUNT=3

# Print dimensions
PLATE_W=210.0    # main support; USB-C and power buttons remain accessible at left
PLATE_L=244.0
PLATE_THICK=4.5
TRAY_W=30.0
TRAY_START_X=208.0  # small overlap for solid union
TRAY_START_Y=30.0
TRAY_END_Y=219.0
TRAY_H=12.0
RAIL_THICK=15.0
RAIL_CENTERS=(23.0, 105.0, 187.0)

# Rounded flat panel: printed underside on bed, without supports.
plate=(cq.Workplane('XY').center(PLATE_W/2,PLATE_L/2)
       .rect(PLATE_W,PLATE_L).extrude(PLATE_THICK).edges('|Z').fillet(6.0))
# Right-hand pen rest (long enough for the 162-mm Premium Pen, open top).
tray=(cq.Workplane('XY').box(TRAY_W,TRAY_END_Y-TRAY_START_Y,TRAY_H,centered=(False,False,False))
      .translate((TRAY_START_X,TRAY_START_Y,0)))
tray=tray.edges('|Z').fillet(4.0)
plate=plate.union(tray)
# 169-mm open semicircular channel, smooth radius > pen radius
pen_channel=cq.Solid.makeCylinder(7.5,169.0,
                                 cq.Vector(223.0,40.0,13.5), cq.Vector(0,1,0))
plate=plate.cut(pen_channel)
# Relief for thumb to lift the pen out of its trough.
thumb=cq.Solid.makeCylinder(14.0,10.0,
                            cq.Vector(241.0,124.5,8.5), cq.Vector(0,0,1))
plate=plate.cut(thumb)
# Two low, rounded anti-slide tabs touch Kindle bottom edge, not its screen.
for cx in (42.0,167.0):
    lip=(cq.Workplane('XY').center(cx,5.5).rect(25.0,5.0).extrude(4.8)
         .translate((0,0,PLATE_THICK)).edges('|Z').fillet(1.8))
    plate=plate.union(lip)
# Shallow top recesses for optional self-adhesive 1-2mm silicone/felt dots.
for px in (21.0,104.0,190.0):
    for py in (25.0,221.0):
        recess=cq.Solid.makeCylinder(6.0,0.8,
                       cq.Vector(px,py,PLATE_THICK-0.7),cq.Vector(0,0,1))
        plate=plate.cut(recess)
plate=plate.clean()

# Side rail is printed lying flat: XY = (rail forward length, its height), Z=15 mm.
# At assembly the rail is rotated 120 degrees about [1,1,1], becoming an upright wedge.
a=math.radians(ANGLE_DEG)
run=PLATE_L*math.cos(a)
rear_rise=FRONT_RISE+PLATE_L*math.sin(a)
rail=(cq.Workplane('XY').polyline([(0,0),(run,0),
             (run,rear_rise),(0,FRONT_RISE)]).close().extrude(RAIL_THICK))
# Two lightweight truss voids, carefully retaining >6mm material around edges.
def opening(points):
    return cq.Workplane('XY').polyline(points).close().extrude(RAIL_THICK+2).translate((0,0,-1))
# coordinates use fractions of rail run and rail top-height
for u0,u1 in ((0.265,0.52),(0.59,0.90)):
    y0,y1=run*u0,run*u1
    top0=FRONT_RISE+(rear_rise-FRONT_RISE)*u0
    top1=FRONT_RISE+(rear_rise-FRONT_RISE)*u1
    rail=rail.cut(opening([(y0,4.5),(y1,4.5),(y1,top1-7.5),(y0,top0-7.5)]))
rail=rail.clean()

# Export two printable parts. Print rail.stl 3 times with large face down.
cq.exporters.export(plate, str(OUTPUT/'kindle_scribe_2024_writing_plate.stl'),
                    exportType='STL', tolerance=0.08, angularTolerance=0.15)
cq.exporters.export(rail, str(OUTPUT/'kindle_scribe_2024_wedge_rail_print_3.stl'),
                    exportType='STL', tolerance=0.08, angularTolerance=0.15)
cq.exporters.export(plate, str(OUTPUT/'kindle_scribe_2024_writing_plate.step'))
cq.exporters.export(rail, str(OUTPUT/'kindle_scribe_2024_wedge_rail.step'))

# Build a reference assembled STEP (for 3D CAD software), with rail tops flush to plate.
assy = cq.Assembly(name='Kindle_Scribe_2024_Writing_Dock')
plate_loc=cq.Location(cq.Vector(0,0,FRONT_RISE),cq.Vector(1,0,0),ANGLE_DEG)
assy.add(plate, name='backing_plate_and_pen_tray', loc=plate_loc,
         color=cq.Color(0.20,0.26,0.24))
rail_rot=cq.Location(cq.Vector(0,0,0),cq.Vector(1,1,1),120)
for i,xc in enumerate(RAIL_CENTERS):
    rloc=cq.Location(cq.Vector(xc-RAIL_THICK/2,0,0))*rail_rot
    assy.add(rail,name=f'support_rail_{i+1}',loc=rloc,color=cq.Color(0.26,0.30,0.28))
assy.save(str(OUTPUT/'kindle_scribe_2024_assembled.step'))

print('Plate dimensions:', PLATE_W+TRAY_W-2, 'x', PLATE_L, 'mm; max Z',TRAY_H)
print('Rail footprint:', round(run,1),'x',round(rear_rise,1),'x',RAIL_THICK,'mm; 3 copies')
print('Assembled writing angle:',ANGLE_DEG,'degrees')
print('Final height at rear:',round(rear_rise+PLATE_THICK*math.cos(a),1),'mm')
print('Done')
