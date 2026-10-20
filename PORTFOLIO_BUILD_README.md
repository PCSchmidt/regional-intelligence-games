# Regional Analysis Desk - The Missing Interval

Onboarding and coastline revision / 20 October 2026.

## Run

Extract the archive, then double-click `RegionalDesk.exe`.
Windows x64, keyboard and mouse. No editor, account, network or AI service required.
This is an unsigned personal build; Windows may display an unknown-publisher warning.
Only run a build you trust. This project does not require disabling Windows security.

## Play

### Your role and objective

You are a civilian regional analyst. A public post treats missing vessel-tracking
data as proof of a covert voyage and hostile activity. Your job is to test that
claim against the records, not to presume guilt. Unsupported allegations can
mislead decisions.

Deliver three findings: the best-supported stop, the explanation of the public
tracking gap, and what can be established about intent. No outside research is
required. All six records are available immediately.

### Start here

1. Read the **Dispatch extract** already open. Then read the remaining sources
   in any order, selecting the source list, timeline or map observations.
2. **Pin source to notebook** makes a useful record available for citation.
   Pinning alone does **not** cite it.
3. Under **each finding**, choose a conclusion and tick its supporting source
   boxes. Scroll the assessment panel to reach all three findings and Submit.
4. Select **Submit assessment**. Read the result, revise as needed and resubmit.
   Notes help your reasoning but are not graded. Confidence is reflective, not scored.
5. Finish when the result says **INVESTIGATION COMPLETE** and **3 of 3 findings
   supported**. That ends this case; there is no next case in this prototype.

The opening **Mission & Help** guide explains these steps. Reopen it from the
top of the desk at any time. Returning saves are not automatically interrupted
by the guide; open it manually if upgrading from the first build.

### Understanding feedback

| Status | Meaning / next action |
|---|---|
| INCOMPLETE | Choose a conclusion for this finding. |
| REVISE | Reconsider the conclusion; the evidence does not establish it. |
| NEEDS SUPPORT | The conclusion matches, but supporting citations are missing. Tick sources under this finding. |
| SUPPORTED | Both the conclusion and its required citations are accepted. |

Every submission opens a result dialog. The supported-finding count remains
visible above the scrolling assessment form. **Review latest result** reopens
the current debrief, including after restart. Editing the assessment/notebook
invalidates the displayed result until resubmission. Optional hints have no
timer or penalty.

### Map and controls

- Squares identify places; circles identify public position fixes; the diamond
  identifies the shore sighting. Labels show UTC observation times.
- Batan, Itbayat and Sabtang have real generalized coastlines and island names.
  The north indicator and approximate kilometer scale provide orientation.
- Drag empty map space to pan; use the wheel or +/- to zoom; **Reset view**
  restores the map. The scale changes with zoom.
- Observations do not form a continuous route. No observed route is drawn
  through the public tracking gap.
- Use the timeline as a keyboard-accessible alternative to map markers.
  Tab moves among ordinary controls; Space activates buttons and checkboxes.

## Save

Progress autosaves locally. A manual Save button is also available.
Default Windows location:
```text
%APPDATA%\Godot\app_userdata\Regional Analysis Desk\session.json
```
Reset case requires confirmation. Corrupt saves are not overwritten silently.
The Licenses button displays engine and third-party notices.
Existing version-1 saves retain their notes, selections, citations and hints.
Older saves without submission metadata must be submitted again to establish
a current completion result; they are not silently declared finished.

## Content and limitations

Basco/Batan and Itbayat are real places. All vessel activity, people, organizations,
records and the incident are fictional. All times are UTC.
Made with Natural Earth: public-domain 1:10m land data, version 5.0.0,
repository revision `ace5fed0eaf3c6c03c951e75b439ba8fffbc218e`.
Source: https://github.com/nvkelso/natural-earth-vector

The map is generalized, not a navigational chart. Place labels and synthetic
vessel fixes are approximate. The geography's source date is not evidence for
the fictional incident.
There is no forensic imagery, sound design, 3D or two-hour campaign in this build.
This small case tests an evidence and assessment interaction.
The first owner playtest lasted approximately 20 minutes, with hints and an
assessment submission; completion was not confirmed. This revision responds to
that feedback. Improved novice usability and enjoyment still need a new playtest.
