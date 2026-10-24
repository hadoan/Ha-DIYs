# Upstream sources, versions, and licenses

Access checked 17 October 2026. These links identify source material; no third-party firmware is vendored into this project.

## Mechanical set

- Project: [Open-Hardware-Leaders/OttoDIY](https://github.com/Open-Hardware-Leaders/OttoDIY), `master` commit [`8cf3e784c734981c50143cfddde18a68685bcea3`](https://github.com/Open-Hardware-Leaders/OttoDIY/tree/8cf3e784c734981c50143cfddde18a68685bcea3).
- Variant: **classic V9**, all four names use `OttoDIY_..._V9` (without `+`, `H`, or `EYES`). Same source commit and version naming make this a matching published set; actual printed joint fit and the selected servos remain untested.
- Official [classic V9 assembly manual](https://github.com/Open-Hardware-Leaders/OttoDIY/blob/8cf3e784c734981c50143cfddde18a68685bcea3/How%20to%20guides/OttoDIY_Manual_V9.pdf), [classic V9 avoidance sketch](https://github.com/Open-Hardware-Leaders/OttoDIY/blob/8cf3e784c734981c50143cfddde18a68685bcea3/Code/ultrasound/Otto_avoid_V9/Otto_avoid_V9.ino), and [root README](https://github.com/Open-Hardware-Leaders/OttoDIY/blob/8cf3e784c734981c50143cfddde18a68685bcea3/README.md).

| Stored file | Direct original download | SHA-256 |
|---|---|---|
| `OttoDIY_head_V9.stl` | [raw](https://raw.githubusercontent.com/Open-Hardware-Leaders/OttoDIY/8cf3e784c734981c50143cfddde18a68685bcea3/3Dprint/OttoDIY_head_V9.stl) | `d0f8ecf31bc2b55466dd2a8705d243d8e11d2ea93bb21d8b1a982da0a16cb425` |
| `OttoDIY_body_V9.stl` | [raw](https://raw.githubusercontent.com/Open-Hardware-Leaders/OttoDIY/8cf3e784c734981c50143cfddde18a68685bcea3/3Dprint/OttoDIY_body_V9.stl) | `cb955d9f5791ee01bc301ccc4fd406fbdc992bb7ff9e1e5ebb6b4575442a9216` |
| `OttoDIY_Leg_V9.stl` | [raw](https://raw.githubusercontent.com/Open-Hardware-Leaders/OttoDIY/8cf3e784c734981c50143cfddde18a68685bcea3/3Dprint/OttoDIY_Leg_V9.stl) | `c075a166153dc1239547d09f0cebf5a589ddada051a353a6b114052ff3e509ee` |
| `OttoDIY_foot_V9.stl` | [raw](https://raw.githubusercontent.com/Open-Hardware-Leaders/OttoDIY/8cf3e784c734981c50143cfddde18a68685bcea3/3Dprint/OttoDIY_foot_V9.stl) | `e3ed6a71058ca019efc0b3fc793fd34347685a4d0b9023e0e9d633daf2c56b08` |

The upstream README says **code GPL v3.0, hardware/3D prints CERN OHL v2.0, documentation/media CC BY-SA 4.0**, while its following broad statement describes Otto resources/remixes as CC BY-SA. This is an upstream licensing ambiguity. Preserve this attribution and source information; treat the four unmodified STLs as hardware under the stated CERN OHL v2.0 designation, and confirm precise redistribution obligations with the upstream project before publishing modified meshes. Attribute **Otto DIY / ottodiy.com**. This project's notes are original instructions, not a copy of the official manual.

## Firmware library

- [OttoDIY/OttoDIYLib](https://github.com/OttoDIY/OttoDIYLib), `main` commit [`f384c00a641e11c8741487320c6f1d82ad72e6d5`](https://github.com/OttoDIY/OttoDIYLib/tree/f384c00a641e11c8741487320c6f1d82ad72e6d5), [`library.properties`](https://github.com/OttoDIY/OttoDIYLib/blob/f384c00a641e11c8741487320c6f1d82ad72e6d5/library.properties) version **13.0.0**, [GPL-3.0 license](https://github.com/OttoDIY/OttoDIYLib/blob/f384c00a641e11c8741487320c6f1d82ad72e6d5/LICENSE).
- Its [README](https://github.com/OttoDIY/OttoDIYLib/blob/f384c00a641e11c8741487320c6f1d82ad72e6d5/README.md) uses D2/D3/D4/D5 for the four servos and D13 for buzzer on AVR. Its [`Otto.h`](https://github.com/OttoDIY/OttoDIYLib/blob/f384c00a641e11c8741487320c6f1d82ad72e6d5/src/Otto.h) exposes `init`, `home`, `walk`, `turn`, and trim methods. The V9 avoidance example uses D8/D9 for ultrasonic input.
- The older mechanical repo's V9 sketches include `<Otto9.h>` and call a different `init(...)` signature. **Do not compile them as OttoDIYLib 13.0.0 examples unchanged.** The chosen mechanical set and proposed pin map align at the interface level; motion with v13 has not been bench verified.

## Electrical and print references

- [Arduino Nano classic pinout](https://docs.arduino.cc/resources/pinouts/A000005-full-pinout.pdf) and [board page](https://docs.arduino.cc/hardware/nano). A generic Nano expansion shield is **not** covered by that pinout.
- [Official Otto DIY printing/BOM guidance](https://github.com/Open-Hardware-Leaders/OttoDIY/blob/8cf3e784c734981c50143cfddde18a68685bcea3/README.md): PLA, ~0.20 mm layers, at least 20% infill, and no supports for the original geometry.
- [TowerPro SG90 catalogue](https://towerpro.com.tw/product/sg90-7/): a starting reference, not proof that the user's specific servo clone matches dimensions or current.
