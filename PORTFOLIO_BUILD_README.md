# Regional Analysis Desk - Two Investigations

Two-case build / 20 October 2026.

## Run

Extract the archive, then double-click `RegionalDesk.exe`.
Windows x64, keyboard and mouse. No editor, account, network or AI service required.
This is an unsigned personal build; Windows may display an unknown-publisher warning.
Only run a build you trust. This project does not require disabling Windows security.

## Play

### Your role and objective

You are a civilian regional analyst. Test disputed public claims against the
records, rather than presuming guilt. Unsupported allegations can mislead decisions.

| Investigation | Your task | Start with |
|---|---|---|
| 1. The Missing Interval | Assess a stop, a tracking gap and the limits of an intent claim | Dispatch extract; six records |
| 2. The Borrowed Name | Compare vessel identity, camera time and independent positions | Review request; seven records |

Deliver three supported findings in each investigation. No outside research is
required; all of the selected case's records are immediately available.

### Start here

1. Read the first document already open. Then read the remaining sources
   in any order, selecting the source list, timeline or map observations.
2. **Pin source to notebook** makes a useful record available for citation.
   Pinning alone does **not** cite it.
3. Under **each finding**, choose a conclusion and tick its supporting source
   boxes. Scroll the assessment panel to reach all three findings and Submit.
4. Select **Submit assessment**. Read the result, revise as needed and resubmit.
   Notes help your reasoning but are not graded. Confidence is reflective, not scored.
5. Finish when the result says **INVESTIGATION COMPLETE** and **3 of 3 findings
   supported**. Completing Case 1 enables **Continue to Case 2**.
6. The header's **Cases** selector opens either case directly, with its own
   progress status. Case 2 finishes this build's available content, not the planned
   full campaign. There is no third investigation yet.

The opening **Mission & Help** guide explains these steps. Reopen it from the
top of the desk at any time. Returning saves are not automatically interrupted
by the guide; open it manually if upgrading from the first build.

### Understanding feedback

| Status | Meaning / next action |
|---|---|
| INCOMPLETE | Choose a conclusion for this finding. |
| REVISE | Change this finding's selected answer using the explanation; also check any listed missing citations. |
| NEEDS SUPPORT | Your answer is correct. Open the listed records, pin them if needed, then tick their boxes under this finding. |
| SUPPORTED | Both the conclusion and its required citations are accepted. |

Every submission opens a result dialog. The supported-finding count remains
visible above the scrolling assessment form. **Review latest result** reopens
the current debrief, including after restart. Editing the assessment/notebook
invalidates the displayed result until resubmission. Optional hints have no
timer or penalty.

**Submitted is not the same as complete.** Scroll through the result and fix
every finding that is not SUPPORTED. Select **Return to findings**, change the
answer and/or citations, then **Submit assessment** again. Pinning alone does
not cite a record. The previous result is not updated until you resubmit.

For Case 2's finding 2, distinguish **when the camera took the image** from
**when the archive processed it**. Record 03 separates these events; record 04
establishes the camera's clock convention. The hints walk through choosing the
event, converting its clock and supplying citations. This revision retains your
answers and notes; use **Review latest result** to resume without resetting.

### Map and controls

- Squares identify places; circles identify public position fixes; diamonds
  identify shore sightings. Labels show UTC observation times and, in Case 2,
  local vessel identifiers.
- Batan, Itbayat and Sabtang have real generalized coastlines and island names.
  The north indicator and approximate kilometer scale provide orientation.
- Drag empty map space to pan; use the wheel or +/- to zoom; **Reset view**
  restores the map. The scale changes with zoom.
- Observations do not form a continuous route. Do not merge observations of
  different vessels into a single track.
- Timeline entries use UTC. Source documents may use another clock convention;
  read the records rather than assuming an image overlay is already UTC.
- Use the timeline as a keyboard-accessible alternative to map markers.
  Tab moves among ordinary controls; Space activates buttons and checkboxes.

## Save

Progress autosaves separately for each case. A manual Save button is also
available. Default Windows locations:
```text
%APPDATA%\Godot\app_userdata\Regional Analysis Desk\session.json
%APPDATA%\Godot\app_userdata\Regional Analysis Desk\session-case-02.json
```
The first path is unchanged from earlier builds. Restart opens Case 1; use
**Cases** to resume Case 2. Notes, pins, answers, citations, confidence, hints and
submitted results remain independent.

Switching saves the current case before leaving. If saving fails, choose
**Stay here** to retain current work, or explicitly **Switch without saving**.
**Reset case** requires confirmation and affects only the selected case.
Corrupt saves lock writes and are preserved; resetting first creates a `.backup`
of that case's original. An existing backup is never overwritten silently.
The other case remains accessible.

The Licenses button displays engine and third-party notices.
Existing version-1 saves retain their notes, selections, citations and hints.
Older saves without submission metadata must be submitted again to establish
a current completion result; they are not silently declared finished.

## Content and limitations

Basco/Batan and Itbayat are real places. All vessel activity, people, organizations,
records and incidents are fictional. The second case's image is a text observation
transcript, not a supplied photograph or forensic tool.
Made with Natural Earth: public-domain 1:10m land data, version 5.0.0,
repository revision `ace5fed0eaf3c6c03c951e75b439ba8fffbc218e`.
Source: https://github.com/nvkelso/natural-earth-vector

The map is generalized, not a navigational chart. Place labels and synthetic
vessel fixes are approximate. The geography's source date is not evidence for
the fictional incident.
There is no forensic imagery, sound design, 3D or two-hour campaign in this build.
These two cases test evidence-based assessment and independent progression.
The first owner playtest lasted approximately 20 minutes, with hints and an
assessment submission; completion was not confirmed. After the guidance revision,
the owner completed Case 1 in about five minutes with no remaining confusion.
That was a familiar-case replay, not fresh-player timing. Case 2's first owner session was about seven minutes with all hints used;
an assessment was submitted but not all findings were supported. The camera
times and feedback were confusing. This revision addresses that feedback;
clear completion, pacing and enjoyment still need human confirmation.
