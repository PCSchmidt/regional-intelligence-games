# Master Plan - Regional Intelligence Game Portfolio

**Status:** v2 - confirmed direction; first Godot interaction prototype technically verified, owner playtest pending
**Updated:** 2026-10-20
**Purpose:** Deliver a small, polished portfolio series about investigation, uncertainty and regional decision-making. Build one playable title at a time.

**Repository:** [PCSchmidt/regional-intelligence-games](https://github.com/PCSchmidt/regional-intelligence-games) - one public portfolio repository, with games in separate folders. Original conversation documents are included with owner approval; local engines, caches and generated builds are excluded. See [setup and repository layout](./README.md).

## 1. Confirmed direction and constraints

| Topic | Decision |
|---|---|
| Ownership and purpose | Personal projects on personal equipment; portfolio use with very few expected users. The user has confirmed no employment-contract conflict. No employment-clearance prerequisite. |
| Geography | Real places: the South China Sea, Philippines, Singapore, Taiwan and Japan. This is a regional envelope, not a promise to model every location. |
| People and events | Fictional people by default. Historical people may appear where supported by reliable historical sources. Clearly separate fictional incidents from documented events. |
| Period | Provisional baseline: contemporary fictional scenarios against real geography. Historical and near-future alternatives remain possible. |
| Game 1 | Regional analysis desk anchored by maritime investigations; approximately two hours total, including onboarding and debriefs. No 3D requirement. |
| Later games | A realistic cable-ship/ROV investigation, followed by a regional strategy game. Titles and detailed scope remain provisional. |
| Audience | Non-specialists: authentic reasoning, guided tools, optional hints and no assumed professional training. |
| Platform | Windows desktop download, keyboard/mouse, offline play. |
| Human availability | Approximately 10 hours/week for direction, content review, integration and playtesting. AI performs most coding and assists content production. |
| AI budget | Hard cap of $20/month in project model usage. Prefer inexpensive capable models, including the user's suggested DeepSeek V4.1 Flash 1017, subject to checking availability and actual pricing. |
| Assets | Free licensed assets initially; no required purchases. Model budget is separate from any later explicitly approved non-model expense. |
| Engine | Godot is the leading candidate for the series. Choose language and commit to architecture after a small technical prototype. |
| Playtesting | The owner will test; outside testers are desirable but not guaranteed. Do not report self-testing as independent usability evidence. |

### Source documents and how to use them

- [OSINT Game Design & AI Co-Building Architecture](./OSINT%20Game%20Design%20%26%20AI%20Co-Building%20Architecture.md)
- [OSINT Game Planning Concepts, AI Tooling and Meridian Review](./OSINT%20Game%20Planning%20Concepts%2C%20AI%20Tooling%20and%20Meridian%20Review.md)
- [OSINT Game Development Strategy](./OSINT_Game_Development_Strategy.docx)

These are concept inputs, not mutually consistent specifications or independently verified research. They disagree about engines, simulation scope, title selection and harness timing. This plan supersedes their conflicting recommendations where decisions are recorded here.

### Corrections to draft v1

- Real geography is allowed and desired; an invented archipelago is not required.
- Commercial release, Steam marketing and employment review are not project prerequisites.
- Content/code effort percentages, fixed engine-package size comparisons, language/model superiority claims and a claimed threefold 3D schedule multiplier were not established project measurements. Do not use them as estimates.
- Simulations can be tested. Their challenge is defining useful behavioral and balance criteria, not an inability to verify code.
- Formal validation cannot prove that natural-language evidence is unambiguous, a puzzle is enjoyable or a human will infer the intended answer.
- Neither a full regional simulator nor a hardened agent harness must precede the first playable investigation.

## 2. Recommended portfolio and build order

### Game 1: Regional Analysis Desk - working concept

**Player fantasy:** Turn incomplete, conflicting public information into a defensible assessment of a regional incident.

| Candidate focus | Strength | Main risk | Determination |
|---|---|---|---|
| Maritime investigator | Concrete spatial and temporal puzzles; strong connection to Game 2 | Repetitive vessel tracking | Use as the investigative backbone |
| Broad regional analyst | Combines maritime, aviation, infrastructure and political context | Dashboard sprawl; too many shallow tools | Use as the framing, not a fully simulated world |
| Media verification specialist | Accessible cross-referencing and chronology | Becoming a collection of generic authenticity minigames | Include only techniques needed by a case |

**Selection:** Regional analysis anchored by maritime incidents. The player investigates observable events, considers alternative explanations and submits a supported assessment. Do not simulate an entire intelligence organization.

**Core loop:**

1. Receive a concrete question and a small initial evidence set.
2. Inspect maps, documents and time-stamped observations.
3. Compare claims, resolve entities and annotate an evidence timeline.
4. Test a hypothesis against corroborating and conflicting evidence.
5. Submit conclusions, supporting evidence and a confidence judgment.
6. Receive an explanatory debrief and advance the linked story.

**Initial content target:** Three linked investigations, approximately two hours combined. This is a design target to measure during playtesting, not a duration guaranteed by case count.

| Investigation | Proposed question | Distinct learning goal |
|---|---|---|
| 1 - Unexpected movement | Where did a vessel go, and what can the available observations actually establish? | Map/time cross-referencing and distinguishing gaps from proof |
| 2 - Communications outage | How do infrastructure reports, vessel activity and competing public accounts fit together? | Corroboration, provenance and alternative explanations |
| 3 - Regional assessment | What is established, what remains uncertain and which interpretation is best supported? | Evidence synthesis and calibrated conclusions |

These are fictional incident sketches, not historical claims or final scripts. Narrow the first case to one route or locality within the regional envelope. Other named places may appear as context without becoming explorable locations.

**Game 1 exclusions:** Combat, multiplayer, open-world travel, live feeds, mandatory external web research, unrestricted chat characters, a full nation simulator and elaborate desktop-OS emulation.

### Game 2: Cable Ship - realistic bounded 3D

**Player fantasy:** Investigate an undersea communications failure from a cable vessel, connecting physical observations with the evidence skills learned in Game 1.

- One compact ship area and one bounded ROV survey area.
- A focused loop: receive survey question, inspect instrumentation, operate ROV, capture evidence and revise an assessment.
- Prioritize believable scale, materials, lighting, sound and instrument behavior over geographic size.
- Begin with basic ROV movement and inspection, not a complete cable-repair or ocean-physics simulator.
- No large crew simulation, extensive character animation, global sailing or fully modeled ship systems in the initial scope.
- Reuse setting research and evidence concepts where useful, not an assumption that Game 1 code will transfer unchanged.
- Set its playtime after a 3D interaction prototype; the two-hour target currently applies to Game 1.

Game 2 is the explicit home for realistic 3D in this series. A small visual experiment may precede it, but must not displace delivery of Game 1.

### Game 3: Regional Strategy - decisions under uncertainty

**Player fantasy:** Make bounded regional decisions with incomplete information and see the consequences.

- Prefer a discrete-turn model with a small set of actors, resources and scenario drivers.
- Separate the hidden scenario state from the information visible to the player.
- Test transitions, invariants, reproducibility and scenario outcomes; evaluate balance through play.
- Procedural variation and a broader simulator are optional later capabilities, not shared infrastructure required now.
- Select the playable decision-maker and geographic scope during its own concept phase.

No fourth title is scheduled. Retain other source concepts as a backlog, not simultaneous commitments.

## 3. Authenticity, geography and evidence policy

### Real places; clearly labeled scenario fiction

- Use correct names, spatial relationships and relevant public geographic facts.
- Keep a dated source record for historical assertions and identify the scenario's reference date.
- Use fictional people, vessels and companies for invented wrongdoing rather than implying unsupported accusations against identifiable real parties.
- A real historical person may appear when the depiction is supported by sources; do not silently invent quotations or conduct and present them as fact.
- Distinguish real geographic background, documented history and synthetic scenario evidence in content metadata and player-facing context.
- Represent regional communities and local agency, not just external-power competition. Avoid treating national identity as evidence of culpability.

### Offline and reusable sources

Do not assume that public visibility permits redistribution. Select geography, imagery, fonts, audio and other assets with licenses suitable for inclusion in an offline downloadable build.

For each external asset or dataset, retain source, author/provider, license, attribution, modifications and retrieval/version date. Check derived map exports and imagery as well as raw source files. No required commercial map API or paid AIS subscription.

Use a limited offline map dataset or authored map derived from appropriately licensed sources. Avoid downloading or bundling a global basemap. Every required clue must ship with the build.

### Honest analytical mechanics

Missing AIS observations are not automatically evidence of wrongdoing. Metadata and image-analysis artifacts are not infallible authenticity detectors. Cases should teach corroboration and limitations, rather than claim that a single technical clue proves intent.

Allow conflicting reports as deliberate story evidence. The validator must distinguish a source's claim from scenario ground truth rather than reject every disagreement as a content error.

## 4. Architecture and tooling

### Godot-first, evidence-based commitment

Start by testing a suitable stable Godot release, recording its exact version and Windows export requirements. Do not automatically introduce React, Tauri, Rust, a database or Python.

The prototype must demonstrate:

1. A readable document view with scrolling and text selection or an equivalent evidence-selection interaction.
2. A bounded pan/zoom map with selectable markers and a synchronized timeline.
3. Evidence pinning and a structured assessment/debrief.
4. Local JSON loading, explicit validation errors and useful automated checks.
5. Save/reload and a Windows export that runs offline outside the editor.

**Pass condition:** These interactions work together, are readable at the chosen test resolution and can be iterated without excessive integration effort. Record actual issues and elapsed human effort.

If Godot's document/map UI proves a material obstacle, evaluate a small web desktop alternative for Game 1. Do not add a second production pipeline merely because the source conversations proposed one.

### Language selection

GDScript and C# remain candidates. Build the first small spike in one, then compare only the difficult portion in the other if there is a specific unresolved limitation.

Choose on observed implementation reliability, debugging, automated testing, UI integration, export behavior and maintenance. AI authoring does not eliminate those costs. If C# wins, install the compatible .NET tooling and use the appropriate Godot build; otherwise .NET is not required.

**Prototype decision, 20 October 2026:** Continue Game 1 with Godot 4.7.2 standard, GDScript and the GL Compatibility renderer. The [first interaction prototype](./games/regional-desk/README.md) integrates document reading, a schematic/timeline, evidence citations, assessment, validated local saves and Windows export. Automated scene/persistence checks and an extracted release startup passed. No observed blocker currently justifies adding C#/.NET or a second UI stack. This is not a language benchmark, a minimum-hardware certification or a final decision for every later title.

### Minimal runtime structure

```text
Scenario content and licensed map assets
                 |
        Loader and content checks
                 |
   Case state and assessment rules
          /                  \
 Godot UI/scenes        Versioned local save
```

- **Content:** Engine-independent JSON for case IDs, entities, observations, claims, documents, clue relationships, accepted conclusions and hints.
- **Domain logic:** Separate discovery, progression and assessment rules from scene presentation so they can be tested.
- **Presentation:** Start with four workspaces: map/timeline, evidence viewer, notebook and assessment. Tabs or panels are acceptable; a window manager is not required.
- **Persistence:** Versioned local saves with stable content IDs; preserve notebook, progress, settings and hint state. Write safely and surface corrupt or incompatible saves rather than silently resetting them.
- **Runtime:** Deterministic authored cases. No mandatory network, model service or telemetry.
- **Tools:** Use engine-supported checks and a small validation command. Introduce standalone tooling only when it solves a demonstrated content or test need.

### Sharing across the series

Share research, provenance records, data conventions and reusable evidence concepts first. Extract shared runtime code only after a second title has a concrete need.

Keep public facts, synthetic scenario state and player knowledge separate. Do not build a universal cross-engine framework, distributed backend, graph database or general agent-based simulator for Game 1.

### Known development hardware

- Intel Core i9-12950HX, 16 cores / 24 logical processors.
- Approximately 64 GB RAM.
- NVIDIA RTX A4500 Laptop GPU, plus integrated Intel graphics.

This is a capable development starting point, not a minimum specification. Profile Game 1 and a bounded 3D scene before selecting a lower hardware target. Godot was initially absent from PATH; a portable official engine and matching Windows templates are now installed under the ignored local `.tools` directory. System PATH is unchanged.

## 5. Content, assessment and validation

### Author one case alongside the interface

Write a short evidence-and-answer sketch before implementation. Then co-evolve a thin content format, minimal checks and the playable interface. Do not finish a large schema or a solver platform before testing the interaction.

A case should record:

- Scenario ID/version, geographic extent and reference time convention.
- Ground truth, source claims and intended uncertainties.
- Evidence IDs, provenance, accessibility descriptions and discovery conditions.
- Supported conclusions, acceptable alternatives and evidence requirements.
- Progression conditions, hints, debrief explanations and replay/reset behavior.

Define coordinate reference, distance units, UTC storage and local-time display explicitly. Normalize names and IDs rather than grading arbitrary text formatting.

### Proposed assessment design

Use structured conclusions linked to selected evidence, with an optional confidence choice and an explanation in the debrief. Avoid exact free-text grading.

Support partial correctness and legitimate uncertainty. Do not adopt mandatory three-answer batches or punitive confidence scoring without testing whether they suit these cases. A confidence mechanic must have a clear rubric; it must not punish reasonable caution or reward an unjustified claim merely because it matches hidden truth.

Use location/time tolerances only where required by a puzzle. Advanced solar geometry, audio analysis or crypto tracing are not baseline systems.

### What automation can establish

| Check | Evidence provided | Limitation |
|---|---|---|
| Content structure | Required fields, supported versions and valid IDs/references | Does not establish factual or narrative quality |
| Declared clue graph | Required evidence is reachable under modeled conditions | Cannot prove a player will notice or understand it |
| Assessment rules | Accepted/rejected example submissions behave as specified | Only covers the authored answer model |
| State transitions | Tested discovery orders, save/reload and progression remain usable | Exhaustive claims require a bounded, enumerated state model |
| Chronology/geography | Declared times, coordinates and relationships satisfy explicit constraints | Does not validate every implication of prose or imagery |
| Replay/export | A packaged build completes defined offline walkthroughs | Does not establish fun or independent usability |

Where a finite puzzle model permits exhaustive uniqueness checks, use them. Otherwise record authored alternatives and test counterexamples; do not advertise a general proof of uniqueness.

Test interruption, revisiting documents, incorrect submissions, hints, case reset and save migration/failure behavior as those features are introduced.

### Human evaluation

Review whether evidence supports the intended inference, alternative explanations are treated fairly, instructions are sufficient and the payoff is satisfying.

Without outside testers, record owner walkthroughs, confusion points, completion times and subsequent changes. Fresh-session self-tests help but do not replace novice testing. If a volunteer becomes available, prioritize an unassisted first-case session over a large formal test panel.

## 6. AI workflow and $20/month spending control

### Policy

Use one inexpensive capable model for normal work, with small, self-contained tasks. Expensive models and additional agents are exceptions within the same cap, not assumed resources.

Suggested starting allocation, adjustable without raising the cap:

| Use | Monthly allowance |
|---|---:|
| Implementation and repair | $14 |
| Targeted content/code review | $3 |
| Contingency | $3 |
| **Total** | **$20** |

- Check exact model/provider prices, cache pricing and context limits before paid runs. The named DeepSeek model is a candidate, not a verified price/performance promise.
- Track total project usage across providers, including retries and reviews. Do not assume existing subscriptions or free quotas cover unmetered work.
- Enable provider spending controls where available; otherwise pre-authorize bounded calls using current input/output prices and remaining balance. A suggested allocation is not an implemented hard-stop mechanism.
- Stop paid activity before it can exceed the remaining monthly budget. Do not auto-escalate or top up; continue local work or request explicit approval for a changed budget.
- Compare models on a few representative tasks using accepted results, repair effort and total cost. A ten-task benchmark is optional, not a prerequisite.

### Working loop

1. Owner chooses one observable behavior and its acceptance examples.
2. Agent reads the relevant code/content, makes a bounded change and runs applicable checks.
3. Owner inspects the integrated behavior and generated content.
4. Record actual test evidence, relevant decisions and spending.
5. Commit a coherent checkpoint when version control is established.

After two failed repair attempts on the same issue, stop the loop and inspect the failure. Reduce scope, improve the reproduction or consider a budgeted review rather than buying more unbounded retries.

Use actual tests and owner judgment as the baseline. A fresh-context or different-family review may help at important milestones, but is neither always necessary nor proof of correctness.

### Meridian

Meridian is optional. Start with ordinary version control, explicit acceptance examples and executable checks. Add harness integration only if repeated coordination failures justify its maintenance and model costs.

The source review and limited repository inspection identified concerns about missing/stale evaluator verdicts and platform enforcement. Recheck the current implementation before relying on it. A local hook can be bypassed; agent-written metadata is not independent evidence; artifact hashes identify stale results but do not establish a trusted execution boundary.

If adopted, require functioning hooks, verification tied to the evaluated revision, explicit missing-verdict policy and review of where enforcement actually runs. Do not make a harness rewrite part of this game's critical path.

## 7. Specifications and decisions - just enough, just in time

This plan is the current planning artifact. The following are future deliverables, not files to create automatically or prerequisites that all must be completed before prototyping.

| Stage | Minimum specification or record |
|---|---|
| Before the first prototype | One-page concept, first-case evidence sketch, scope exclusions and prototype acceptance checklist |
| During the prototype | Engine/language decision with evidence; initial case/save contracts and test invocation |
| Before expanding content | Regional setting/reference-date brief, case template, assessment rubric, source/license register and UI/audio style sheet |
| Before sharing a build | Controls and hints, credits/attributions, save compatibility, known limitations and offline export walkthrough |
| Before Game 2 | 3D art reference, asset availability, ROV interaction boundaries and measured rendering budget |

For Game 1, design readable scalable text, keyboard navigation, non-color-only markers, adjustable sound and persistent hints/settings. Do not claim accessibility coverage without testing it.

Treat typography, responsive feedback, map readability and restrained audio as quality requirements. Avoid decorative complexity that competes with understanding the evidence.

## 8. Milestone-based build approach

The owner has 10 hours/week. AI can accelerate implementation, but integration, creative review and testing still consume that time. Do not promise a release date until the first playable case provides throughput evidence.

| Milestone | Work | Exit evidence |
|---|---|---|
| M0 - Concept checkpoint | Bound Game 1 to one initial incident/locality; sketch its question, evidence and supported answer | A coherent case on paper; scope and assumptions recorded |
| M1 - Godot interaction prototype | Implement map, document, evidence selection, assessment, basic save/reload and Windows export | One offline integrated path works; language/engine decision recorded |
| M2 - First playable investigation | Add enough authored content for a short complete investigation, hints, debrief and failure-path checks | Approximately 15-25 minute target slice, with actual duration and usability observations recorded |
| M3 - Scope recalibration | Review enjoyment, content effort, bugs and model spend | Keep/cut decisions and a forecast based on measured human effort |
| M4 - Two-hour Game 1 | Expand to the linked three-case target; improve readability, feedback, audio and saves | Complete offline walkthroughs; duration evidence with tester identity/limitations stated |
| M5 - Portfolio delivery | Package executable, instructions, credits and known limitations | Downloadable archive runs from an extracted location outside the editor |
| M6 - Bounded 3D prototype | Start Cable Ship only after Game 1 delivery | One ship-space/ROV inspection loop; performance and visual evidence |
| M7 - Later portfolio titles | Scope Cable Ship, then regional strategy from prototype results | Separate small plans grounded in completed work |

**Suggested first 10-hour block, not a delivery guarantee:**

- 2 hours: first-case question, evidence sketch and visual references.
- 2 hours: source/asset suitability checks, Godot setup and minimal project structure.
- 4 hours: thin interactive path, implemented with bounded AI tasks.
- 2 hours: export check, owner walkthrough, issue triage and spending review.

If setup or research takes longer, reduce the prototype's breadth instead of dropping export/testing. Use focused learning exercises only when they unblock the prototype; several unrelated game-jam projects are not mandatory.

### Current checkpoint - 20 October 2026

- **M0 artifacts available:** [Game 1 concept/requirements](./specs/game-01/spec.md) and [Case 01 evidence sketch](./specs/game-01/CASE_01.md). *The Missing Interval* uses real Basco/Batan and Itbayat geography with a fictional incident and six synthetic records.
- **M1 technical path verified:** 24 case, 19 persistence and 51 scene/UI checks passed; a rendered run passed 52 checks, including its viewport capture. The extracted exported resource pack passed the 51-check journey using the standard engine. Separately, the actual release executable opened a responsive window, autosaved its initialized case and exited normally outside the project. See [commands, evidence and limitations](./games/regional-desk/README.md#verified-checkpoint---20-october-2026).
- **Packaging proof is for this slice only:** The local `builds/RegionalDesk-Windows.zip` contains a runnable Windows prototype and instructions, not the two-hour game or a public release.
- **Still pending:** Owner first-play duration, confusion points, enjoyment, keyboard-only navigation and a readable-text check at the actual preferred display scaling. The first 15-25 minute expanded investigation, full three-case campaign, art/audio polish and weaker-hardware performance are not established.
- **Next gate:** Owner walkthrough, then M2/M3 keep/cut decisions before expanding content or starting 3D production. No paid assets or runtime model services were introduced; human throughput and monthly provider spending still need owner records.

## 9. Guidelines

1. Deliver one game before developing the next in earnest.
2. Real places are welcome; clearly label fictional incidents and source historical claims.
3. Teach evidence and uncertainty, not technical certainty unsupported by the scenario.
4. Prototype a complete interaction early; develop content and checks alongside it.
5. No runtime model or online-service dependency for the baseline games.
6. No full regional simulator, universal framework or harness project before demonstrated need.
7. Use the smallest sustainable toolchain; choose language from project evidence.
8. Keep realistic 3D bounded and prioritize composition, materials, lighting and sound.
9. Generated content and assets require human review and appropriate reuse rights.
10. Treat automated checks, model review and human playtesting as different evidence.
11. Preserve actual failure output; never substitute an agent's completion claim for a passing check.
12. Track human hours and paid model usage; stay within $20/month without automatic escalation.
13. Use version control and backups; no automatic commits, publishing or paid purchases without authorization.
14. Keep exclusions explicit and revisit forecasts after the first playable case.

## 10. Risks and mitigations

| Risk | Mitigation |
|---|---|
| The region becomes five detailed game worlds | Start with one locality/route and treat the rest as context |
| Broad analysis becomes a dashboard with no satisfying decisions | Anchor each case in a concrete question and an evidence-supported conclusion |
| Real geography is mistaken for historical accuracy | Label scenario fiction, maintain dated sources and separate claims from ground truth |
| Offline map/image rights are unsuitable | Verify redistribution rights before investing in integration; keep a source/license register |
| Model usage or repeated repairs exhausts the cap | Bounded tasks, cost tracking, provider limits where available and stop-before-overrun policy |
| Godot document/map UI becomes costly | Test the integrated path before committing; evaluate a desktop-web fallback only if needed |
| Case prose permits unintended interpretations | Review alternative explanations, test counterexamples and document rubric limits |
| AI produces technically plausible but false forensic details | Verify decisive facts and teach limitations; omit unsupported mechanics |
| No independent playtesters are available | Record honest self-test evidence; keep hints and onboarding adaptable |
| Realistic 3D expands into simulation of everything | Limit the ship/survey area and validate one inspection loop first |
| Tooling becomes the main project | Defer custom harnesses, authoring platforms and shared frameworks until justified |

## 11. Decisions still provisional

These do not block this revision and should be resolved at the indicated milestone.

| Decision | Default or method | Resolve by |
|---|---|---|
| Scenario date and first locality | First prototype: Batanes, Philippines; fictional incident dated 2026-09-14. Wider campaign remains open | M0 selected |
| Character/title names and exact case story | Working concepts only; review for clarity and provenance | M0-M2 |
| Godot version, GDScript/C# and renderer | Godot 4.7.2 standard / GDScript / GL Compatibility for Game 1; revisit only for an observed blocker | M1 selected |
| Map source and presentation | Authored offline schematic in the prototype; detailed basemap/assets still require suitable redistribution rights | M1 prototype selected |
| Minimum hardware and performance thresholds | Measure a representative scene; do not use the owner's laptop as the minimum | M1-M3 |
| Final assessment/confidence rubric | Evidence-backed structured conclusions; test confidence behavior before commitment | M2 |
| Release date | Forecast after measured content/integration throughput | M3 |
| Game 2 duration and strategy-game role | Define after the relevant prototype, not by extrapolating Game 1 | M6-M7 |

**Next action:** Play the first investigation without reading its author-only rubric. Record elapsed time, unclear wording, missing guidance and whether the assessment feels earned. Revise that slice before authoring the next case. Paid usage, publishing and expansion to later games remain separate decisions.
