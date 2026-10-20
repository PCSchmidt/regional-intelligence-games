# Regional Analysis Desk - first interaction prototype

This is a small, offline Godot investigation, not the completed two-hour game.

- [Concept and requirements](../../specs/game-01/spec.md)
- [First-case sketch and evidence rubric](../../specs/game-01/CASE_01.md)
- [Master plan](../../MASTER_PLAN.md)

## Run

From the workspace root in PowerShell:

```powershell
.\tools\prototype.ps1 -Mode Run
```

The local toolchain is Godot 4.7.2 standard Windows x64, installed portably under the ignored `.tools` directory. Nothing is added to system PATH. GDScript is the first prototype choice, not a final series-wide language decision.

If Windows blocks script execution, use a process-scoped invocation rather than changing machine policy:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\prototype.ps1 -Mode Run
```

Alternatively import this folder in Godot and run its main scene. On a different machine, obtain Godot from its official distribution and supply `-GodotPath` to the runner. Windows export also needs matching x64 release/debug templates at the custom paths in the export preset.

## Play

1. Read the briefing. The vessel and all incident records are fictional; the places are real.
2. Select a source, timeline entry or map observation. All six sources are available from the beginning.
3. Pin sources to the notebook, then tick citations separately under each finding.
4. Choose three conclusions and submit. Feedback explains conclusions and missing support.
5. Use hints if needed; they do not impose a penalty. Notes and progress save locally.

Drag empty map space to pan, use the wheel or +/- buttons to zoom, and reset the view if needed. Standard controls support keyboard focus; the timeline provides a keyboard-accessible alternative to map markers.

Times are UTC. The map is a schematic with approximate contextual place markers and authored vessel fixes. It does not reproduce coastlines or a surveyed navigational chart. No line is drawn through the reception gap.

The save resides in Godot's application user-data directory (`%APPDATA%\Godot\app_userdata\Regional Analysis Desk\session.json` on a default Windows setup). Unreadable saves lock automatic writes; explicitly resetting first preserves the original as `.backup`. A second existing backup is not silently overwritten.

## Testing strategy

- **App type:** Native desktop; no HTML, HTTP service, database, credentials or authentication.
- **Primary stack:** Godot's own script/runtime, actual scene tree, native renderer and real isolated temporary save files. No test package installation.
- **Legacy tests:** None; this is a new project.
- **Journeys:** investigate in multiple orders; cite and assess; save/reload; handle corrupt/incompatible/unwritable data; reset safely; package and start without the editor.
- **Unit/domain tier:** Case validation and assessment classifications.
- **Persistence tier:** Real write/read/replace and rejection paths in unique per-process test directories.
- **UI tier:** Actual controls, map/timeline synchronization, pin/citation changes, hints and restored state. A rendered run captures the game's own viewport, never the desktop.
- **Packaged tier:** Export a Windows executable, run the same UI journey against its embedded resources, and check normal packaged startup.
- **Browser/infra axes:** Not applicable; this app has neither web content nor external infrastructure. Playwright and containers are not substitutes for testing a native Godot scene.
- **Isolation:** Tests supply their own save paths and clean up their named files/directories. The player's normal save is not used.
- **Pass:** Every suite exits zero with zero failed checks; error output must be reviewed, not hidden.
- **Known gaps:** Scripted control interaction is not a novice playtest. Desktop window-manager behavior, full accessibility, weaker hardware and actual play duration need human evaluation.

```powershell
.\tools\prototype.ps1 -Mode Test
.\tools\prototype.ps1 -Mode VisualTest
.\tools\prototype.ps1 -Mode Export
.\tools\prototype.ps1 -Mode PackagedTest
```

Tests are deliberately excluded from the exported resource pack. Release templates do not support running the external script driver. PackagedTest therefore extracts the ZIP outside the project, uses the standard engine with `--main-pack` to exercise the embedded scenes, compiled logic and case data, then separately launches the actual release executable. It checks a responsive desktop window, initialized-case autosave and exit zero. The release launch uses isolated application data, not the player's normal save.

### Verified checkpoint - 20 October 2026

All commands below completed with exit code 0 on the owner's Windows development laptop using Godot 4.7.2.

| Command | Observed result |
|---|---|
| `-Mode Test` | 24 case checks, 19 persistence checks and 51 scene/UI checks passed; zero failures |
| `-Mode VisualTest` | 52 checks passed with the NVIDIA compatibility renderer; game-only preview inspected |
| `-Mode Export` | Windows x64 release with embedded resources and instructions archived successfully |
| `-Mode PackagedTest` | 51 checks passed against the extracted embedded pack; actual release window, autosave and normal exit verified |

The UI checks cover a 1280 x 900 window, scroll reachability of each finding, rendered-canvas bounds, license access, map pan/zoom, discovery order, citation invalidation, debounced autosave, restart and reset failure preservation. Warning output for the intentionally missing save directory and corrupt save is expected and was reviewed. No unexpected script errors remain.

Two test assumptions were corrected during validation: JSON number types differ from in-memory integers, and Godot's stretched canvas must be transformed into window coordinates before checking physical bounds. The release-script limitation is handled explicitly rather than treating a silent GUI launch as a passed journey.

This is automation plus an assistant-inspected viewport, not an owner or independent novice walkthrough. First-play duration, enjoyment, keyboard-only operation, Windows security prompts and minimum hardware remain unverified. Do not treat this checkpoint as completion of the full Game 1 milestones.

## Asset/provenance register

| Material | Source | Treatment |
|---|---|---|
| Godot engine and built-in components | Official `godotengine/godot` 4.7.2 release | Engine/third-party license information is available through the in-game Licenses button |
| UI, schematic and case documents | Authored for this project | No external imagery, map tiles, fonts or audio files |
| Basic place identification | Basco and Itbayat references in the case sketch | Facts used for context; no copied article text or media |
| Incident, organizations and vessel data | Synthetic scenario | Not a historical incident or live operational dataset |

All functions are local. No runtime model calls, analytics, accounts, paid assets or API subscriptions. Future audio, imagery and basemap choices need their own license review.

## Quality boundaries

The prototype tests whether the information loop works. It has text placeholders instead of forensic imagery, a schematic instead of detailed geography, and no sound design or 3D. All evidence is immediately available; there is no search engine, branching campaign or regional simulator. Confidence is reflective, not scored.

The owner must still evaluate enjoyment, clarity and pacing before expanding the content.
