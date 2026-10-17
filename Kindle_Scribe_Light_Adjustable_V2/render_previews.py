"""Render the actual exported CAD meshes (not a generated concept image)."""
from pathlib import Path
import vtk
from PIL import Image, ImageDraw, ImageFont
import numpy as np
from vtk.util.numpy_support import vtk_to_numpy
OUT=Path(__file__).resolve().parent
V=OUT/'previews';V.mkdir(exist_ok=True)
fontpath=next(p for p in ('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
                          '/System/Library/Fonts/Supplemental/Arial.ttf') if Path(p).exists())
boldpath=next(p for p in ('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
                          '/System/Library/Fonts/Supplemental/Arial Bold.ttf') if Path(p).exists())
def font(n,b=False):return ImageFont.truetype(boldpath if b else fontpath,n)
colors={'deck':(0.23,0.27,0.28),'base':(.55,.59,.59),'brace':(.24,.48,.43),
        'stop_left':(.23,.27,.28),'stop_right':(.23,.27,.28),'pen_upper':(.24,.48,.43),'pen_lower':(.24,.48,.43)}

def render(directory,path,cam,scale=175,explode=False,title='',subtitle=''):
    ren=vtk.vtkRenderer();ren.SetBackground(.961,.969,.969)
    rw=vtk.vtkRenderWindow();rw.SetOffScreenRendering(1);rw.SetMultiSamples(8);rw.SetSize(1680,1150);rw.AddRenderer(ren)
    ren.SetAmbient(.5,.5,.5)
    for f in sorted(directory.glob('*.stl')):
        reader=vtk.vtkSTLReader();reader.SetFileName(str(f));reader.Update()
        mapper=vtk.vtkPolyDataMapper();mapper.SetInputConnection(reader.GetOutputPort())
        actor=vtk.vtkActor();actor.SetMapper(mapper)
        p=actor.GetProperty();p.SetColor(*colors[f.stem]);p.SetAmbient(.32);p.SetDiffuse(.68);p.SetSpecular(.12);p.SetSpecularPower(24)
        if explode:
            if f.stem=='deck':actor.SetPosition(0,0,90)
            elif f.stem.startswith('stop'):actor.SetPosition(0,0,114)
            elif f.stem.startswith('pen'):actor.SetPosition(12,0,114)
            elif f.stem=='brace':actor.SetPosition(0,0,34)
        ren.AddActor(actor)
    c=ren.GetActiveCamera();c.SetPosition(*cam);c.SetFocalPoint(112,136,65 if explode else 28);c.SetViewUp(0,0,1);c.ParallelProjectionOn();c.SetParallelScale(scale)
    light=vtk.vtkLight();light.SetLightTypeToSceneLight();light.SetPosition(20,-200,500);light.SetFocalPoint(100,130,0);light.SetIntensity(.7);ren.AddLight(light)
    light=vtk.vtkLight();light.SetLightTypeToSceneLight();light.SetPosition(400,300,220);light.SetFocalPoint(100,130,0);light.SetIntensity(.3);ren.AddLight(light)
    ren.ResetCameraClippingRange();rw.Render()
    w=vtk.vtkWindowToImageFilter();w.SetInput(rw);w.ReadFrontBufferOff();w.Update()
    a=vtk_to_numpy(w.GetOutput().GetPointData().GetScalars()).reshape((1150,1680,-1))
    im=Image.fromarray(np.flipud(a).copy()).convert('RGB')
    d=ImageDraw.Draw(im);d.rectangle((0,0,1680,138),fill=(245,247,247))
    d.text((64,27),title,font=font(38,True),fill=(31,42,44))
    d.text((66,82),subtitle,font=font(23),fill=(85,98,100))
    d.rectangle((0,1080,1680,1150),fill=(245,247,247))
    d.text((65,1098),'Actual CAD geometry  |  V2 prototype  |  Hardware and protective pads not shown',font=font(20),fill=(80,93,94))
    im.save(path);rw.Finalize()

render(OUT/'preview_meshes',V/'01_assembled_12deg.png',(440,-420,440),185,
       title='Kindle Scribe / Lightweight Adjustable Dock',subtitle='Honeycomb deck  /  8°, 12°, 16°, 20°  /  Extended pen cradles')
render(OUT/'preview_meshes',V/'02_mechanism_side.png',(650,40,140),169,
       title='Positive-support angle adjustment',subtitle='The brace ends seat in matching slots on both sides. Lift the empty deck to adjust.')
render(OUT/'folded_meshes',V/'03_folded.png',(480,-410,250),170,
       title='Folds to approximately 29 mm high',subtitle='Fold the U-brace forward into the open base. Remove the Kindle and pen before folding.')
render(OUT/'preview_meshes',V/'04_exploded.png',(440,-500,440),205,True,
       title='Seven printed parts. No glued joints.',subtitle='Deck + base + folding brace + two bottom stops + lower and upper pen cradles')
print('Rendered previews',flush=True)
