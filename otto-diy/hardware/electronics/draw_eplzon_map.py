#!/usr/bin/env python3
"""Draw the photographed EPLZON strip-perfboard header layout as SVG."""

from pathlib import Path
from xml.sax.saxutils import escape

OUT = Path(__file__).with_name("eplzon_perfboard_map.svg")
COLS = dict(zip("ABCDEFGHIJ", (322, 350, 378, 406, 434, 526, 554, 582, 610, 638)))
ROWS = {n: 151 + 30 * (n - 1) for n in range(1, 18)}
COLORS = {
    "signal": "#1769c2",
    "power": "#cf3030",
    "ground": "#292d35",
    "sensor": "#14936f",
    "buzzer": "#8248b4",
}
NETS = {
    ("L", 2): ("D2  LL signal", "signal"),
    ("L", 3): ("servo +5 V", "power"),
    ("L", 4): ("servo GND", "ground"),
    ("R", 2): ("D3  RL signal", "signal"),
    ("R", 3): ("servo +5 V", "power"),
    ("R", 4): ("servo GND", "ground"),
    ("L", 7): ("D4  LF signal", "signal"),
    ("L", 8): ("servo +5 V", "power"),
    ("L", 9): ("servo GND", "ground"),
    ("R", 7): ("D5  RF signal", "signal"),
    ("R", 8): ("servo +5 V", "power"),
    ("R", 9): ("servo GND", "ground"),
    ("L", 12): ("HC-SR04 VCC ← Nano 5V", "sensor"),
    ("L", 13): ("HC-SR04 TRIG ← D8", "sensor"),
    ("L", 14): ("HC-SR04 ECHO → D9", "sensor"),
    ("L", 15): ("HC-SR04 GND → Nano GND", "ground"),
    ("R", 12): ("passive piezo ← D13", "buzzer"),
    ("R", 13): ("passive piezo → Nano GND", "ground"),
}


def txt(x, y, value, size=16, fill="#172235", weight="normal", anchor="start"):
    return (
        f'<text x="{x}" y="{y}" font-family="Arial,Helvetica,sans-serif" '
        f'font-size="{size}" font-weight="{weight}" fill="{fill}" '
        f'text-anchor="{anchor}">{escape(value)}</text>'
    )


def build():
    out = [
        '<svg xmlns="http://www.w3.org/2000/svg" width="1240" height="870" viewBox="0 0 1240 870">',
        '<rect width="1240" height="870" fill="#f8fafc"/>',
        txt(60, 55, "Otto V9 · EPLZON perfboard connector map", 28, weight="bold"),
        txt(60, 83, "TOP / COMPONENT SIDE · letters upright · board drawing is not to scale", 16, fill="#526073"),
        '<rect x="275" y="109" width="410" height="570" rx="20" fill="#10845c" stroke="#086443" stroke-width="4"/>',
        '<rect x="450" y="130" width="58" height="533" rx="9" fill="#0b7855" opacity=".65"/>',
    ]
    # Four M2 corner mounting holes and two M3 center mounting holes.
    for x, y, radius in [(296, 130, 8), (665, 130, 8), (296, 658, 8), (665, 658, 8), (480, 151, 15), (480, 631, 15)]:
        out.append(f'<circle cx="{x}" cy="{y}" r="{radius+3}" fill="#c99e5a"/>')
        out.append(f'<circle cx="{x}" cy="{y}" r="{radius}" fill="#f8fafc"/>')
    for name, x in COLS.items():
        out.append(txt(x, 123, name, 13, "#eafff6", "bold", "middle"))
    for n, y in ROWS.items():
        out.append(txt(283, y + 5, str(n), 13, "#eafff6", "bold", "middle"))
        # Each segment is one copper island on the underside, according to the supplied photo.
        for side, x1, x2 in (("L", 322, 434), ("R", 526, 638)):
            net = NETS.get((side, n))
            stroke = COLORS[net[1]] if net else "#b79659"
            out.append(
                f'<line x1="{x1}" y1="{y}" x2="{x2}" y2="{y}" '
                f'stroke="{stroke}" stroke-width="9" stroke-linecap="round" opacity=".75"/>'
            )
        for col, x in COLS.items():
            side = "L" if col <= "E" else "R"
            net = NETS.get((side, n))
            fill = COLORS[net[1]] if net else "#d7b674"
            out.append(f'<circle cx="{x}" cy="{y}" r="9" fill="{fill}" stroke="#eee2bb" stroke-width="2"/>')
            out.append(f'<circle cx="{x}" cy="{y}" r="4" fill="#f8fafc"/>')
    # Header boxes; pins are vertical, one strip per pin.
    for x, start in [(350, 2), (610, 2), (350, 7), (610, 7)]:
        y = ROWS[start] - 18
        out.append(f'<rect x="{x-18}" y="{y}" width="36" height="96" rx="5" fill="none" stroke="#ffffff" stroke-width="3"/>')
    out.append(f'<rect x="332" y="{ROWS[12]-18}" width="36" height="126" rx="5" fill="none" stroke="#ffffff" stroke-width="3"/>')
    out.append(f'<rect x="592" y="{ROWS[12]-18}" width="36" height="66" rx="5" fill="none" stroke="#ffffff" stroke-width="3"/>')
    # Side callouts include the important signal and polarity mapping.
    for y, title, details in [
        (181, "LL · left leg", ["B2  signal → Nano D2", "B3  +5 V servo", "B4  GND servo"]),
        (331, "LF · left foot", ["B7  signal → Nano D4", "B8  +5 V servo", "B9  GND servo"]),
        (480, "HC-SR04 cable", ["B12  VCC ← Nano 5V", "B13  TRIG ← Nano D8", "B14  ECHO → Nano D9", "B15  GND → Nano GND"]),
    ]:
        out.append(txt(28, y, title, 20, weight="bold"))
        for i, detail in enumerate(details):
            out.append(txt(28, y + 27 + i*23, detail, 15))
    for y, title, details in [
        (181, "RL · right leg", ["I2  signal → Nano D3", "I3  +5 V servo", "I4  GND servo"]),
        (331, "RF · right foot", ["I7  signal → Nano D5", "I8  +5 V servo", "I9  GND servo"]),
        (480, "Optional passive piezo*", ["I12  signal ← Nano D13", "I13  GND → Nano GND", "* Leave empty until type/rating checked"]),
    ]:
        out.append(txt(715, y, title, 20, weight="bold"))
        for i, detail in enumerate(details):
            out.append(txt(715, y + 27 + i*23, detail, 15))
    # Wiring banner. The board's copper carries local header contact only.
    out.append('<rect x="50" y="706" width="1140" height="126" rx="14" fill="#e8eef5" stroke="#c7d5e5"/>')
    out.append(txt(75, 736, "Solder-side power rule", 20, weight="bold"))
    out.append(txt(75, 765, "4×AA → switch/protection → 5 V buck-boost ≥3 A → insulated star → 4 servo power branches.", 17))
    out.append(txt(75, 792, "Nano GND joins star. Regulated +5 V → removable RUN plug → Nano 5V; unplug USB in RUN mode.", 17))
    out.append(txt(75, 818, "Before USB: disconnect AA pack and RUN plug. Copper strips are local only; meter-test each row.", 15, fill="#526073"))
    out.append('</svg>')
    OUT.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(OUT)


if __name__ == "__main__":
    build()
