# Agent rules for `otto-diy`

- Prefer simple, tested solutions and reuse components already owned. Minimize soldering and wiring.
- Never fabricate print, fit, compilation, current, or physical test results. Label untested assumptions clearly.
- Verify the exact board, expansion shield, sensor module, servo, and power-supply pinouts before wiring. Never assume a generic Nano shield isolates its servo rail.
- Do not supply four moving servos from Arduino USB, the onboard regulator, or unverified shield rails. Use a regulated, current-rated servo supply and common ground; prevent backfeeding, especially while USB is attached.
- Preserve upstream filenames, versions, licenses, source links, and Otto DIY attribution. Keep original meshes unchanged and make future mechanical changes parameterized where possible.
- Keep firmware pin mapping, wiring, BOM, printing, and physical design documentation in sync.
- Gate movement on servo fit, centering, trim, and stable power. Avoid wide angle sweeps on an assembled robot until stops are measured.
- Do not order, print, push changes, or add wireless/AI features without the user's authorization. This project's initial requested deliverables are files and instructions, not physical execution.
