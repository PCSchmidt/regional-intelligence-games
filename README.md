# Regional Intelligence Game Portfolio

Personal, offline Windows games about evidence, uncertainty and regional decisions. Real geography, clearly labeled fictional incidents, and one playable title at a time.

**Current status:** The Godot prototype now includes two investigations, case selection, separate progress saves, mission/help guidance, completion feedback and offline coastlines. Case 1's familiar-owner replay took about five minutes with no remaining confusion; Case 2's first owner session lasted about seven minutes, used all hints and remained incomplete, with confusion about camera/record times and feedback. The current clarity revision needs a replay. This is not yet a polished release or the planned two-hour Game 1.

Repository: [PCSchmidt/regional-intelligence-games](https://github.com/PCSchmidt/regional-intelligence-games).

## Portfolio

| Order | Working title | Scope and status |
|---|---|---|
| 1 | Regional Analysis Desk | Two maritime evidence investigations implemented; eventual target is three linked investigations totaling about two hours, subject to playtest recalibration. |
| 2 | Cable Ship | Planned bounded, realistic 3D ship/ROV investigation. Production has not started. |
| 3 | Regional Strategy | Planned discrete-turn decisions under uncertainty. Production has not started. |

The [master plan](./MASTER_PLAN.md) records decisions, constraints and milestone gates. The baseline is approximately 10 owner hours/week, a $20/month project AI budget, free licensed assets initially, and no mandatory runtime AI or online services.

## Play the two-case prototype

**The Missing Interval** asks what the available records establish about a fictional vessel's missing public positions around Basco/Batan and Itbayat, Philippines.

**The Borrowed Name** adds a distinct investigation involving similar vessel names, camera-clock conventions and independent position reports. It contains seven fictional text records, not a real photograph.

Read the selected case's sources, compare map/timeline observations, pin evidence and submit three supported findings. Mission & Help explains how to begin; a result dialog and persistent count identify completion. Use **Cases** to open either investigation, or **Continue to Case 2** after finishing the introduction. Each case saves independently; existing first-case progress is preserved. Real generalized coastlines, named islands, differentiated symbols and a kilometer scale provide geographic context.

- [Controls, save behavior and verification results](./games/regional-desk/README.md)
- [Concept and requirements](./specs/game-01/spec.md)
- [Author-only case sketch and rubric - spoilers](./specs/game-01/CASE_01.md)
- [Author-only second-case evidence graph and rubric - spoilers](./specs/game-01/CASE_02.md)

For the next playtest, resume **The Borrowed Name** using its revised camera/clock records, ordered hints and explicit correction feedback. Existing saves are retained; no reset is needed. The owner spent about seven minutes on the first Case 2 session, used all hints and submitted without all findings supported; capture versus archive time, the camera time zone and feedback were confusing. That is not completion timing. Case 1's improved five-minute replay was familiar content. Automated checks do not establish enjoyment or novice usability.

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

Places are real; the incidents, vessel activity, organizations and records are synthetic. The prototype bundles public-domain Natural Earth land polygons, not map tiles, imagery or audio. **Made with Natural Earth.** [Geographic provenance, license and reproduction](./games/regional-desk/README.md#coastline-provenance-and-reproduction) and the case sketch record sources and limitations.

No project-wide reuse license has been selected. Godot and its built-in components retain their own licenses; engine and third-party notices are accessible through the prototype's **Licenses** button.
