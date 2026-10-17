"""Sampled interference checks only; not physical or structural validation."""
from pathlib import Path
import math, json
import cadquery as cq
OUT=Path(__file__).resolve().parent
load=lambda name:cq.importers.importStep(str(OUT/'STEP'/name)).val()
d=load('01_honeycomb_deck_print_1.step');b=load('02_notched_base_print_1.step');r=load('03_folding_U_brace_print_1.step')
rep=json.loads((OUT/'validation_report.json').read_text())
def deck(a):return d.translate(cq.Vector(0,-8,10)).rotate((0,0,0),(1,0,0),a).translate(cq.Vector(0,8,8))
def upper(a):return (8+192*math.cos(math.radians(a)),8+192*math.sin(math.radians(a)))
def prop(a,phi):
    y,z=upper(a)
    return r.rotate((0,0,0),(1,0,0),phi).translate(cq.Vector(0,y,z))
checks=[]
def check(label,a,phi):
    objs={'deck':deck(a),'base':b,'brace':prop(a,phi)}
    overlaps=[]
    for k,l in [('deck','base'),('brace','base'),('deck','brace')]:
        v=objs[k].intersect(objs[l]).Volume()
        if v>.02: overlaps.append({'pair':[k,l],'intersection_mm3':round(v,4)})
    checks.append({'stage':label,'deck_deg':a,'brace_absolute_deg':round(phi,4),'overlaps':overlaps})
# Lift/lower with brace tucked forward. Then swing it below the deck while held at 45 degrees.
for a in [0,5,10,15,20,25,30,35,40,45]:check('folded brace; deck lifting/lowering',a,a+180)
for phi in [225,240,255,270,285,300,315,330,340]:check('brace swings under raised deck',45,phi)
# Final insertion/removal into each notch: foot is held above its target y as the deck lowers.
for target in (8,12,16,20):
    fy=rep['slot_positions'][str(target)]['y']
    for extra in [3,2,1,.5,0]:
        a=target+extra; uy,uz=upper(a);dx=fy-uy
        phi=-math.degrees(math.acos(dx/76))
        check(f'{target}deg slot entry / exit',a,phi)
rep['sampled_motion_checks']=checks
rep['sampled_motion_passed']=all(not c['overlaps'] for c in checks)
rep['checks_limitations']='Finite sampled positions only; no continuous swept-volume proof, no manufacturing tolerance simulation, no fastener/contact-pad model, no FEA or physical test.'
# Compare against original uploaded STL geometry, not earlier guessed slicer values.
import trimesh
old_dir=OUT.parent/'Kindle_Scribe_2024_Writing_Dock_12deg'
if (old_dir/'kindle_scribe_2024_writing_plate.stl').exists():
    v=trimesh.load(old_dir/'kindle_scribe_2024_writing_plate.stl').volume+3*trimesh.load(old_dir/'kindle_scribe_2024_wedge_rail_print_3.stl').volume
    rep['original_solid_volume_cm3']=round(v/1000,3)
    rep['CAD_solid_volume_reduction_percent']=round((1-rep['total_solid_volume_cm3']/(v/1000))*100,2)
(OUT/'validation_report.json').write_text(json.dumps(rep,indent=2))
print('Sampled motion pass:',rep['sampled_motion_passed'],'samples',len(checks))
for c in checks:
    if c['overlaps']:print(c)
print('CAD volume reduction:',rep.get('CAD_solid_volume_reduction_percent'))
