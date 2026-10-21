# Game 2 - Cable Ship: bounded 3D prototype contract

**Status:** First playable implemented, exported and technically verified on
21 October 2026. Owner realism/usability playtest pending. The owner approved
the bounded prototype path; detailed scenario/art choices below are implementation
assumptions, not individually approved production specifications.
**Milestone:** M6 - bounded 3D prototype.
**Project:** `games/cable-ship` (separate Godot project, Forward+ renderer).

## Purpose

Game 2 is the explicit home for realistic 3D in this portfolio. This prototype
proves one thing only: that a believable ship-to-seabed inspection loop can be
built, measured and shipped offline by one owner at roughly 10 hours/week. It is
not a cable-repair simulator, a crew simulation or a sailing game.

The prototype must answer four questions the master plan defers to M6:

1. Is there a 3D art direction that reads as realistic without paid assets?
2. Can the required assets be produced or licensed for offline redistribution?
3. What exactly does the player do with the ROV, and where does it stop?
4. What is the measured rendering cost on the known development hardware?

## Player fantasy

You are the survey operator on a cable ship. A submarine communications cable has
failed. Before anyone commits a repair, you must fly the work-class ROV, look at
the seabed yourself, and identify the best-supported explanation - then defend that answer with
the frames you captured.

## Setting

Real geography, fictional incident. The survey area is a bounded patch of the
insular slope in the Bashi Channel, south-east of Itbayat, Batanes, Philippines,
at roughly 420 m depth. The cable, the vessel, the operator and the fault are
fictional. No real cable system, company or historical event is described.

Coordinates are authored for the scenario and are not a claim about any real
cable route.

## Loop

1. **Deck brief.** First-person walk on a compact night-time aft deck. The ROV
   sits in its cradle under the A-frame. A console gives the survey question.
2. **Launch.** Interacting with the console starts the dive.
3. **Pilot.** Fly the ROV inside a bounded survey box. Read depth, altitude,
   heading and cable proximity. Two work lights illuminate a short cone.
4. **Capture.** Frame a feature and capture it. Each capture stores a timestamp,
   depth, position and a rendered frame.
5. **Assess.** Return to the console. Choose the mechanism and the decoy
   interpretation, citing captured frames.
6. **Debrief.** The desk explains what the frames support and what they do not.

## Evidence design

Four capturable features. Two support the accepted answer; two are decoys that
punish single-clue reasoning.

| ID | Feature | Supports |
|---|---|---|
| `suspended_span` | Cable lifted clear of the seabed between two contact points, with abrasion polish on the span | Accepted mechanism |
| `net_fragment` | Synthetic netting fragment snagged on the span | Accepted mechanism |
| `sediment_channel` | Linear furrow with draped, rounded shoulders and older sediment fill | Decoy - looks like anchor drag |
| `slide_lobe` | Older slide lobe with a degraded head scarp | Decoy - looks like slope failure |

**Finding 1 `mechanism`** - accepted `trawl_snag`; rejected `anchor_drag`,
`slope_failure`. Required citations: `suspended_span` and `net_fragment`.

**Finding 2 `decoy`** - accepted `pre_existing_channel`; rejected
`recent_anchor_drag`, `active_slope_failure`. Required citations:
`sediment_channel`.

The lesson matches Game 1: a single dramatic-looking feature is not a conclusion.
In the authored scenario, settled sediment and degraded edges favor pre-existing
features over fresh failure mechanisms. This is a comparative interpretation,
not forensic proof of feature age or a uniquely established failure mechanism.

## 3D art direction

- **Palette:** cold blue-green water, warm sodium deck lighting, amber ROV work
  lights. High contrast between the lit cone and the surrounding dark.
- **Scale:** ROV 3.1 m long, 1.8 m wide, 1.9 m tall. Deck 22 m x 14 m. Survey box
  70 m x 70 m x 30 m. Cable 0.09 m diameter.
- **Materials:** physically based, procedurally textured. Sediment is rough and
  slightly varied; steel is metallic with low roughness; the cable jacket is dark
  and semi-rough; netting is a thin synthetic mesh.
- **Lighting:** no sun underwater. Two ROV spotlights plus a very low ambient
  fill. Volumetric fog for turbidity. Marine snow particles for depth cues.
- **Composition:** the lit cone is the frame. Everything outside it is suggested,
  not modeled.
- **Sound:** out of scope for this prototype. Recorded as a known gap.

## Asset and licensing decision

No third-party art assets are downloaded or bundled. All geometry is generated
procedurally in GDScript from engine primitives and authored parameters; all
textures are engine-generated noise. This keeps the build reproducible, offline
and free of redistribution risk, and it is recorded as a deliberate limitation:
procedural geometry reads as clean and industrial, not photoreal.

If a later milestone wants scanned or hand-authored assets, they must be CC0 or
otherwise redistributable, with source, author, license and retrieval date
recorded in `content/ASSET_LICENSES.md`.

## Interaction boundaries

In scope:

- First-person walk on one deck area, mouse look, interact prompt.
- ROV thrust, drag, depth hold, bounded survey box, seabed collision floor.
- Two work lights, camera capture, four instrument readouts, prior-target survey plot (not sonar).
- Four capturable features, two findings, citation-checked assessment.
- Versioned local save, resume, reset.

Explicitly out of scope:

- Cable repair, tool operation, manipulator physics.
- Crew, characters, dialogue, voice.
- Global sailing, weather, currents, tides.
- Full sonar simulation, acoustic modelling, real bathymetry.
- Multiplayer, runtime AI, network services, telemetry.
- Photoreal assets, motion capture, character animation.

## Performance budget

Target: 60 fps at 1920x1080 on the known development hardware (RTX A4500 Laptop,
i9-12950HX). Floor: 30 fps. The prototype ships a benchmark mode that reports
measured average, 1% low and worst frame time over a fixed camera path, so the
budget is evidence rather than an estimate.

Budget ceilings: under 250 draw calls, under 400k visible triangles, one
directional-free environment, two shadow-casting spotlights maximum.

## Acceptance criteria

- **AC-01:** The deck scene loads, accepts first-person input and reaches the
  console interaction without error.
- **AC-02:** Launching transitions to the survey scene with the ROV at the
  authored start position and correct initial instrument readings.
- **AC-03:** ROV motion is thrust-and-drag based, bounded by the survey box and
  the seabed floor, and reproducible from a fixed input sequence.
- **AC-04:** Depth, altitude, heading and cable proximity read correctly against
  the shared seabed height function.
- **AC-05:** Each of the four features can be captured only within range and
  while framed; captures record timestamp, depth, position and a frame.
- **AC-06:** Assessment accepts `trawl_snag` + `pre_existing_channel` with the
  required citations, and rejects every authored alternative and every missing
  required citation with specific feedback.
- **AC-07:** Progress survives save, reload and reset; a corrupt save is
  preserved rather than silently discarded.
- **AC-08:** The Windows export runs from an extracted location outside the
  editor, offline, with no missing resources.
- **AC-09:** Benchmark mode reports measured frame times on the development
  hardware.
- **AC-10:** No third-party asset is bundled without a recorded license.

## Known limitations to state in the build

- Procedural geometry, not photoreal art.
- No audio.
- One survey area, one fault, one accepted answer.
- Authored seabed, not real bathymetry.
- Playtime remains unmeasured until a human playtest; the two-hour target applies to Game 1.
- Performance measured on one machine only.

## Implementation evidence

See [verification and current limitations](../../games/cable-ship/README.md).
All ten technical acceptance surfaces have runnable coverage, including actual
rendered captures and extracted export. Realism, enjoyment and novice usability
are not established by those checks. Throughput and geometry budgets pass the
final 30-second sample, including its strict 30 fps floor. An earlier sample
contained a long-frame hitch; sustained repeatability remains unverified.
The benchmark reports the strict floor separately from average/1% low throughput.
