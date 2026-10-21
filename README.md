# Regional Intelligence Game Portfolio

Personal, offline Windows games about evidence, uncertainty and regional decisions. Real geography, clearly labeled fictional incidents, and one playable title at a time.

**Current status:** The Godot prototype now includes three investigations, case selection, separate progress saves, mission/help guidance, completion feedback and offline coastlines. Case 1's familiar-owner replay took about five minutes with no remaining confusion. After an initially confusing, incomplete Case 2 session, the owner reports that the corrections made the information understandable; its replay took about five minutes with all selections correctly determined. These are familiar-content results, not novice timing. This is not yet a polished release or the planned two-hour Game 1.

Repository: [PCSchmidt/regional-intelligence-games](https://github.com/PCSchmidt/regional-intelligence-games).

**New investigation and maps:** *The Echoed Warning* is implemented: six records about repeated reporting, a correction and independent corroboration. The approved offline map upgrade adds shaded relief, approximate contours, sourced roads/buildings and an expanded view with Basco, Itbayat-town and Chinapoliran-port presets. The owner completed Case 3 in about five minutes after a couple of submissions and reports the expanded map looks good; hint use and the final supported-finding count were not reported. This is not a satellite view or 3D production.

## Portfolio

| Order | Working title | Scope and status |
|---|---|---|
| 1 | Regional Analysis Desk | Three concise evidence investigations implemented; the approximately two-hour target remains unverified and subject to playtest recalibration. |
| 2 | Cable Ship | Planned bounded, realistic 3D ship/ROV investigation. Production has not started. |
| 3 | Regional Strategy | Planned discrete-turn decisions under uncertainty. Production has not started. |

The [master plan](./MASTER_PLAN.md) records decisions, constraints and milestone gates. The baseline is approximately 10 owner hours/week, a $20/month project AI budget, free licensed assets initially, and no mandatory runtime AI or online services.

## Play the three-case prototype

**The Missing Interval** asks what the available records establish about a fictional vessel's missing public positions around Basco/Batan and Itbayat, Philippines.

**The Borrowed Name** adds a distinct investigation involving similar vessel names, camera-clock conventions and independent position reports. It contains seven fictional text records, not a real photograph.

**The Echoed Warning** asks how reports obtained their information, what a correction changes and what a separately kept record supports. All its times are UTC; its map is regional context, not an invented vessel track.

Read the selected case's sources, compare records and the timeline, pin evidence and submit three supported findings. Mission & Help explains how to begin; a result dialog and persistent count identify completion. Use **Cases** to open any investigation, or **Continue to Case 2/3** after completing the preceding case. Each case saves independently; existing progress is preserved. **Expand map** opens the town presets. Terrain, mapped streets/buildings, available port outlines and a kilometer/meter scale provide context, not additional evidence. Itbayat has named port points and roads but no supplied pier outlines; no facilities are invented.

- [Controls, save behavior and verification results](./games/regional-desk/README.md)
- [Concept and requirements](./specs/game-01/spec.md)
- [Author-only case sketch and rubric - spoilers](./specs/game-01/CASE_01.md)
- [Author-only second-case evidence graph and rubric - spoilers](./specs/game-01/CASE_02.md)
- [Author-only third-case design and rubric - spoilers](./specs/game-01/CASE_03.md)

The owner comprehension gate for **The Borrowed Name** is now met: the revised information made sense, and all selections were correctly determined in about five minutes. Hint use and the final supported-finding count were not explicitly reported. Preserve the earlier seven-minute incomplete session as evidence of the original confusion; do not average it with the replay or treat either as novice completion timing. The third-case design was approved and implemented, and its owner comprehension gate is now met: about five minutes to completion after a couple of submissions, with the expanded map reported as looking good. Hint use and the final supported-finding count were not reported. Fresh-player testing remains useful if available; enjoyment and novice usability are not established by automated checks.

## Run from source

Use **Godot 4.7.2 standard Windows x64**, not the .NET build. The prototype uses GDScript and the GL Compatibility renderer.

1. Obtain the engine from the [official Godot release](https://github.com/godotengine/godot/releases/tag/4.7.2-stable).
2. Import [the Godot project](./games/regional-desk/project.godot) in the editor and run its main scene.

Alternatively, from the repository root in PowerShell:

```powershell
.\tools\prototype.ps1 -Mode Run -GodotPath 'C:\path\to\Godot_v4.7.2-stable_win64_console.exe'
.\tools\prototype.ps1 -Mode Test -GodotPath 'C:\path\to\Godot_v4.7.2-stable_win64_console.exe'
```

The optional local-tooling convention is `.tools\godot\Godot_v4.7.2-stable_win64_console.exe`, alongside the engine executable from the same archive. With that layout, omit `-GodotPath`. Engine downloads are not committed.

### Windows export

Obtain the matching official export templates. Extract these two files from the template archive into `.tools\godot\templates`:

- `windows_release_x86_64.exe`
- `windows_debug_x86_64.exe`

These are the custom paths configured in [the export preset](./games/regional-desk/export_presets.cfg). From the repository root:

```powershell
.\tools\prototype.ps1 -Mode VisualTest
.\tools\prototype.ps1 -Mode Export
.\tools\prototype.ps1 -Mode PackagedTest
```

Supply `-GodotPath` on these commands if using a different engine location. Export produces `builds\RegionalDesk-Windows.zip`; extract it before launching the included executable. The unsigned personal build may trigger an unknown-publisher warning. Do not disable Windows security to run it.

Generated builds are local outputs, not files distributed by this repository. No GitHub Release has been published.

## Repository layout

- [games/regional-desk](./games/regional-desk): Game 1 source, synthetic case content and tests.
- [specs/game-01](./specs/game-01): Concept, requirements and case design.
- [tools](./tools): PowerShell run, test and export entry point.
- [MASTER_PLAN.md](./MASTER_PLAN.md): Portfolio direction and progress.
- The three original conversation documents: brainstorming inputs retained with the owner's approval, not independently verified specifications. The master plan supersedes conflicting recommendations.

Local engines, Godot caches, generated builds and temporary files are excluded from Git. Each game stays in its own folder; split repositories only when independent delivery or tooling needs justify it.

## Content and licenses

Places are real; the incidents, vessel activity, organizations and records are synthetic. The offline map bundles derived **OpenStreetMap contributors** data under **ODbL-1.0**, Mapzen/USGS/NOAA relief, and the earlier public-domain Natural Earth reference. No website map tiles or satellite imagery are bundled. [Offline source/license notices](./games/regional-desk/content/MAP_DATA_LICENSES.md) and [geographic provenance/reproduction](./games/regional-desk/README.md#offline-terrain-and-town-map) distinguish vector detail from the elevation grid's variable effective resolution. The derived OSM database is separately available under ODbL; this does not license the game code.

No project-wide reuse license has been selected. Godot and its built-in components retain their own licenses; engine and third-party notices are accessible through the prototype's **Licenses** button.
