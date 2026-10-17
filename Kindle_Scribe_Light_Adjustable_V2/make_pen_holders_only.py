"""Create a one-plate QIDI project containing only the two revised pen holders.

The final complete project is the source of the printer, filament and per-part
infill settings. Run update_qidi_projects.py first after changing CAD geometry.
"""
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / 'Kindle_Scribe_V2_Final_All_Parts_XPlus5.3mf'
TARGET = ROOT / 'Kindle_Scribe_V2_Pen_Holders_Only_XPlus5.3mf'
KEEP_IDS = {'8', '10'}
KEEP_OBJECT_MODELS = {'object_4.model', 'object_5.model'}
PREVIEW = ROOT / 'previews' / '05_pen_holders_only_plate.png'

with zipfile.ZipFile(SOURCE) as src:
    files = {name: src.read(name) for name in src.namelist()}

settings = files['Metadata/model_settings.config'].decode()
model = files['3D/3dmodel.model'].decode()
relations = files['3D/_rels/3dmodel.model.rels'].decode()

for object_id, expected in (('8', '05_lower_pen_cradle_print_1.stl'),
                            ('10', '06_upper_pen_cradle_print_1.stl')):
    match = re.search(rf'<object id="{object_id}">(.*?)</object>', settings, re.S)
    assert match and f'value="{expected}"' in match.group(1)

settings = re.sub(r'  <object id="(\d+)">.*?</object>\n',
                  lambda m: m.group(0) if m.group(1) in KEEP_IDS else '',
                  settings, flags=re.S)
plates = re.findall(r'  <plate>.*?</plate>\n', settings, flags=re.S)
assert len(plates) == 2
first_plate = plates[0]
first_plate = re.sub(r'    <model_instance>.*?</model_instance>\n',
                     lambda m: m.group(0) if re.search(r'<metadata key="object_id" value="(8|10)"/>', m.group(0)) else '',
                     first_plate, flags=re.S)
first_plate = first_plate.replace('BASE - brace and mounts', 'PEN HOLDERS ONLY')
assert first_plate.count('<model_instance>') == 2
settings = settings.replace(plates[0], first_plate).replace(plates[1], '')

model = re.sub(r'  <object id="(\d+)".*?</object>\n',
               lambda m: m.group(0) if m.group(1) in KEEP_IDS else '',
               model, flags=re.S)
model = re.sub(r'  <item objectid="(\d+)"[^>]*/>\n',
               lambda m: m.group(0) if m.group(1) in KEEP_IDS else '',
               model)

def move_item(text, object_id, x, y):
    pattern = rf'(<item objectid="{object_id}"[^>]*? transform=")[^"]+("[^>]*?/>)'
    def update(m):
        values = m.group(0).split('transform="', 1)[1].split('"', 1)[0].split()
        assert len(values) == 12
        values[9:11] = [str(x), str(y)]
        return m.group(1) + ' '.join(values) + m.group(2)
    text, count = re.subn(pattern, update, text)
    assert count == 1
    return text

model = move_item(model, '8', 145, 160)
model = move_item(model, '10', 175, 160)
assert model.count('<item ') == 2
relations = re.sub(r' <Relationship [^>]+/>\n',
                   lambda m: m.group(0) if any(name in m.group(0) for name in KEEP_OBJECT_MODELS) else '',
                   relations)
assert relations.count('<Relationship ') == 2

files['Metadata/model_settings.config'] = settings.encode()
files['3D/3dmodel.model'] = model.encode()
files['3D/_rels/3dmodel.model.rels'] = relations.encode()
for name in list(files):
    if name.startswith('3D/Objects/') and Path(name).name not in KEEP_OBJECT_MODELS:
        del files[name]
    elif re.fullmatch(r'Metadata/(?:plate|plate_no_light|top|pick)_2\.png', name):
        del files[name]

if PREVIEW.exists():
    thumbnail = PREVIEW.read_bytes()
    for name in ('Metadata/plate_1.png', 'Metadata/plate_no_light_1.png',
                 'Metadata/top_1.png', 'Metadata/pick_1.png'):
        files[name] = thumbnail

with zipfile.ZipFile(TARGET, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as out:
    for name, data in files.items():
        out.writestr(name, data)
with zipfile.ZipFile(TARGET) as check:
    assert check.testzip() is None
print(TARGET)
