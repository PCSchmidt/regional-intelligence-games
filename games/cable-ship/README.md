# Cable Ship - first playable prototype

Separate Godot **4.7.2 standard Windows x64**, GDScript, **Forward+ / Vulkan**
project. [Player instructions](./PLAYER_README.md) contain spoiler-free controls.
[Design/acceptance contract](../../specs/game-02/PROTOTYPE.md) contains answers.

## Run, validate and export

From the repository root in PowerShell:

```powershell
.\tools\cable-ship.ps1 -Mode Run
.\tools\cable-ship.ps1 -Mode Test
.\tools\cable-ship.ps1 -Mode VisualTest
.\tools\cable-ship.ps1 -Mode Benchmark
.\tools\cable-ship.ps1 -Mode Export
.\tools\cable-ship.ps1 -Mode PackagedTest
```

Default engine: `.tools\godot\Godot_v4.7.2-stable_win64_console.exe`.
Supply `-GodotPath 'C:\path\to\Godot.exe'` to override. Use the matching official
Windows debug/release templates in `.tools\godot\templates`, as configured by
[the export preset](./export_presets.cfg). No extra dependencies are needed.
Alternatively import [the Godot project](./project.godot) in the editor.

Outputs: `builds\CableShip\CableShip.exe`, Markdown instructions, and the two-entry
`builds\CableShip-Windows.zip`. Generated builds, screenshots, local engines and
caches are ignored. There is no public release or code-signing certificate.

## Structure

- [Survey content](./content/survey.json): fictional evidence, options, citations, hints.
- [Shared seabed](./scripts/seabed.gd): authored floor (including furrow/lobe), cable, bounds, instruments.
- [Motion model](./scripts/rov_model.gd): deterministic thrust/linear drag, speed limits and clamping.
- [Rules](./scripts/survey_rules.gd) and [save store](./scripts/save_store.gd): validated content/state, captured-citation scoring, protected writes and backup/reset.
- [World builder](./scripts/world_builder.gd) and [geometry](./scripts/geometry.gd): procedural scene/materials, surface winding, shared-height terrain collision.
- [Main controller](./scripts/main.gd): real input, phase transitions, lighting, real PNG capture, gallery and feedback.
- [Survey plot](./scripts/survey_chart.gd): known target positions, not sonar.
- [Asset notices](./content/ASSET_NOTICES.md): provenance and in-game engine license access.

## Verified checkpoint - 21 October 2026

| Command/tier | Result | Scope |
|---|---|---|
| Test | 166 checks passed, 0 failed; 3 explicitly skipped | 111 domain/geometry, 44 scene/save journeys, 11 keyboard-dispatch checks. Headless cannot capture mouse or verify desktop layout. |
| VisualTest | 75 checks passed, 0 failed, no skips | 60 rendered scene/capture/screenshot checks at 1600x900; 15 control/layout/screenshot checks at 1180x700. |
| PackagedTest | 232 checks passed, 0 failed; 3 headless-only skips | 166 native plus 52 rendered exported-pack scene checks and 14 rendered input/layout checks, using external test drivers and the extracted embedded pack. |
| Actual release executable | Responsive window, initialized independent save, normal exit 0 | Separately launched outside the project with isolated APPDATA; no external test script in the release process. |

Every final validation command exited 0; the runner also rejects engine/script
errors because Godot can return 0 after a parse failure. Corrupt-save fixtures
intentionally emit **SAVE LOCKED** warnings and assert preservation. Those are
expected, not swallowed exceptions.

Rendered tests save actual viewport PNGs, load them back, review authored
observations, choose wrong/right alternatives, toggle citation controls, resubmit,
restart, cancel/confirm reset and preserve corrupt saves. The input journey sends
synthetic Godot key events through the real input handler and physics loop; it is
not OS-level keyboard automation. Headless scene tests use metadata fixtures,
never pretend they captured images. All use isolated directories and clean up.

Screenshots inspected: starting deck, console, all four features, gallery,
completion and small-window review. Geometry regression tests specifically
check upward-facing evidence surfaces after the first visual pass exposed
incorrect mesh winding. Text supplies authored observation detail that these
first-pass meshes cannot fully show; usability/realism require owner feedback.

### Performance

The benchmark disables VSync/FPS limiting, renders at actual 1920x1080, warms up
for five seconds, and traverses four inspection views plus a moving overview for
30 seconds. `builds\CableShip\benchmark.json` records adapter, viewport and
results. It does not include loading, PNG encoding or dialog rebuilding.
All-pass primitive counts (including extra passes) conservatively bound visible
triangle cost. Results are host/render-loop timings, not GPU timestamp queries.

Measured on the RTX A4500 Laptop GPU, Forward+:

- Average and 1% low throughput exceed the 60/30 fps targets.
- Maximum 51 draw calls and 271,166 rendered primitives, within 250/400k ceilings.
- Final sample: **618.9 fps average, 423.0 fps 1% low, 3.27 ms worst frame**,
  18,567 frames over 30 seconds. Both throughput and the strict 30 fps floor pass
  for this sample.
- An earlier 30-second run recorded a 75.21 ms hitch (586.6 fps average,
  152.1 fps 1% low), failing its strict floor. Retain that evidence: repeatability
  under sustained load is not established. The benchmark explicitly reports the
  strict floor separately and warns on hitches; command success alone is not
  strict-floor sign-off.

One powerful laptop is not a minimum-hardware certification or a sustained-load
test. Investigate stutter during owner play; do not infer performance on weaker
hardware, or realistic production-asset cost, from this procedural scene.

## Remaining gates

Owner completion time, hints used, control clarity, target visibility, movement
comfort, enjoyment, art direction and observed stutter. No audio, dynamic marine
snow, launch/recovery animation, crew, repair or tether simulation is included.
Physics uses a point-floor envelope, not a full ROV collision hull.
The written evidence supports comparative conclusions, not proof of vessel
identity, intent or exact failure time. Game 1's two-hour target remains unmet.
