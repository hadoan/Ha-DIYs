"""Kindle Scribe 2024 lightweight adjustable desk dock V2.
Units: millimetres. Requires CadQuery 2.8+, trimesh, numpy.
Run: python make_design.py  (writes files alongside this script).
Engineering prototype; revised pen holders require physical fit and load checks.
"""
from pathlib import Path
import math, json, csv
import cadquery as cq
import trimesh
import numpy as np

OUT = Path(__file__).resolve().parent
STL = OUT/'STL'; STEP = OUT/'STEP'
for p in (STL, STEP): p.mkdir(exist_ok=True)
W, H = 210.0, 242.0
THICK = 3.2
BASE_L = 278.0
FRONT_Y, HINGE_Z = 8.0, 8.0
LOCAL_HINGE_Z = -10.0
PROP_Y, PROP_LEN = 200.0, 76.0
PIN_R, FOOT_Z = 3.2, 7.5
HOLE_D = 3.4
PEN_INNER_R = 4.7  # 9.4 mm opening for an 8.8 x 8.4 mm Premium Pen
ANGLES = (8,12,16,20)


def box(x0,x1,y0,y1,z0,z1):
    return cq.Solid.makeBox(x1-x0,y1-y0,z1-z0,cq.Vector(x0,y0,z0))

def cyl_x(x0,x1,y,z,r):
    return cq.Solid.makeCylinder(r,x1-x0,cq.Vector(x0,y,z),cq.Vector(1,0,0))

def cyl_z(x,y,z0,z1,r):
    return cq.Solid.makeCylinder(r,z1-z0,cq.Vector(x,y,z0),cq.Vector(0,0,1))

def fuse(shapes):
    a=shapes[0]
    return a.fuse(*shapes[1:]).clean() if len(shapes)>1 else a

def hinge_ear(x0,x1,y,z,connect_z,r=4.5):
    c=cyl_x(x0,x1,y,z,r)
    if connect_z>z:
        c=c.fuse(box(x0,x1,y-r,y+r,z,connect_z))
    else:
        c=c.fuse(box(x0,x1,y-r,y+r,connect_z,z))
    return c.cut(cyl_x(x0-0.2,x1+0.2,y,z,HOLE_D/2)).clean()


def slots():
    result={}
    for a in ANGLES:
        t=math.radians(a); d=PROP_Y-FRONT_Y
        py=FRONT_Y+d*math.cos(t); pz=HINGE_Z+d*math.sin(t)
        dy=math.sqrt(PROP_LEN**2-(pz-FOOT_Z)**2)
        result[a]={'y':py+dy,'z':FOOT_Z,'upper_y':py,'upper_z':pz,
                   'brace_angle_deg':-math.degrees(math.atan2(pz-FOOT_Z,dy))}
    return result
SLOTS=slots()

# Deck, in assembly-local coordinates: contact face z=0, underside negative.
print('Building honeycomb deck...',flush=True)
deck=box(0,W,0,H,-THICK,0)
hexes=[]
R=11.5; pitchR=14.0; yp=math.sqrt(3)*pitchR
for col in range(11):
    x=24+col*1.5*pitchR
    for row in range(11):
        y=25+row*yp+(yp/2 if col%2 else 0)
        if x-R<10 or x+R>W-10 or y-R*math.sqrt(3)/2<16 or y+R*math.sqrt(3)/2>H-10: continue
        pts=[(x+R*math.cos(math.radians(60*k)),y+R*math.sin(math.radians(60*k))) for k in range(6)]
        hexes.append(cq.Workplane('XY',origin=(0,0,-THICK-1)).polyline(pts).close().extrude(THICK+2).val())
deck=deck.cut(*hexes).clean()
# Continuous ribs run through the contact lattice: no rib bridges over an empty hole.
reinforcements=[box(x-3,x+3,12,H-8,-5.0,0) for x in (15,105,195)]
# Fold-flat stops land on the uncut fronts of the two rear racks.
reinforcements += [box(x-3,x+3,218.5,221.5,-6.0,-4.9) for x in (15,195)]
# Front and rear pivot attachment pads; the rear cross-rib connects both brace hinges.
reinforcements += [box(4,28,0,16,-THICK,0),box(182,206,0,16,-THICK,0),box(20,190,194,206,-5,0)]
# Two small right-side tabs for bolt-on pen cradles.
for y in (50,170): reinforcements.append(box(203,219,y-8,y+8,-THICK,0))
deck=fuse([deck]+reinforcements)
for cx in (15,195):
    for x0,x1 in ((cx-7,cx-3.5),(cx+3.5,cx+7)):
        deck=deck.fuse(hinge_ear(x0,x1,FRONT_Y,LOCAL_HINGE_Z,-2.5))
for cx in (29.5,180.5):
    for x0,x1 in ((cx-7,cx-3.5),(cx+3.5,cx+7)):
        deck=deck.fuse(hinge_ear(x0,x1,PROP_Y,LOCAL_HINGE_Z,-2.5))
for x,y in [(58,3.8),(152,3.8),(214,50),(214,170)]:
    deck=deck.cut(cyl_z(x,y,-9,3,HOLE_D/2))
deck=deck.clean()

print('Building notched open base...',flush=True)
base=fuse([box(8,22,0,BASE_L,0,3.2),box(188,202,0,BASE_L,0,3.2),
           box(8,202,0,12,0,3.2),box(8,202,BASE_L-10,BASE_L,0,3.2)])
for cx in (15,195): base=base.fuse(hinge_ear(cx-3,cx+3,FRONT_Y,HINGE_Z,2.5))
for x0,x1 in ((8,22),(188,202)):
    rack=box(x0,x1,218,BASE_L,3,12)
    for a,s in SLOTS.items():
        # Radius clearance .15; lowest contact at z4.3 gives pin-centre z7.5.
        notch_centre=FOOT_Z+0.15
        cutter=cyl_x(x0-1,x1+1,s['y'],notch_centre,PIN_R+0.15)
        cutter=cutter.fuse(box(x0-1,x1+1,s['y']-PIN_R-0.15,s['y']+PIN_R+0.15,notch_centre,17))
        rack=rack.cut(cutter)
    base=base.fuse(rack)
# Small numbered tabs identify matching left/right slot positions in the guide.
# The engraved numbers on the right rail are visible with the deck lifted.
for a,s in SLOTS.items():
    tab=box(176,189,s['y']-4.1,s['y']+4.1,0,3.2)
    txt=cq.Workplane('XY',origin=(182.2,s['y'],2.5)).text(str(a),4.5,1.0,
            font='DejaVu Sans',halign='center',valign='center',combine=False).val()
    base=base.fuse(tab).cut(txt)
base=base.clean()

# Folding U brace in its own reference frame: upper pivot y=z=0, feet at y=PROP_LEN.
print('Building folding brace...',flush=True)
brace_p=[]
for x0,x1 in ((26.5,32.5),(177.5,183.5)):
    body=box(x0,x1,0,PROP_LEN,-3.0,3.2)
    boss=cyl_x(x0,x1,0,0,5.0).intersect(box(x0-1,x1+1,-6,6,-3.0,3.2))
    body=body.fuse(boss).cut(cyl_x(x0-0.5,x1+0.5,0,0,HOLE_D/2))
    brace_p.append(body)
brace_p.append(box(26.5,183.5,PROP_LEN-9,PROP_LEN,-3,3.2))
brace_p.append(cyl_x(8,202,PROP_LEN,0,PIN_R).intersect(box(7,203,PROP_LEN-4,PROP_LEN+4,-3,4)))
brace=fuse(brace_p)

# A separate low bottom stop. Print two copies. Mounting screw outside device footprint.
stop=fuse([box(-9,9,0,9.5,0,2.2),box(-9,9,7,9.5,0,7.2)])
stop=stop.cut(cyl_z(0,3.8,-1,9,HOLE_D/2)).clean()

# Pen cradles: the 12 mm mounting tab stays centered while the pen-contact
# body extends 12 mm in each direction. Local x origin is the mounting screw.
def pen_cradle(lower=False):
    s=box(-8,18,-6,6,0,2.5)
    outer=cq.Solid.makeCylinder(7,24,cq.Vector(11,-12,7.2),cq.Vector(0,1,0))
    if not lower:
        outer=outer.intersect(box(-9,19,-13,13,0,10.5))
    s=s.fuse(outer)
    inner=cq.Solid.makeCylinder(PEN_INNER_R,26,cq.Vector(11,-13,7.2),cq.Vector(0,1,0))
    if not lower:
        inner=inner.fuse(box(11-PEN_INNER_R,11+PEN_INNER_R,-13,13,7.2,16))
    s=s.cut(inner).cut(cyl_z(0,0,-1,15,HOLE_D/2))
    if lower: s=s.fuse(box(4,18,-14,-11.8,0,14.2))
    return s.clean()
pen_low=pen_cradle(True);pen_high=pen_cradle(False)

# Two-piece hinge coupon, same x gaps, pin holes and print direction as the real hinge.
ca=box(0,24,0,18,-3.2,0)
for x0,x1 in ((5,8.5),(15.5,19)):
    ca=ca.fuse(hinge_ear(x0,x1,8,-10,-2.5))
cb=hinge_ear(9,15,8,8,2.5).fuse(box(5,19,0,18,0,3.2)).clean()


def floor(s):
    bb=s.BoundingBox()
    return s.translate(cq.Vector(-bb.xmin,-bb.ymin,-bb.zmin))

parts={
 '01_honeycomb_deck_print_1':(deck,1,floor(deck.rotate((0,0,0),(1,0,0),180))),
 '02_notched_base_print_1':(base,1,floor(base)),
 '03_folding_U_brace_print_1':(brace,1,floor(brace)),
 '04_bottom_stop_print_2':(stop,2,floor(stop)),
 '05_lower_pen_cradle_print_1':(pen_low,1,floor(pen_low.rotate((0,0,0),(1,0,0),90))),
 '06_upper_pen_cradle_print_1':(pen_high,1,floor(pen_high.rotate((0,0,0),(1,0,0),-90))),
 'TEST_A_hinge_deck_half':(ca,0,floor(ca.rotate((0,0,0),(1,0,0),180))),
 'TEST_B_hinge_base_half':(cb,0,floor(cb))
}

report={'version':'2.0','device_mm':[196,230,5.7],'device_case':'bare / no cover',
        'angles_deg':list(ANGLES),'slot_positions':SLOTS,'parts':[],
        'density_assumption_g_cm3':1.24,'mass_method':'solid mesh volume times assumed density; not a slicer prediction',
        'physical_testing':'Earlier 9.4 mm upper cradle passed user pen-fit test; extended holders and closed lower ring untested',
        'fea':'none','assembly_collision_checks':{}}
for name,(s,q,pr) in parts.items():
    print('Exporting',name,flush=True)
    assert s.isValid(),name+' invalid BREP'
    assert len(s.Solids())==1,(name,'not one solid',len(s.Solids()))
    cq.exporters.export(pr,str(STL/(name+'.stl')),tolerance=0.05,angularTolerance=0.12)
    cq.exporters.export(s,str(STEP/(name+'.step')))
    mesh=trimesh.load(STL/(name+'.stl'),force='mesh')
    assert mesh.is_watertight,(name,'not watertight')
    assert mesh.is_winding_consistent,(name,'bad normals')
    assert len(mesh.split(only_watertight=False))==1,(name,'mesh components')
    assert np.min(mesh.bounds[0])>=-1e-5
    bb=mesh.extents
    assert bb[0]<310 and bb[1]<310
    report['parts'].append({'file':name+'.stl','copies':q,'print_bounds_mm':list(np.round(bb,3)),
       'solid_volume_cm3':round(float(mesh.volume)/1000,3),
       'solid_PLA_g_at_1_24':round(float(mesh.volume)/1000*1.24,2),
       'watertight':bool(mesh.is_watertight),'single_solid':True})

# Assembly transforms are independent of the print orientation used in the STL files.
def plate_pose(s,angle):
    return s.translate(cq.Vector(0,-FRONT_Y,-LOCAL_HINGE_Z)).rotate((0,0,0),(1,0,0),angle).translate(cq.Vector(0,FRONT_Y,HINGE_Z))

def assemble(angle):
    if angle==0:
        prop=brace.rotate((0,0,0),(1,0,0),180).translate(cq.Vector(0,PROP_Y,HINGE_Z))
    else:
        ss=SLOTS[angle]
        prop=brace.rotate((0,0,0),(1,0,0),ss['brace_angle_deg']).translate(cq.Vector(0,ss['upper_y'],ss['upper_z']))
    return {'deck':plate_pose(deck,angle),'base':base,'brace':prop,
            'stop_left':plate_pose(stop.translate(cq.Vector(58,0,0)),angle),
            'stop_right':plate_pose(stop.translate(cq.Vector(152,0,0)),angle),
            'pen_lower':plate_pose(pen_low.translate(cq.Vector(214,50,0)),angle),
            'pen_upper':plate_pose(pen_high.translate(cq.Vector(214,170,0)),angle)}

for a in (*ANGLES,0):
    print('Checking assembled pose',a,flush=True)
    objs=assemble(a)
    intersections=[]
    keys=list(objs)
    for i,k in enumerate(keys):
        for l in keys[i+1:]:
            v=objs[k].intersect(objs[l]).Volume()
            if v>0.02: intersections.append({'part_a':k,'part_b':l,'intersection_mm3':round(v,4)})
    report['assembly_collision_checks'][str(a)]=intersections
    ass=cq.Assembly(name=f'Kindle_Scribe_V2_{a}deg')
    for k,v in objs.items(): ass.add(v,name=k)
    ass.export(str(STEP/(f'ASSEMBLY_{a:02d}deg_REFERENCE_ONLY.step')))
    if a==12:
        preview=OUT/'preview_meshes';preview.mkdir(exist_ok=True)
        for k,v in objs.items(): cq.exporters.export(v,str(preview/(k+'.stl')),tolerance=.1,angularTolerance=.18)
    if a==0:
        preview=OUT/'folded_meshes';preview.mkdir(exist_ok=True)
        for k,v in objs.items(): cq.exporters.export(v,str(preview/(k+'.stl')),tolerance=.1,angularTolerance=.18)

report['total_solid_PLA_g']=round(sum(p['copies']*p['solid_PLA_g_at_1_24'] for p in report['parts']),2)
report['total_solid_volume_cm3']=round(sum(p['copies']*p['solid_volume_cm3'] for p in report['parts']),3)
(OUT/'validation_report.json').write_text(json.dumps(report,indent=2))
with (OUT/'parts_and_material.csv').open('w',newline='') as f:
    wr=csv.writer(f);wr.writerow(['File','Print quantity','X mm','Y mm','Z mm','Solid volume cm3 each','Solid PLA g each (1.24 g/cm3)','Watertight'])
    for p in report['parts']:wr.writerow([p['file'],p['copies'],*p['print_bounds_mm'],p['solid_volume_cm3'],p['solid_PLA_g_at_1_24'],p['watertight']])
print('TOTAL SOLID PLA',report['total_solid_PLA_g'],flush=True)
print('COLLISIONS',json.dumps(report['assembly_collision_checks']),flush=True)
# Keep objects available to a caller using runpy for additional analysis.
