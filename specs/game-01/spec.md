# Feature Specification: Regional Analysis Desk

**Created:** 2026-10-20
**Status:** Two-case implementation and Case 2 clarity revision technically verified; revised owner completion and fresh-player timing pending
**Governing decisions:** [Master Plan](../../MASTER_PLAN.md)
**Input:** A personal, offline Windows portfolio game using real regional geography, fictional scenario actors and accessible evidence-based investigation.

## Scope Baseline

- **Discovery method:** Review of the three source conversations, confirmed user answers and master-plan v2.
- **Total items discovered:** Three portfolio titles.
- **Items in scope:** Game 1's introductory investigation and approved second investigation, with case selection and separate progress. The cable-ship and regional-strategy games remain later projects.
- **Full-game target:** Approximately two hours across three linked investigations, including tutorial and debriefs.
- **This prototype:** Two investigations (six and seven text records), an offline coastline map, synchronized timeline, notebook, assessment, hints, case selection and independent save/reload.
- **Player fantasy:** Explain what happened without claiming more than the evidence supports.
- **Working title:** Regional Analysis Desk. Case 1: *The Missing Interval*; Case 2: *The Borrowed Name*.
- **Tone:** Calm, credible and curious. Tension comes from competing explanations, not combat or a countdown.
- **Exclusions:** Real feeds, external research, combat, account creation, procedural world simulation, live models, commercial release and 3D in Game 1.

## User Scenarios & Testing

### User Story 1 - Resolve a conflicting account (Priority: P1)

As a non-specialist analyst, I compare records and observations to explain a vessel's missing public positions.

**Why this priority:** This cross-referencing loop is the game, not a dashboard feature.

**Independent test:** Open the case, inspect the six records in any order, link evidence to conclusions and obtain an explanatory debrief.

**Acceptance scenarios:**

1. **Given** a new case, **when** I open it, **then** I see the question, fiction disclaimer, controls and time convention.
2. **Given** a timeline event or map observation, **when** I select it, **then** its supporting document opens and the selected event is identified.
3. **Given** the delivery and lookout records, **when** I submit Itbayat as the best-supported stop and cite both, **then** that finding is accepted.
4. **Given** only a missing tracking interval, **when** I claim deliberate shutdown, **then** the debrief explains why the evidence does not establish that conclusion.
5. **Given** a correct conclusion with inadequate citations, **when** I submit, **then** feedback distinguishes missing support from an incorrect answer.

### User Story 2 - Build an evidence-backed assessment (Priority: P1)

As a player, I pin sources to a notebook and choose citations separately for each finding.

**Why this priority:** A correct guess should not be mistaken for supported reasoning.

**Independent test:** Pin a source, cite it under a finding, unpin it and verify the obsolete citation disappears.

**Acceptance scenarios:**

1. **Given** an open document, **when** I pin it, **then** it appears in my notebook and becomes available for citation.
2. **Given** three completed findings, **when** I submit, **then** each receives separate conclusion/support feedback.
3. **Given** feedback, **when** I revise a selection, citation or note, **then** the old debrief is marked out of date or cleared.
4. **Given** a completed assessment, **when** I review it, **then** the explanation distinguishes observed activity from unproven intent.

### User Story 3 - Resume and learn without pressure (Priority: P2)

As a new player, I use optional hints and return later without losing notes or progress.

**Why this priority:** The audience is unfamiliar with professional OSINT tools.

**Independent test:** Save notes, selections, citations and hint progress, restart and compare.

**Acceptance scenarios:**

1. **Given** an unfinished case, **when** I save and restart, **then** notes, read/pinned evidence, selections, citations and hints are restored.
2. **Given** corrupt or incompatible saved data, **when** I open the game, **then** an explicit error appears and the original file is not overwritten automatically.
3. **Given** uncertainty, **when** I request a hint, **then** I receive staged guidance without a timer or score penalty.
4. **Given** an existing case, **when** I request reset, **then** confirmation is required before progress is replaced.

### Edge Cases

- A document is opened repeatedly or evidence is investigated in reverse order.
- Sources disagree with one another; disagreement is not automatically a content error.
- The right answer is selected with the wrong evidence or no evidence.
- A pinned source is removed after it has been cited.
- Notes contain punctuation or non-ASCII text.
- A save is interrupted, corrupt, incompatible, or inaccessible.
- A player tries to submit an incomplete form.
- Timeline and document order differ; all displayed times remain explicitly UTC.
- A previous build's save has no submitted-assessment flag; notes and selections must still load.
- A player scrolls past the debrief or reloads after completing the investigation.
- Coastlines and observations must share the same transform when panned or zoomed.

### User Story 4 - Understand the assignment (Priority: P1)

As a first-time player, I understand my analyst role, why an allegation needs scrutiny, my first action and the deliverable before investigating.

**Independent test:** Start a new case, read the mission guide, dismiss it and reopen it without changing progress.

**Acceptance scenarios:**

1. **Given** a new session, **when** it opens, **then** a briefing explains my role, the allegation, the three-finding deliverable and the non-accusatory aim.
2. **Given** the desk, **when** I open Help, **then** I see a non-spoiling read/pin/choose/cite/submit walkthrough and feedback-status definitions.

### User Story 5 - Recognize progress and completion (Priority: P1)

As a player, I can distinguish an assessment that needs revision from a completed investigation without searching through a scrolling panel.

**Independent test:** Submit incomplete, partially supported and fully supported assessments, then revise and reload.

**Acceptance scenarios:**

1. **Given** a submission, **when** it is assessed, **then** a visible result dialog and non-scrolling progress indicator state how many of the three findings are supported.
2. **Given** three supported findings, **when** I submit, **then** I see "Investigation complete" with the debrief and a clear statement that this case is finished.
3. **Given** a submitted assessment, **when** I restart, **then** its progress is recomputed from saved findings; changing the assessment clears the current result until resubmission.

### User Story 6 - Orient geographically (Priority: P2)

As a player unfamiliar with Batanes, I recognize islands, places, observations, orientation and approximate distances.

**Independent test:** Inspect the default map, select observations, then pan/zoom/reset while coastlines remain aligned.

**Acceptance scenarios:**

1. **Given** the offline map, **when** I open it, **then** I see real generalized coastlines, named islands, distinct place/observation symbols, a legend, north indicator and distance scale.
2. **Given** a zoomed map, **when** I change zoom, **then** the scale remains geographically consistent and no observed route is invented through the tracking gap.

### User Story 7 - Investigate a mistaken identity (Priority: P1)

As an analyst, I compare vessel features, clock conventions and independent observations rather than trusting a shared name or a reposted timestamp.

**Independent test:** Complete The Borrowed Name using its seven records in any order.

**Acceptance scenarios:**

1. **Given** two similar vessel names, **when** I compare the register and image transcript, **then** I can identify the best structural match without outside knowledge.
2. **Given** a local camera timestamp and its setting card, **when** I distinguish capture from archive indexing, **then** I can report the capture time in UTC.
3. **Given** two independent position records, **when** I assess the reconstruction, **then** I do not merge distinct vessel IDs into one observed route.

### User Story 8 - Continue and resume separate cases (Priority: P1)

As a player, I can choose either investigation, continue from the introduction and resume each without losing the other's work.

**Independent test:** Edit and complete different cases, switch/restart, then reset only one.

**Acceptance scenarios:**

1. **Given** work in Case 1, **when** I select Case 2 and return, **then** Case 1's notes, answers and submitted result remain intact.
2. **Given** a completed Case 1, **when** I continue, **then** Case 2 opens with its own briefing and progress.
3. **Given** a failed save, **when** I attempt to switch, **then** I can stay without losing work or explicitly confirm leaving without saving.
4. **Given** a corrupt Case 2 save, **when** I select Case 1 or reset Case 2, **then** the original is preserved and Case 1 remains unaffected.

## Requirements

### Functional Requirements

- **REQ-001:** The case MUST label all vessel activity, organizations and records as synthetic, while identifying Basco/Batan and Itbayat as real places.
- **REQ-002:** The player MUST be able to open all evidence in the selected case (six records in Case 1, seven in Case 2) in any order without external services.
- **REQ-003:** Selecting an observation on the location view or timeline MUST open the associated evidence and identify the selected observation.
- **REQ-004:** The player MUST be able to pan, zoom and reset the location view; its generalized geography MUST be labeled as unsuitable for navigation.
- **REQ-005:** The player MUST be able to pin/unpin read evidence and keep free-form notes.
- **REQ-006:** The assessment MUST collect a conclusion and individual citations for each of three findings.
- **REQ-007:** Feedback MUST distinguish incomplete submission, unsupported conclusion and correct conclusion lacking support, identify missing citations even when an answer also needs revision, and explain returning, pinning/citing and resubmitting.
- **REQ-008:** A complete supported Case 1 submission MUST explain the supported stop, receiver outage and absence of proof of hostile intent without asserting that all other conduct is disproven.
- **REQ-009:** The player MUST be able to revise and resubmit; changing the supporting state MUST invalidate displayed assessment results.
- **REQ-010:** Optional staged hints MUST persist and MUST NOT impose a timer or penalty.
- **REQ-011:** Saving and restarting MUST preserve the case version, notes, read/pinned sources, findings, citations, confidence selection and hint position.
- **REQ-012:** Save failures and incompatible/corrupt data MUST produce explicit messages; unreadable saves MUST NOT be silently replaced.
- **REQ-013:** Reset MUST require confirmation and MUST preserve existing progress if persistence fails.
- **REQ-014:** The delivered prototype MUST run offline on Windows without the editor or an account.

### Non-Functional Requirements

- **REQ-015:** At 1280 x 900, the case selector, briefing, six/seven-source list, evidence reader, notebook and three assessment findings MUST be reachable without clipped interactive controls.
- **REQ-016:** Findings, source labels and feedback MUST not rely on color alone; normal form controls MUST support keyboard focus.
- **REQ-017:** The prototype MUST contain no paid assets, mandatory network calls or runtime AI dependency.
- **REQ-018:** Invalid case structure or dangling evidence references MUST stop case startup with a visible diagnostic rather than start a partially valid case.

### Onboarding and Geographic Context

- **REQ-019:** New sessions MUST show a mission briefing identifying the player role, stakes, first action and three-finding deliverable without revealing accepted answers.
- **REQ-020:** A persistent Help control MUST reopen the briefing, step-by-step controls and four assessment-status explanations without changing saved progress.
- **REQ-021:** Every submission MUST show the supported-finding count outside the scrolling form and open a result dialog; all three supported findings MUST explicitly show "Investigation complete."
- **REQ-022:** Submitted progress MUST survive restart and be recomputed from the saved assessment; edits MUST invalidate the displayed result. Older saves without submission metadata MUST retain their existing progress.
- **REQ-023:** The offline map MUST show sourced real coastlines, Batan/Itbayat/Sabtang island labels, a north indicator, a legend and a kilometer scale that updates with zoom. Places and public fixes/shore observations MUST be distinguishable without color alone.
- **REQ-024:** Map data MUST be redistributable, credited with its source and limitations, bundled for offline play and share the observation projection. Missing or invalid geography MUST produce an explicit startup diagnostic.

### Two-Case Build

- **REQ-025:** Case 2 MUST provide seven immediately available fictional records supporting three distinct identity, timestamp and geographic-corroboration findings; no outside research or real photograph is required.
- **REQ-026:** The timeline and source headers MUST distinguish UTC record/index times from unconverted camera-overlay time and MUST NOT reveal the accepted conversion as an observed map timestamp. Source text and staged hints MUST identify which event is being converted and where the camera clock convention is established.
- **REQ-027:** A visible case selector MUST open either investigation and identify each case's progress or save problem without relying on color.
- **REQ-028:** Each case MUST preserve its own notes, read/pinned records, findings, citations, confidence, hints and submitted state; existing Case 1 version-1 saves MUST retain their original location and compatibility.
- **REQ-029:** Switching MUST first save current progress; on failure or a locked save, departure MUST require explicit confirmation, with a cancel path preserving the current case.
- **REQ-030:** Reset/recovery MUST affect only the selected case. A corrupt save MUST NOT prevent access to the other investigation or silently replace the original.
- **REQ-031:** Supported completion of Case 1 MUST offer continuation to Case 2; the last available case MUST clearly state that no third case is included, without claiming full campaign completion.

### Key Entities

- **Case:** Versioned question, region, reference date, evidence and expected reasoning.
- **Evidence record:** Stable ID, source description, UTC record/index timestamp, synthetic status and body. An embedded camera overlay can use a different clock convention.
- **Observation:** Timestamp, optional coordinates and reference to its evidence record.
- **Finding:** Question, candidate conclusions, citation requirements and explanatory feedback.
- **Notebook:** Read/pinned records and player notes.
- **Session:** Case/version-bound selections, citations, notes, hints and transient debrief.

## Success Criteria

### Measurable Outcomes

- **SC-001:** Each offline packaged investigation reaches a supported debrief for all three findings.
- **SC-002:** Each case's sources can be opened in forward and reverse order without blocking completion.
- **SC-003:** Correct submissions with missing support, wrong conclusions and incomplete submissions yield distinguishable feedback.
- **SC-004:** A save/restart round trip preserves every state field listed in REQ-011.
- **SC-005:** Corrupt, incompatible and unwritable save examples each produce an explicit diagnostic without replacing prior progress.
- **SC-006:** At the target resolution, an owner walkthrough can reach every required control and read each source.
- **SC-007:** Record actual first-play duration and confusion points. A 15-25 minute expanded first-case target remains unverified; the initial six-record prototype is not claimed to meet it.
- **SC-008:** A new player can identify their role, first action and completion condition from the opening guide; an owner playtest must confirm whether clarity improved.
- **SC-009:** Automated submissions with zero, one and three supported findings show the corresponding counts; a completed result remains accessible after restart.
- **SC-010:** Coastline, place and observation alignment survives pan/zoom/reset; the scale matches a known 10 km projected distance within 1% at the map's reference latitude.
- **SC-011:** Both cases can be completed in forward or reverse discovery order; every alternative Case 2 conclusion is rejected and every omitted decisive citation yields missing-support feedback.
- **SC-012:** Switch/restart round trips preserve two different sets of notes, citations, hints and completion states; resetting either leaves the other's saved bytes unchanged.
- **SC-013:** Failed-switch cancel/confirm and corrupt-save recovery are observable, preserve originals and leave the other case usable.
- **SC-014:** An extracted offline Windows build supports both cases, a seven-record source list, case-specific help and independent progress; target-window controls remain reachable.

### Owner Playtest Baseline - 20 October 2026

Approximately 20 minutes, hints used, assessment submitted, completion unconfirmed. The owner reported that features appeared to work, but role/stakes, first action, finish condition and feedback meaning were unclear. Coastlines, named islands, legend and scale were requested. This is one owner's observation, not independent usability or proof of completion.

### Revised Owner Playtest - 20 October 2026

The owner reports approximately five minutes to completion, no remaining confusion, and conclusions that required some thought. Hint use was not reported. This supports improved clarity and owner-reported completion, but is a repeat playthrough with prior knowledge of the case. It does not establish novice usability, first-play duration, enjoyment or the 15-25 minute expanded-investigation target. Preserve the concise introductory case rather than adding records solely to increase duration. The second investigation was subsequently approved and implemented.

### Case 2 Owner Playtest - 20 October 2026

Approximately seven minutes, all hints used, difficulty with finding 2 and a fair bit of confusion. The owner clarified that an assessment was submitted but not all findings were supported; do not label this as completed-case duration. Capture versus archive processing, the camera's time zone, step 2/hints and submission feedback were unclear. A clarity revision retains the existing rubric and save identity, separates event/clock labels, sequences hints and makes correction actions explicit. The next owner gate is understanding and reaching three supported findings, not adding more content.

## Assumptions

- First case locality: Batanes, Philippines. This is a bounded starting point within the agreed broader region.
- Scenario date: 2026-09-14, entirely fictional; no relationship to an actual incident on that date is asserted.
- Confidence is recorded for reflection, not numerically scored in this prototype.
- No independent testers are guaranteed. Automated and owner tests must be labeled separately.
- Hardware/performance minimums and final art/audio treatment are deferred.
