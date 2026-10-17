"""Replace the pen meshes in the existing QIDI projects, preserving their plates and profiles.

Run after make_design.py. The original 3MF projects supply the printer, filament,
process, per-object infill, and plate placement settings.
"""
from datetime import date
from pathlib import Path
import re
import zipfile
from xml.etree import ElementTree as ET

import trimesh

ROOT = Path(__file__).resolve().parent
PROJECTS = (
    'Kindle_Scribe_V2_Final_All_Parts_XPlus5.3mf',
    'Kindle_Scribe_V2_Complete_XPlus5.3mf',
    'Kindle_Scribe_V2_Pen_Cradle_9p4mm_Test.3mf',
)
PARTS = {
    '05_lower_pen_cradle_print_1.stl',
    '06_upper_pen_cradle_print_1.stl',
}
CORE = '{http://schemas.microsoft.com/3dmanufacturing/core/2015/02}'
P = '{http://schemas.microsoft.com/3dmanufacturing/production/2015/06}'


def build_mesh_xml(mesh):
    center = mesh.bounds.mean(axis=0)
    vertices = ''.join(
        f'<vertex x="{x:.8g}" y="{y:.8g}" z="{z:.8g}"/>'
        for x, y, z in mesh.vertices - center
    )
    triangles = ''.join(
        f'<triangle v1="{a}" v2="{b}" v3="{c}"/>'
        for a, b, c in mesh.faces
    )
    return f'<mesh><vertices>{vertices}</vertices><triangles>{triangles}</triangles></mesh>'


def replace_object_settings(xml, object_id, bounds, face_count):
    block_re = re.compile(rf'(<object id="{object_id}">)(.*?)(</object>)', re.S)
    match = block_re.search(xml)
    assert match, f'No settings for object {object_id}'
    block = match.group(2)
    block = re.sub(r'(<metadata face_count=")[^"]+', rf'\g<1>{face_count}', block)
    block = re.sub(r'(<mesh_stat face_count=")[^"]+', rf'\g<1>{face_count}', block)
    center = bounds.mean(axis=0)

    def matrix_repl(m):
        numbers = m.group(2).split()
        assert len(numbers) == 16
        numbers[3], numbers[7], numbers[11] = (f'{v:.8g}' for v in center)
        return m.group(1) + ' '.join(numbers) + m.group(3)

    block, count = re.subn(r'(<metadata key="matrix" value=")([^"]+)("/>)', matrix_repl, block)
    assert count == 1
    for axis, value in zip('xyz', center):
        block = re.sub(
            rf'(<metadata key="source_offset_{axis}" value=")[^"]+',
            lambda m: m.group(1) + f'{value:.8g}', block,
        )
    return xml[:match.start(2)] + block + xml[match.end(2):]


def replace_build_height(xml, object_id, height):
    pattern = rf'(<item objectid="{object_id}"[^>]*? transform=")[^"]+("[^>]*?/>)'
    def update(m):
        values = m.group(0).split('transform="', 1)[1].split('"', 1)[0].split()
        assert len(values) == 12
        values[11] = f'{height:.8g}'
        return m.group(1) + ' '.join(values) + m.group(2)
    result, count = re.subn(pattern, update, xml)
    assert count == 1, (object_id, count)
    return result


def place_object(xml, object_id, x, y):
    pattern = rf'(<item objectid="{object_id}"[^>]*? transform=")[^"]+("[^>]*?/>)'
    def update(m):
        values = m.group(0).split('transform="', 1)[1].split('"', 1)[0].split()
        assert len(values) == 12
        values[9:11] = [f'{x:.8g}', f'{y:.8g}']
        return m.group(1) + ' '.join(values) + m.group(2)
    result, count = re.subn(pattern, update, xml)
    assert count == 1, (object_id, count)
    return result


def update_project(path):
    with zipfile.ZipFile(path) as src:
        files = {name: src.read(name) for name in src.namelist()}
    settings = files['Metadata/model_settings.config'].decode()
    model = files['3D/3dmodel.model'].decode()
    root = ET.fromstring(model)
    resources = root.find(f'{CORE}resources')
    object_paths = {}
    for obj in resources.findall(f'{CORE}object'):
        comp = obj.find(f'{CORE}components/{CORE}component')
        if comp is not None:
            object_paths[obj.get('id')] = comp.get(f'{P}path').lstrip('/')

    changed = []
    name_ids = {}
    for match in re.finditer(r'<object id="(\d+)">(.*?)</object>', settings, re.S):
        part = re.search(r'<metadata key="name" value="([^"]+)"', match.group(2))
        if part is not None:
            name_ids.setdefault(part.group(1), []).append(match.group(1))
        if part is None or part.group(1) not in PARTS:
            continue
        name, object_id = part.group(1), match.group(1)
        mesh = trimesh.load(ROOT / 'STL' / name, force='mesh')
        assert mesh.is_watertight and mesh.is_winding_consistent
        object_path = object_paths[object_id]
        object_xml = files[object_path].decode()
        object_xml, count = re.subn(r'<mesh>.*?</mesh>', build_mesh_xml(mesh), object_xml, count=1, flags=re.S)
        assert count == 1
        files[object_path] = object_xml.encode()
        settings = replace_object_settings(settings, object_id, mesh.bounds, len(mesh.faces))
        model = replace_build_height(model, object_id, mesh.extents[2] / 2)
        changed.append(name)

    assert changed, f'No pen parts in {path.name}'
    if path.name == PROJECTS[0]:
        # The longer cradles need more clearance from each other and the brace.
        model = place_object(model, name_ids['05_lower_pen_cradle_print_1.stl'][0], 48, 50)
        model = place_object(model, name_ids['06_upper_pen_cradle_print_1.stl'][0], 68, 50)
        stop_ids = name_ids['04_bottom_stop_print_2.stl']
        model = place_object(model, stop_ids[0], 86, 45)
        model = place_object(model, stop_ids[1], 86, 72)
    elif path.name == PROJECTS[1]:
        # Put both revised pen holders with the test coupons on plate 1.
        model = place_object(model, name_ids['05_lower_pen_cradle_print_1.stl'][0], 260, 167)
        # Clear the brace at the rear of plate 2.
        model = place_object(model, name_ids['04_bottom_stop_print_2.stl'][0], 447, 68)
    elif path.name == PROJECTS[2]:
        # The single-part test imported its old mesh with an extra local offset.
        # The new mesh is centered like the meshes in the complete projects.
        model = model.replace('transform="1 0 0 0 1 0 0 0 1 13 5.25 6"',
                              'transform="1 0 0 0 1 0 0 0 1 0 0 0"')
        model = place_object(model, name_ids['06_upper_pen_cradle_print_1.stl'][0], 160, 160)
    model = re.sub(r'(<metadata name="ModificationDate">)[^<]+',
                   lambda m: m.group(1) + date.today().isoformat(), model)
    files['3D/3dmodel.model'] = model.encode()
    files['Metadata/model_settings.config'] = settings.encode()
    target = path.with_suffix('.tmp.3mf')
    with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as out:
        for name, data in files.items():
            out.writestr(name, data)
    with zipfile.ZipFile(target) as check:
        assert check.testzip() is None
    target.replace(path)
    print(path.name, ', '.join(changed))


if __name__ == '__main__':
    for project in PROJECTS:
        update_project(ROOT / project)
