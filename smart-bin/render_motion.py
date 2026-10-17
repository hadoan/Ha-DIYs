#!/usr/bin/env python3
"""Render provisional constrained-motion stills, looping GIF and MP4."""

from __future__ import annotations

from math import cos, pi
from pathlib import Path
import shutil
import subprocess
from tempfile import TemporaryDirectory


ROOT = Path(__file__).resolve().parent
EXPORTS = ROOT / "exports"
CAMERA = "25,0,40,85,0,5,750"
SIZE = "1200,900"
LABEL = (
    "drawtext=text='PROVISIONAL CAD - fit unverified':"
    "x=18:y=16:fontsize=24:fontcolor=0x17324d:"
    "box=1:boxcolor=white@0.82:boxborderw=7"
)


def run(args: list[str]) -> None:
    result = subprocess.run(args, cwd=ROOT, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(f"{' '.join(args[:3])} failed:\n{result.stderr[-4000:]}")


def openscad_png(path: Path, angle: float) -> None:
    run([
        "openscad", "--hardwarnings", "-o", str(path),
        f"--imgsize={SIZE}", f"--camera={CAMERA}",
        "-D", f"pose_override={angle:.6f}",
        "-D", "show_lower_body=false", "assembly.scad",
    ])


def render() -> None:
    EXPORTS.mkdir(exist_ok=True)
    if not shutil.which("ffmpeg"):
        raise RuntimeError("ffmpeg is required for the labeled stills and animation")
    with TemporaryDirectory(prefix="smart-bin-motion-") as temporary:
        frames = Path(temporary)
        stills = {
            "closed": 0,
            "30": 30,
            "half_open": 45,
            "75": 75,
            "open": 90,
        }
        for name, angle in stills.items():
            raw = frames / f"still_{name}.png"
            openscad_png(raw, angle)
            run([
                "ffmpeg", "-y", "-loglevel", "error", "-i", str(raw),
                "-vf", LABEL, "-frames:v", "1",
                str(EXPORTS / f"assembly_{name}.png"),
            ])
        count = 48
        for index in range(count):
            angle = 45 * (1 - cos(2 * pi * index / count))
            openscad_png(frames / f"frame_{index:03d}.png", angle)
        source = str(frames / "frame_%03d.png")
        run([
            "ffmpeg", "-y", "-loglevel", "error", "-framerate", "12",
            "-i", source, "-vf", f"{LABEL},format=yuv420p",
            "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart",
            str(EXPORTS / "mechanism_motion.mp4"),
        ])
        run([
            "ffmpeg", "-y", "-loglevel", "error", "-framerate", "12",
            "-i", source,
            "-filter_complex",
            f"[0:v]{LABEL},split[a][b];[a]palettegen[p];[b][p]paletteuse[v]",
            "-map", "[v]", "-loop", "0",
            str(EXPORTS / "mechanism_motion.gif"),
        ])
    print("PASS labeled 0/30/45/75/90° stills and looping GIF/MP4")


if __name__ == "__main__":
    render()
