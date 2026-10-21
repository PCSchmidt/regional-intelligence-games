# Cable Ship - Survey 01

An offline, first-playable **3D prototype**, not finished realistic production art.
One aft deck, one compact ROV survey and two evidence-supported findings.
Real Batanes regional context; fictional incident and authored seabed.
No audio, internet connection, account, AI API or paid assets required.

## Start

Extract the ZIP, then double-click `CableShip.exe`. This unsigned personal build
may show an unknown-publisher warning. Do not disable Windows security to run it.
Use Windows x64 with a Vulkan-capable GPU for Godot Forward+.
The development laptop is not a certified minimum specification.

1. Read and close Mission & controls; click the deck to capture the mouse.
2. Walk toward the glowing console with **WASD**; press **E** within 3 m.
3. Choose **Launch / resume ROV**. Visit the numbered marks on the survey plot.
4. Fly within 6 m of an unrecorded feature and place it near the center of view.
   When the capture prompt appears, press **F** to retain a real image.
5. **Tab** recovers the ROV and opens review. Read the observations alongside the
   recorded images. Choose both conclusions and tick their supporting captures.
6. Submit, review feedback, and revise until both findings are **SUPPORTED**.
   Hints are optional. You can return to the console to resume surveying.

## Controls

| Input | Action |
|---|---|
| WASD | Walk on deck; forward/reverse/strafe in ROV |
| Mouse | Look after clicking the 3D view |
| Q / E | Turn ROV left / right |
| Space / Ctrl | ROV rise / descend |
| H | Toggle depth hold; vertical input changes the held depth |
| F | Capture the framed feature |
| Tab | Recover and open review |
| B | Recover to deck |
| Esc | Release mouse and stop thrust |
| F1 | Reopen mission and controls |

Movement pauses during dialogs, capture and free-cursor use. Click the 3D view
to pilot again. The survey envelope is 70 x 70 m, 0.8-30 m above the authored floor.
Depth and altitude use the same geometry as the terrain. Cable distance is an
approximation at the vehicle's local east/west coordinate, not precision sonar.
The plot marks prior targets, not simulated sonar or newly discovered evidence.
Capture timestamps measure active survey time, excluding pauses and dialogs.

## Saves and images

Progress saves automatically at launch, recovery, edits, captures and active
five-second intervals. Normal window close saves before exiting.
Location: `%APPDATA%\Godot\app_userdata\Cable Ship - Survey\survey`.
Images are PNG files under `captures`; the JSON links them to observations.
Do not move individual images out of this folder while continuing a survey.

**Reset** requires confirmation and renames the save to a backup before starting
again. Old images are retained. An unreadable save is preserved and put in
protected mode; use Reset to back it up explicitly. Regional Desk uses a separate
directory and is unaffected.

## Prototype limits and licenses

Procedural first-pass art, simplified thrust/drag and point-floor collision,
static marine snow, instant launch/recovery, no tether/repair/crew simulation.
This is not a forensic training tool. Written observations are authored evidence;
not every material-age or microscopic detail is represented in these meshes.
Human playtime, enjoyment, realism and novice clarity still need a playtest.
Use **Licenses** for procedural-asset notices and Godot/third-party license texts.
