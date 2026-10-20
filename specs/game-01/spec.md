# Feature Specification: Regional Analysis Desk

**Created:** 2026-10-20
**Status:** Prototype baseline; owner playtest pending
**Governing decisions:** [Master Plan](../../MASTER_PLAN.md)
**Input:** A personal, offline Windows portfolio game using real regional geography, fictional scenario actors and accessible evidence-based investigation.

## Scope Baseline

- **Discovery method:** Review of the three source conversations, confirmed user answers and master-plan v2.
- **Total items discovered:** Three portfolio titles.
- **Items in scope:** One concept and the first investigation of Game 1. The cable-ship and regional-strategy games remain later projects.
- **Full-game target:** Approximately two hours across three linked investigations, including tutorial and debriefs.
- **This prototype:** One small complete investigation, six text evidence records, an offline location schematic, synchronized timeline, notebook, assessment, hints and save/reload.
- **Player fantasy:** Explain what happened without claiming more than the evidence supports.
- **Working title:** Regional Analysis Desk. Case 1: *The Missing Interval*.
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

## Requirements

### Functional Requirements

- **REQ-001:** The case MUST label all vessel activity, organizations and records as synthetic, while identifying Basco/Batan and Itbayat as real places.
- **REQ-002:** The player MUST be able to open all six evidence records in any order without external services.
- **REQ-003:** Selecting an observation on the location view or timeline MUST open the associated evidence and identify the selected observation.
- **REQ-004:** The player MUST be able to pan, zoom and reset the location view; it MUST be labeled a schematic, not a navigational chart.
- **REQ-005:** The player MUST be able to pin/unpin read evidence and keep free-form notes.
- **REQ-006:** The assessment MUST collect a conclusion and individual citations for each of three findings.
- **REQ-007:** Feedback MUST distinguish incomplete submission, unsupported conclusion and correct conclusion lacking support.
- **REQ-008:** A complete supported submission MUST explain the supported stop, receiver outage and absence of proof of hostile intent without asserting that all other conduct is disproven.
- **REQ-009:** The player MUST be able to revise and resubmit; changing the supporting state MUST invalidate displayed assessment results.
- **REQ-010:** Optional staged hints MUST persist and MUST NOT impose a timer or penalty.
- **REQ-011:** Saving and restarting MUST preserve the case version, notes, read/pinned sources, findings, citations, confidence selection and hint position.
- **REQ-012:** Save failures and incompatible/corrupt data MUST produce explicit messages; unreadable saves MUST NOT be silently replaced.
- **REQ-013:** Reset MUST require confirmation and MUST preserve existing progress if persistence fails.
- **REQ-014:** The delivered prototype MUST run offline on Windows without the editor or an account.

### Non-Functional Requirements

- **REQ-015:** At 1280 x 900, the briefing, six-source list, evidence reader, notebook and three assessment findings MUST be reachable without clipped interactive controls.
- **REQ-016:** Findings, source labels and feedback MUST not rely on color alone; normal form controls MUST support keyboard focus.
- **REQ-017:** The prototype MUST contain no paid assets, mandatory network calls or runtime AI dependency.
- **REQ-018:** Invalid case structure or dangling evidence references MUST stop case startup with a visible diagnostic rather than start a partially valid case.

### Key Entities

- **Case:** Versioned question, region, reference date, evidence and expected reasoning.
- **Evidence record:** Stable ID, source description, UTC timestamp, synthetic status and body.
- **Observation:** Timestamp, optional coordinates and reference to its evidence record.
- **Finding:** Question, candidate conclusions, citation requirements and explanatory feedback.
- **Notebook:** Read/pinned records and player notes.
- **Session:** Case/version-bound selections, citations, notes, hints and transient debrief.

## Success Criteria

### Measurable Outcomes

- **SC-001:** One offline packaged walkthrough reaches a supported debrief for all three findings.
- **SC-002:** All six sources can be opened in forward and reverse order without blocking completion.
- **SC-003:** Correct submissions with missing support, wrong conclusions and incomplete submissions yield distinguishable feedback.
- **SC-004:** A save/restart round trip preserves every state field listed in REQ-011.
- **SC-005:** Corrupt, incompatible and unwritable save examples each produce an explicit diagnostic without replacing prior progress.
- **SC-006:** At the target resolution, an owner walkthrough can reach every required control and read each source.
- **SC-007:** Record actual first-play duration and confusion points. A 15-25 minute expanded first-case target remains unverified; the initial six-record prototype is not claimed to meet it.

## Assumptions

- First case locality: Batanes, Philippines. This is a bounded starting point within the agreed broader region.
- Scenario date: 2026-09-14, entirely fictional; no relationship to an actual incident on that date is asserted.
- Confidence is recorded for reflection, not numerically scored in this prototype.
- No independent testers are guaranteed. Automated and owner tests must be labeled separately.
- Hardware/performance minimums and final art/audio treatment are deferred.

