# Case 03 - The Echoed Warning

**Created:** 2026-10-20
**Status:** Design approved and implemented; three-case native, rendered and packaged checks passed. Owner playtest pending.
**Governing decisions:** [Master Plan](../../MASTER_PLAN.md) and [Game 1 specification](./spec.md).
**Audience:** Author-only design and answer rubric. Contains spoilers.
**Input:** Design a bounded third investigation with a different reasoning challenge, retaining the source clarity, staged hints and actionable feedback validated in the owner replay of Case 2.

## Scope Baseline

- **Discovery method:** Review of the master plan, existing case designs, Game 1 requirements, owner playtest feedback and existing content-validation constraints.
- **Total items discovered:** Three candidate reasoning tasks: trace a reporting chain, interpret a correction and compare an independently kept record.
- **Items in scope:** All three tasks in one investigation: six immediately available text records, three findings, four optional hints and a debrief.
- **Player fantasy:** Replace a widely repeated but overbroad warning with a useful, appropriately bounded account.
- **Real setting:** Itbayat in Batanes, Philippines; Basco/Batan remains regional context on the existing map.
- **Scenario date:** 2026-09-16, the day after Case 2. Proposed stable case ID: `echoed-warning`, version 1.
- **Fiction boundary:** Every report, organization, work arrangement, delivery and timestamp is invented. Loading areas A and B are temporary labels within the fictional work arrangement, not asserted real pier names, charted facilities or new geographic places.
- **Time convention:** Every displayed time is UTC on the scenario date. Observation and publication/filing times are explicitly labeled. No clock conversion, hidden time zone or midnight calculation.
- **Exclusions:** New imagery, audio, 3D, external player research, live services, paid assets, a source-graph editor, drag-and-drop linkage, free-text grading or a navigation task. The separately approved map upgrade is not part of this case's evidence.
- **Length policy:** Keep records focused. Do not pad the case or set a minimum playtime to manufacture a two-hour campaign.

### Player brief

> Three messages describe a complete halt to supply landings at Itbayat. Your desk must issue an accurate summary as of 09:00 UTC. Trace where those messages got their information, compare the original account with its correction, and check a separately kept handling record. Choose and support three findings. Do not assume that more publications mean more independent witnesses, or that a correction means nothing happened.
>
> Start with 01 / Desk review request. All records are available now; investigate them in any order. Pin useful records, then tick their boxes separately under each finding. Submission is not completion: use the result to correct answers or missing citations and resubmit until all three findings are SUPPORTED.

This teaches the task, not the accepted source count or operational conclusion. It must not describe the outcome as sabotage, name a real operator or instruct the player to authorize a real voyage.

## User Scenarios & Testing

### User Story 1 - Trace independent reporting (Priority: P1)

As an analyst, I follow source references rather than count publishers as separate witnesses.

**Why this priority:** Repeated publication can create false confidence without new observation.

**Independent test:** Compare records 02-04 and assess their common reporting origin.

**Acceptance scenarios:**

1. **Given** a field note, a bulletin citing it and a digest citing that bulletin, **when** I trace the closure headline through all three records, **then** I can distinguish one originating report from three publications.
2. **Given** a selected origin count without one of those records cited, **when** I submit, **then** the missing part of the chain is identified rather than accepted as supported.

### User Story 2 - Read the correction precisely (Priority: P1)

As an analyst, I identify what a correction changes without treating it as proof that there was no disruption.

**Why this priority:** The correction narrows an overstatement; it does not erase the original limited observation.

**Independent test:** Compare the original headline and field observation with the correction that explicitly names that report.

**Acceptance scenarios:**

1. **Given** the original and its correction, **when** I compare their scope, **then** I distinguish an all-landings claim from a restriction limited to one loading area.
2. **Given** that a barrier remains in place at B, **when** I select either total closure or no restriction anywhere, **then** the debrief explains the specific overstatement.

### User Story 3 - Use bounded corroboration (Priority: P1)

As an analyst, I check whether a separately recorded event supports the corrected account, without extrapolating through the rest of the day.

**Why this priority:** The case must support a positive conclusion, not reward blanket distrust or perpetual indecision.

**Independent test:** Compare the correction with the independently maintained handling ledger, then complete and resume the assessment.

**Acceptance scenarios:**

1. **Given** a correction and a ledger based on its own handling entry, **when** I compare them, **then** I recognize independent, limited corroboration rather than another repost.
2. **Given** one recorded unloading at A, **when** I claim that every landing was unrestricted for the rest of the day, **then** feedback explains the unsupported extension.
3. **Given** a wrong conclusion and a missing citation, **when** I submit and then correct only the answer, **then** feedback changes from REVISE to NEEDS SUPPORT; adding the citation and resubmitting produces SUPPORTED.
4. **Given** saved work in all available cases, **when** I switch, restart or reset Case 3, **then** the other cases retain their progress.

### Edge Cases

- The player opens the correction first or discovers all six records in reverse order.
- Different publisher names or publication times are mistaken for independent observations.
- The correction is counted as a second origin within the explicitly scoped question about records 02-04.
- The player assumes a later record is automatically true; corroboration must rest on its provenance and contents, not age alone.
- A correct conclusion cites only the correction where the question requires an original-versus-corrected comparison.
- A player cites all three repeated publications as substitutes for the independent ledger.
- The player selects "nothing happened" merely because an overbroad warning was corrected.
- The map has no vessel observations; no ship track or exact work-area location should be fabricated to fill it.
- A required citation is unpinned after submission, or a saved result is reopened after restart.

## Requirements

### Functional Requirements

These extend REQ-001 through REQ-031 in the parent specification. They were approved before implementation and now describe the third case in the playable build.

- **REQ-032:** Case 3 MUST provide the six fictional records defined below, available in any order, with a non-spoiling review request and three distinct reporting-chain, correction-scope and corroboration findings.
- **REQ-033:** The first finding MUST explicitly scope its origin count to records 02-04. Their attribution chain MUST be traceable, and three publications MUST NOT be graded as three independent reports.
- **REQ-034:** The correction MUST identify the original report, withdraw its all-landings headline, retain the limited restriction and distinguish that correction from a claim that no disruption occurred.
- **REQ-035:** The handling ledger MUST identify its own record of an actual unloading, independently of the circulated warning. Its accepted interpretation MUST corroborate the corrected account only within the event and time it records.
- **REQ-036:** Every time MUST be explicitly UTC. Source headers and timeline entries MUST distinguish observation/event time from publication/filing time without requiring conversion.
- **REQ-037:** The map MUST remain geographic context only for this case: reuse the sourced regional geography, do not invent vessel positions or routes, and do not present temporary scenario work-area labels as real mapped facilities.
- **REQ-038:** Four optional hints MUST separately guide tracing attribution, comparing corrected scope, checking independent corroboration and applying citations/resubmission. They MUST preserve progress and retain the existing no-penalty behavior.
- **REQ-039:** Case 3 MUST be directly selectable and independently resumable, preserve both existing save identities and recovery protections, and be offered after supported Case 2 completion. Its end message MUST state that it is the last included case without claiming that the portfolio or two-hour target is complete.
- **REQ-040:** Assessment MUST require every source in each defined support set, including the three-source chain for finding 1. Extra or repeated-source citations MUST NOT replace missing required records. Missing answers, wrong answers, missing support and three supported findings MUST retain distinct, actionable feedback.

### Key Entities

- **Originating report:** A claim and its limited observation, identified by report ID M17.
- **Derived publication:** A record that attributes its information to a prior report or publication, without gathering a new observation.
- **Correction:** A specifically linked replacement of the original headline's scope, not an unrelated newer message.
- **Independent event record:** A separately maintained handling entry with its own event ID, observation and filing time.
- **Finding:** A bounded question, candidate interpretations and required citations.
- **Session:** Case-specific read/pinned records, notes, answers, citations, hints, confidence and submitted state; existing persistence behavior is inherited.

## Success Criteria

### Measurable Outcomes

- **SC-015:** Each of the three findings has exactly one accepted option among three candidates. All six alternative conclusions are rejected. For otherwise accepted answers, omission of any of the seven required citation memberships yields missing-support feedback.
- **SC-016:** Both forward and reverse discovery order permit three supported findings. A wrong answer plus missing citation can be corrected through REVISE, NEEDS SUPPORT and SUPPORTED without resetting or losing another case's progress.
- **SC-017:** An owner walkthrough can explain the shared reporting origin, the correction's limited scope and what the independent event corroborates. Record elapsed time, hints, final supported count and any confusion separately; do not impose a minimum duration or treat author familiarity as novice evidence.
- **SC-018:** At the established target window size, all six records, complete source text, four hints, three findings, citation controls and the result/correction loop are reachable. The packaged offline build preserves existing case progress and does not display invented map observations.

## Author-only Truth and Uncertainty

- At 07:55 UTC, the fictional Landing Watch observer saw a barrier at loading area B but could not see A. The observation was limited; the 08:00 headline generalized it incorrectly to all landings.
- Route Service copied that headline from M17. Community Digest copied Route Service's bulletin. Neither gathered a new observation.
- At 08:40, the same observer issued M17-C, explicitly withdrawing the all-landings headline. B remained restricted for a routine inspection; A was available for scheduled unloading.
- An independently maintained handling ledger records one completed unloading at A at 08:45, with B still cordoned. It was filed at 08:55.
- The ledger provides independent support for the corrected, limited account. The correction is not independent of its own original report.
- No evidence establishes who first ordered the barrier, every operation that day, uninterrupted future access, navigational safety or anyone's hidden intent.
- This is an invented work arrangement serving real Itbayat, not a historical closure, a real port notice or navigational advice.

## Evidence Graph and Draft Record Contents

The following contents fix the decisive facts for implementation. Final formatting may change, but provenance, scope and limitations must not.

| ID | Number / title | Header time, UTC | Reporting role |
|---|---|---|---|
| assignment | 01 / Desk review request | Request issued: 09:00 | Defines the 09:00 summary and three questions, without giving answers |
| original | 02 / Morning field note | Report issued: 08:00 | M17; limited observation plus an overbroad preliminary headline |
| bulletin | 03 / Route service bulletin | Bulletin published: 08:10 | RB4 repeats M17; no new observation |
| digest | 04 / Community digest | Digest published: 08:25 | CD9 repeats RB4; no new observation |
| correction | 05 / Field note correction | Correction issued: 08:40 | M17-C explicitly corrects M17's scope |
| ledger | 06 / Handling ledger extract | Ledger filed: 08:55 | Own entry DH21 records an 08:45 unloading, not a repost |

### 01 / Desk review request

Use the player brief above. Explicitly state that records 02-04 are the publications to trace for finding 1; records outside that set inform the other questions. Review as of 09:00 UTC on 16 September 2026. All records, groups and activity are synthetic. This is a desk assessment, not permission to sail or unload.

### 02 / Morning field note

> FICTIONAL LANDING WATCH / report M17 / issued 08:00 UTC
>
> PRELIMINARY HEADLINE: All supply landings at Itbayat suspended.
>
> OBSERVATION, 07:55 UTC: From the approach to loading area B, I saw a barrier and an inspection notice across B's access. I could not see loading area A from that position.
>
> The headline is my preliminary interpretation. I have not checked A or a handling ledger. A follow-up check is pending.

### 03 / Route service bulletin

> FICTIONAL ROUTE SERVICE / bulletin RB4 / published 08:10 UTC
>
> All supply landings at Itbayat suspended.
>
> Source: Landing Watch report M17, issued 08:00 UTC. This bulletin relays that report. We have not sent an observer or made a separate check.

### 04 / Community digest

> FICTIONAL COMMUNITY DIGEST / item CD9 / published 08:25 UTC
>
> Supply landings at Itbayat suspended, according to Route Service bulletin RB4.
>
> Source for this item: RB4, published 08:10 UTC. This is a summary of that bulletin; no additional observation or handling record was obtained.

### 05 / Field note correction

> FICTIONAL LANDING WATCH / correction M17-C / issued 08:40 UTC
>
> CORRECTS M17, issued 08:00 UTC. Withdraw the headline "All supply landings at Itbayat suspended."
>
> After checking both areas, the restriction is limited to loading area B for a routine inspection. B remains cordoned. A is available for scheduled unloading as of this check. The barrier observation at B stands; the all-landings interpretation does not.
>
> This corrects my earlier report; it is not a second independent witness. It does not guarantee access later in the day or certify navigation conditions.

### 06 / Handling ledger extract

> FICTIONAL DELIVERY COOPERATIVE / ledger filed 08:55 UTC
>
> OWN HANDLING ENTRY DH21 / event time 08:45 UTC: One scheduled supply unloading was completed at loading area A. Loading area B was not used; its inspection barrier remained in place.
>
> Compiled from the cooperative's own unloading entry DH21, not from M17, RB4 or CD9. This entry records that operation only; it does not certify other deliveries, later access or the condition of every landing facility.

### Lineage and timeline

Reporting chain: `original (M17) -> bulletin (RB4) -> digest (CD9)`.
Correction relationship: `correction (M17-C) -> explicitly revises original (M17)`.
Independent record: `ledger (DH21)`, based on its own handling entry, not the chain above.

Eight timeline entries, all UTC:

| Time | Event label | Source |
|---|---|---|
| 07:55 | Barrier at B observed / A not checked | original |
| 08:00 | Preliminary field note issued | original |
| 08:10 | Route bulletin published | bulletin |
| 08:25 | Community digest published | digest |
| 08:40 | Field note correction issued | correction |
| 08:45 | Unloading at A recorded | ledger |
| 08:55 | Handling ledger filed | ledger |
| 09:00 | Desk review requested | assignment |

These are source-backed events, not vessel fixes. No timeline entry has a ship coordinate or observation marker. Keep the existing real-place map as context; explain that this case contains no mapped vessel observations. Timeline labels expose record events, not an answer summary or an implied sailing route.

## Assessment Rubric

Each finding has an unselected state plus the following three candidates. Vary accepted-option placement during implementation; do not make option position a clue.

| Finding ID / question | Accepted option ID and meaning | Required citations | Rejected options |
|---|---|---|---|
| origins / How many original reporting accounts lie behind the closure headline in records 02-04? | one_origin: one originating report, repeated through two other publications | original + bulletin + digest | three_origins: each publisher is an independent account; two_origins: the digest supplies a new account |
| corrected_scope / What does record 05 change in record 02's account? | limited_restriction: withdraws all-landings suspension; B remains restricted while A is available for scheduled unloading | original + correction | all_closed: retains total suspension; no_restriction: withdraws every restriction and the barrier observation |
| corroboration / How does record 06 relate to the corrected account in record 05? | bounded_corroboration: its own recorded unloading independently supports the limited account at that time | correction + ledger | copied_confirmation: it only repeats the bulletin chain; unrestricted_day: it proves every landing remained unrestricted for the rest of the day |

Support requirements are tied to the question, not arbitrary source collecting:

- Finding 1 needs the original and both attribution links to establish the complete chain.
- Finding 2 asks what changed, requiring the original and its explicit correction.
- Finding 3 asks whether another record corroborates that correction, requiring both the corrected claim and the independent entry.

All six records matter; there is no filler dossier or hidden external fact. Extra citations are permitted, but cannot replace missing chain links or the independent ledger.

### Four staged hints

1. **Finding 1 / trace the source:** In records 02-04, distinguish each document's own ID from the report it cites. Follow the digest's attribution backward to the bulletin, then follow that bulletin's attribution. A new publication is not automatically a new observation.
2. **Finding 2 / compare the scope:** Read what 02 actually observed and compare it with 05's explicit correction. Identify which headline is withdrawn and which restriction remains. "The broad claim was wrong" does not mean "nothing happened."
3. **Finding 3 / check independent support:** Compare 05 with 06. Identify where the ledger's entry came from, what operation it actually records and what period it does not cover. Do not accept or reject it merely because it was filed later.
4. **Apply support and resubmit:** Pin and cite 02/03/04 under finding 1, 02/05 under finding 2, and 05/06 under finding 3. Pinning alone does not cite. Review every REVISE or NEEDS SUPPORT result, make the indicated change and submit again.

### Debrief payoff

The desk replaces an apparent three-source shutdown warning with a precise correction supported by a separately recorded event. Explain the chain, identify the limited disruption that was real within the fiction, and distinguish useful corroboration from certainty about everything that followed. Do not infer malicious intent from an erroneous headline or give a universal "all clear."

## Implementation Boundaries and Testing Strategy

This contract was written before implementation. [Recorded three-case results](../../games/regional-desk/README.md#three-case-checkpoint---20-october-2026) distinguish technical verification from the still-pending owner playtest.

- **Existing foundation:** Reuse the current read/pin/cite/submit flow, per-finding support sets, ordered hints, content validation, shared offline geography and local persistence. No new comparison widget or graph subsystem is required.
- **Save compatibility:** Retain both existing case IDs, versions and save paths. Proposed third save slot: `session-case-03.json`. Switching, unreadable-save protection and reset isolation must cover all three slots; never migrate or overwrite another case to introduce this one.
- **Relevant UI surfaces:** Add the case to selection, its own help/brief, Case 2 continuation and final-case messaging. Replace case-inapplicable tracking-gap wording with context-only map guidance for Case 3. Keep first-case startup behavior unless separately changed.
- **Validation stack:** Existing native Godot runner. Browser, HTTP, accounts, database, containers and network services are not applicable. No dependency installation is planned.
- **Baseline:** Preserve the latest 224 canonical checks and existing rendered/packaged journeys, updating only assertions for deliberately changed available-case messages. Do not present those prior counts as Case 3 coverage.
- **Content/rubric checks:** Six valid records, eight sorted source-linked timeline events, explicit UTC/header meanings, no coordinates, unique IDs, all three accepted conclusions, all six rejected alternatives, all seven individual required-citation omissions and substituted repeated-source support. Test first-finding support with each possible missing chain link, not only an empty citation list.
- **Native scene/file journeys:** Finish Case 2 and continue to Case 3; also select it directly. Complete in forward and reverse discovery order. Exercise wrong answer plus missing citation, answer-only correction, then pin/cite/resubmit. Reveal all four hints, save, switch through all cases, restart and compare each case's progress and recomputed results.
- **Failure/reset coverage:** Corrupt only the third save and retain both originals; confirm failed-switch cancel/leave behavior. Reset each slot in turn and compare the other two files immediately before and after the reset. Isolate test files from normal player saves and clean up only named test paths.
- **Rendered/package checks:** At 1280 x 900, inspect the six-record list, source headers, longest body, all citation controls, notes/footer, all hints and both incomplete/complete results. Export and exercise the extracted resource pack with the existing standard-engine driver; separately launch the actual release and verify responsive startup, autosave and normal exit. Every final validation command must exit 0 without failed checks or unexpected engine errors.
- **Owner gate:** On unfamiliar content, record time spent, hint use, final supported-finding count, confusion and whether the inference required thought. Confirm the player can explain the three distinctions. Technical checks cannot establish enjoyment, novice usability or a two-hour campaign.

## Assumptions and Approval Boundary

- Six records and three findings are a scope ceiling for this first Case 3 version, not a request to add filler if play is short.
- A shared date sequence and region provide continuity; Case 3 does not require recalling the prior cases' accepted answers.
- Real geography remains unchanged. Synthetic loading-area labels describe an authored work arrangement only; no new map asset or historical claim is introduced.
- No timer, punitive confidence scoring, hidden evidence unlock or runtime model is added.
- The owner explicitly approved implementation of this case and three-case progression after reviewing the design. This does not authorize production of another game or paid services.
- The design-only checkpoint did not change runtime files. Implementation subsequently added the third JSON, catalogue entry, dynamic progression and case-aware guidance, retaining both earlier case fixtures and save identities. The Windows build now contains all three cases.
