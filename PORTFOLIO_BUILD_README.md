# Regional Analysis Desk - Three Investigations

Three-case / offline terrain-and-town-map build / 20 October 2026.

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
| 3. The Echoed Warning | Trace reporting sources, read a correction and test independent support | Desk review request; six records |

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
   supported**. Case 1 enables **Continue to Case 2**; Case 2 enables
   **Continue to Case 3**.
6. The header's **Cases** selector opens any included case directly, with its own
   progress status. Case 3 finishes this build's available content, not a
   guaranteed two-hour campaign. No fourth investigation is included.

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
- The regional view has sourced shaded relief and approximate 100 m elevation
  contours. The north indicator and zoom-aware kilometer/meter scale provide
  orientation. The output elevation grid is about 30 m; effective source detail
  varies and can be coarser.
- Drag empty map space to pan; use the wheel or +/- to zoom; **Reset view**
  restores the map. The scale changes with zoom.
- **Expand map** opens a larger view. Its selector offers **Region**, **Basco
  town / port**, **Itbayat town** and **Chinapoliran Port**. Use the wheel or +/-
  to inspect actual supplied streets and building footprints. Esc or OK closes
  the expanded view; clicking a synthetic observation opens its source.
- Street/building detail is limited to the supplied town areas. Basco has five
  supplied pier/breakwater/quay outlines; Itbayat has named ports and roads, but
  no supplied pier outlines. Features not present in the source are not invented.
  These are map features, not 3D models, satellite imagery or new case clues.
- Observations do not form a continuous route. Do not merge observations of
  different vessels into a single track.
- In Case 3, the map provides regional context only: there are no mapped vessel
  observations or work-area positions. A/B are fictional work labels, not real
  named piers. Select timeline entries to open their sources.
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
%APPDATA%\Godot\app_userdata\Regional Analysis Desk\session-case-03.json
```
The first path is unchanged from earlier builds. Restart opens Case 1; use
**Cases** to resume Case 2 or 3. Notes, pins, answers, citations, confidence, hints and
submitted results remain independent.

Switching saves the current case before leaving. If saving fails, choose
**Stay here** to retain current work, or explicitly **Switch without saving**.
**Reset case** requires confirmation and affects only the selected case.
Corrupt saves lock writes and are preserved; resetting first creates a `.backup`
of that case's original. An existing backup is never overwritten silently.
Other cases remain accessible.

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
The newer map combines **OpenStreetMap contributors** data under **ODbL-1.0**
with **Mapzen Global Terrain**, USGS SRTM/GMTED2010 and NOAA ETOPO1 elevation.
The Batan/Itbayat land mask uses sourced OSM coastlines, rather than the coarse
elevation shoreline. Flat styled water is not sea-depth information.
Map data license: https://opendatacommons.org/licenses/odbl/1-0/
Attribution: https://www.openstreetmap.org/copyright
The derived machine-readable OSM database, source URLs/hashes and processing
notes are freely available under ODbL at:
https://github.com/PCSchmidt/regional-intelligence-games/blob/main/games/regional-desk/content/offline_map.json
It is also embedded in the executable. The **Licenses** button provides offline
map notices and terrain-source limitations. Map-data terms do not establish
a project-wide reuse license for the game code.
There is no forensic imagery, sound design, 3D or two-hour campaign in this build.
These three cases test evidence-based assessment and independent progression.
Case 3 adds source lineage, precise correction reading and bounded corroboration.
Every third-case time is explicitly UTC; no clock conversion is required.
Its owner playtest is pending.
The first owner playtest lasted approximately 20 minutes, with hints and an
assessment submission; completion was not confirmed. After the guidance revision,
the owner completed Case 1 in about five minutes with no remaining confusion.
That was a familiar-case replay, not fresh-player timing. Case 2's first owner session was about seven minutes with all hints used;
an assessment was submitted but not all findings were supported. The camera
times and feedback were confusing. After this revision, the owner reports that
the information made sense and all selections were correctly determined in
about five minutes. Hint use and the final supported-finding count were not
explicitly reported. This familiar-case replay confirms owner comprehension,
not novice timing; pacing and enjoyment still need evaluation.
