# Regional Analysis Desk - two-case prototype

Two small, offline Godot investigations, not the completed two-hour game.

- [Concept and requirements](../../specs/game-01/spec.md)
- [First-case sketch and evidence rubric](../../specs/game-01/CASE_01.md)
- [Second-case evidence graph and rubric - author-only spoilers](../../specs/game-01/CASE_02.md)
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

You are a civilian regional analyst testing public claims, not presuming guilt. **The Missing Interval** introduces stop/tracking-gap/intent assessment with six records. **The Borrowed Name** adds seven records about vessel identification, camera-clock conventions and independent observations; its image is explicitly a text transcript, not forensic imagery.

1. A new session opens **Mission & Help**, explaining role, stakes, first action, feedback and completion. The header button reopens it without changing progress.
2. Read **Dispatch extract** in Case 1 or **Review request** in Case 2, already open, then select other sources, timeline entries or map observations in any order. All of that case's sources are available; no outside research is needed.
3. Pin useful sources to the notebook, then tick citations **separately under each finding**. Pinning alone does not cite a source.
4. Choose three conclusions and scroll to **Submit assessment**. A result dialog explains each finding. INCOMPLETE means choose an answer; REVISE means reconsider it; NEEDS SUPPORT means add citations; SUPPORTED means conclusion and citations are accepted.
5. Finish when the dialog says **INVESTIGATION COMPLETE** and the fixed indicator shows **3 of 3 findings supported**. **Review latest result** reopens the debrief after closing it or restarting. Edits invalidate stale results until resubmission.
6. Hints have no penalty; notes and progress save locally. Confidence is reflective, not scored.
7. **Cases** opens either investigation directly and shows progress or save attention. Completing Case 1 enables **Continue to Case 2**; Case 2 explicitly says no third case is included. This is not full-campaign completion.

Drag empty map space to pan, use the wheel or +/- buttons to zoom, and reset the view if needed. Standard controls support keyboard focus; the timeline provides a keyboard-accessible alternative to map markers.

Timeline times are UTC; source documents may use another clock convention. The map bundles real, generalized Natural Earth coastlines with named Batan, Itbayat and Sabtang, a north indicator and zoom-aware kilometer scale. Squares identify places, circles public fixes and diamonds shore sightings. Case 2 marker labels add local vessel IDs, not a pre-solved image-capture time. Labels/incident fixes are approximate; this is not a navigation product. Coastlines and observations share a local equirectangular projection, with cosine correction at 20.6 degrees north. No observed route is inferred between markers.

Default Windows saves:

```text
%APPDATA%\Godot\app_userdata\Regional Analysis Desk\session.json
%APPDATA%\Godot\app_userdata\Regional Analysis Desk\session-case-02.json
```

Case 1 retains its original path and version-1 compatibility. Every progress field is independent, including submitted results. Restart opens Case 1; select Case 2 to resume it. Switching saves before leaving; failed/locked saves require explicit **Switch without saving** or **Stay here** confirmation. Reset requires confirmation and affects only the selected slot. Unreadable originals lock writes; resetting first preserves that slot as `.backup`. An existing backup is not silently overwritten. Older saves without the optional submission marker load unsubmitted; resubmit to establish completion. Upgrading does not reopen the new-session guide automatically; use **Mission & Help**.

The pinned-source summary is limited to two lines to preserve space for notes; hover to see its full text. Individual source/citation labels remain available in the source list and assessment.

The export bundles Markdown [player instructions](../../PORTFOLIO_BUILD_README.md) as `README.md`.

## Testing strategy

- **Revision journeys:** New-session mission/help; incomplete/partial/complete submissions and conspicuous results; reload and stale-result invalidation with legacy saves; offline coastlines aligned through pan/zoom with a measured scale; updated Markdown instructions and extracted Windows delivery.
- **Two-case strategy:** [Case 2's pre-implementation evidence graph and testing strategy](../../specs/game-01/CASE_02.md#testing-strategy) extends the verified 140-check introductory baseline. Validate every alternative conclusion and omitted decisive citation, then exercise direct selection, continuation, independent notes/hints/confidence/citations/results, restart, save-failure cancel/confirm, and per-slot corruption/reset. Run forward and reverse second-case discovery and inspect the seven-row layout. No new infrastructure.
- **Existing tests:** Reuse and extend the Godot case, persistence and scene suites through the same `-Mode Test` entry point. Baseline: 24 case, 19 save and 51 UI checks passed, exit 0.
- **Map tier:** Add native geometry tests for the actual bundled public-domain coastlines, land/sea fixtures, projection and scale. No geographic network access at runtime.
- **App type:** Native desktop; no HTML, HTTP service, database, credentials or authentication.
- **Primary stack:** Godot's own script/runtime, actual scene tree, native renderer and real isolated temporary save files. No test package installation.
- **Legacy test assets:** Discovered native case/save/UI suites; reuse with edits. Preserve their original flows and add new mission, submitted-result, legacy-save and map checks. No framework migration.
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

Tests are deliberately excluded from the exported resource pack. Release templates do not support running the external script driver. PackagedTest therefore extracts the ZIP outside the project, verifies Markdown instructions, uses the standard engine with `--main-pack` to exercise map geometry and both UI/campaign journeys against embedded resources, then separately launches the actual release executable. It checks a responsive desktop window, initialized-case autosave and exit zero. The release launch uses isolated application data, not the player's normal save.

### Verified checkpoint - 20 October 2026

The initial build passed 24 case, 19 persistence and 51 UI checks. The onboarding/coastline revision is verified separately below using Godot 4.7.2 on the owner's Windows development laptop.

| Command | Observed result |
|---|---|
| `-Mode Test` | 24 case, 23 persistence, 23 map and 70 scene/UI checks passed; zero failures; exit 0 |
| `-Mode VisualTest` | 73 checks passed; exit 0; game-only desk, opening guide and completion dialog captured with the NVIDIA compatibility renderer and inspected |
| `-Mode Export` | Windows x64 release with embedded case/coastline resources and `README.md` archived successfully; exit 0 |
| `-Mode PackagedTest` | 23 map and 70 UI checks passed against the extracted embedded pack; Markdown instructions verified; actual release window, case autosave and normal exit verified; exit 0 |

The UI checks cover a 1280 x 900 window, scroll reachability, fixed progress visibility, mission/help, zero/one/three-supported submissions, current-result review, license access, discovery order, citation invalidation, debounced autosave, restart, legacy saves and reset failure preservation. Map tests load and triangulate all six actual island exteriors, distinguish land/sea, check every vessel observation is offshore and agrees with its source prose, verify nearest-marker selection and pan/zoom/reset, and measure a known 10 km distance within 1%. Warning output for the intentionally missing save directory and corrupt save is expected and was reviewed.

Two test assumptions were corrected during validation: JSON number types differ from in-memory integers, and Godot's stretched canvas must be transformed into window coordinates before checking physical bounds. The release-script limitation is handled explicitly rather than treating a silent GUI launch as a passed journey.

Coastline extraction was reproduced from the reviewed hash-pinned source and compared byte-for-byte with the bundled subset. An initially guessed Batan land fixture was offshore in the actual polygon; the fixture was corrected, not the source geometry. All final suites pass. The 140 canonical checks are not additional unique checks each time they are repeated in rendered or packaged runs.

This is automation plus assistant-inspected viewports, not independent usability testing. The first owner session lasted approximately 20 minutes, used hints and submitted an assessment; completion was unconfirmed. Role, first action, finish condition and feedback were unclear, motivating this revision. The owner reported that features appeared to work.

After the revision, the owner reported approximately five minutes to completion, no remaining confusion and conclusions that required some thought. Hint use was not reported for this run. This confirms improved clarity for the owner, but familiarity with the case makes it a repeat-player result, not first-play duration or independent novice validation. Enjoyment, keyboard-only operation, Windows security prompts and minimum hardware remain unverified.

### Two-case checkpoint - 20 October 2026

The owner approved designing and building Case 2, followed by commit/push. The introductory checkpoint was preserved as commit `b8feeaf` before expansion. Case 1's records, accepted answers and original save identity are unchanged.

| Command | Observed result |
|---|---|
| `-Mode Test` | 50 case, 23 persistence, 27 map, 70 original UI and 54 campaign checks passed: **224 total**, zero failures, exit 0 |
| `-Mode VisualTest` | 73 original UI and 58 campaign checks passed: **131 total**, exit 0; game-only views captured for both cases, clock source and correction feedback |
| `-Mode Export` | Windows x64 executable embeds both case JSON files and shared geography; Markdown instructions archived; exit 0 |
| `-Mode PackagedTest` | 27 map, 70 original UI and 54 campaign checks passed: **151 total** against extracted embedded resources; actual release window/autosave/normal exit verified; exit 0 |

The campaign suite drives real scene controls and isolated files through continuation/direct selection, both discovery orders, distinct confidence/notes/hints/citations, restart and recomputed completion, failed-switch cancel/confirm, corrupt-slot preservation/recovery, and resetting either slot without changing the other slot's bytes. JSON integer/float serialization can legitimately change bytes during a normal save/reload, so reset isolation compares the other file immediately before and after reset. All seven source rows and the completed notebook/footer fit the target window.

Initial validation caught an unparented map allocation during case activation; it was removed rather than suppressing resource errors. The longer source list and pinned summary were adjusted after inspecting the rendered view. Deliberately failed/locked-save warnings are expected; final passing runs contain no engine/script errors.

These checks repeat in rendered and packaged runs; do not add them as separate unique tests. The initial Case 2 owner session was about seven minutes with all hints used. The owner clarified that submission did not support all findings; capture versus archive time, camera time zone, instructions/hints and feedback were confusing. This is an incomplete-session observation, not completion timing.

### Case 2 clarity revision - 20 October 2026

Record 03 now separates camera display from archive processing, including an explicit processing-time header. Record 04 labels its administrative copy time separately and spells out the camera clock convention. Finding 2 asks for capture, not processing; staged hints specify the event, conversion and citation actions. Incomplete feedback lists missing citations even when the selected answer is also wrong, explains pinning versus citing, and says to return, correct and resubmit. Accepted answers, required citation pairs, case versions and save paths are unchanged.

Existing submitted results are recomputed on load. Resume the saved case and use **Review latest result**; no reset is required. A new scripted flow deliberately chooses a wrong time and unpins its supporting clock record, then corrects only the answer, then pins/cites/resubmits to reach completion. Native rendering and packaged checks remain distinct from owner usability confirmation.

## Asset/provenance register

| Material | Source | Treatment |
|---|---|---|
| Godot engine and built-in components | Official `godotengine/godot` 4.7.2 release | Engine/third-party license information is available through the in-game Licenses button |
| UI and case documents | Authored for this project | No external imagery, map tiles, fonts or audio files |
| Offline Batanes coastlines | Natural Earth 1:10m land, version 5.0.0 | Public-domain polygon subset; source and transformation details below; also credited in the app and packaged instructions |
| Basic place identification | Basco and Itbayat references in the case sketch | Facts used for context; no copied article text or media |
| Incident, organizations and vessel data | Synthetic scenario | Not a historical incident or live operational dataset |

All functions are local. No runtime model calls, analytics, accounts, paid assets or API subscriptions. Future audio, imagery and other basemap choices need their own license review.

### Coastline provenance and reproduction

- [Pinned source GeoJSON](https://raw.githubusercontent.com/nvkelso/natural-earth-vector/ace5fed0eaf3c6c03c951e75b439ba8fffbc218e/geojson/ne_10m_land.geojson), revision `ace5fed0eaf3c6c03c951e75b439ba8fffbc218e`.
- [Source license](https://github.com/nvkelso/natural-earth-vector/blob/ace5fed0eaf3c6c03c951e75b439ba8fffbc218e/LICENSE.md): map data is public domain; modification and redistribution permitted. Credit: **Made with Natural Earth**.
- Reviewed input SHA256: `1ac90796408bc6ad6911d69448485d3c4dbf2190370080368a09976e1c9f7416`.
- [Bundled subset](./content/batanes_coastline.json): six complete island exterior rings, 70 coordinate pairs including repeated closing vertices. WGS84 longitude/latitude order; no additional simplification, clipping, tiles or invented coastlines.
- [Extraction utility](../../tools/extract-coastline.cjs) selects whole islands inside longitude 121.55-122.25 and latitude 20.1-21.15. It checks the source hash and rejects selected polygons with holes or crossing the bounds.
- To reproduce, download the pinned GeoJSON to the ignored local path below, then run Node (not required to play):

```powershell
node .\tools\extract-coastline.cjs .\.tools\geodata\ne_10m_land.geojson .\games\regional-desk\content\batanes_coastline.json
```

Two synthetic fixes were moved offshore when the real coastlines exposed inland positions: 07:40 is now 20.760 N, 121.775 E; 09:00 is 20.675 N, 121.820 E. Source prose and map coordinates changed together. No historical observations, answer rubric or save identity changed.

## Quality boundaries

The prototype tests whether the information loop works. It has text placeholders instead of forensic imagery, generalized coastlines rather than a detailed chart, and no sound design or 3D. All evidence is immediately available; there is no search engine, branching campaign or regional simulator. Confidence is reflective, not scored.

The next gate is clear owner completion of the revised Case 2, before deciding on additional content or broader presentation polish.
