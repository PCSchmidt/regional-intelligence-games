# Case 02 - The Borrowed Name

## Player brief

The day after The Missing Interval, a new post assigns an Itbayat image to Lantern Six and labels its camera time as UTC. Compare identity details, clock conventions and independently recorded positions before accepting a northbound-voyage claim.

Real setting: Basco/Batan and Itbayat, Philippines. All vessels, observations, registrations, timestamps and documents are fictional. Existing Natural Earth coastlines are reused; no new geographic or asset claims are introduced. The image is explicitly an authored observation transcript, not a photograph or forensic image-analysis tool.

## Author-only truth and uncertainty

- Lantern Six (LN-6) and Lantern Nine (LN-9) are different fictional local supply vessels. The similar name is insufficient identification.
- Registry descriptions distinguish three rectangular cabin windows on LN-6 from two round cabin portholes on LN-9. The image shows two round cabin portholes; the name suffix and hull number are unreadable.
- The image's Q4 camera displays local time, UTC+08:00. Its 08:20 on 15 September corresponds to 00:20 UTC that same date. Archive indexing at 08:45 UTC is not capture time.
- A separately kept quay ledger places LN-9 approaching Itbayat at 00:10 UTC. A Basco observer identifies LN-6 at 06:40 UTC. These are two vessels, not points belonging to one observed route.
- The post reuses the same archive frame, drops the time-zone context and assigns the cropped name to LN-6. It adds no independent position observation.
- This corrects the claimed identification and chronology; it does not reconstruct either vessel's whole day or prove that LN-6 never visited Itbayat.

## Evidence graph

| ID | Document UTC | Record | Role |
|---|---|---|---|
| assignment | 09:10 | Review request | Sets the disputed claim and three questions without giving the answers |
| registry | 06:00 | Local vessel register | Maps local hull IDs and structural features to two similar names |
| image | 08:45 | Archive observation transcript | Shows two round cabin portholes and an unzoned 08:20 overlay; names Q4 and frame Q4-0915-0820 |
| clock | 08:50 | Q4 camera setting card | Establishes UTC+08:00 convention; requires conversion rather than giving this frame's answer |
| quay | 00:35 | Itbayat approach ledger | Independently identifies LN-9 at an approximate offshore arrival point at 00:10 UTC |
| basco | 06:40 | Basco observation | Independently identifies LN-6 offshore at 06:40 UTC |
| claim | 09:00 | Circulating identification post | Reuses frame Q4-0915-0820, calls it LN-6 at 08:20 UTC and claims a northbound run |

All seven documents are immediately available in any order. Three different comparisons are required, not a larger pile of filler documents.

### Assessment rubric

| Finding | Accepted conclusion | Required support | Counterexample / limit |
|---|---|---|---|
| Image identity | Best match is Lantern Nine / LN-9 | registry + image | Cropped shared name is not enough; no clear hull ID is claimed in the image |
| Image capture time | 00:20 UTC on 15 September | image + clock | 08:20 is local camera time; 08:45 is archive indexing, not capture |
| Independent positions | LN-9 near Itbayat at 00:10; LN-6 near Basco at 06:40 | quay + basco | Do not merge different IDs into one track; no full-day route or speed inference is justified |

The first pair establishes the best identity match, the second resolves time, and the third supplies independent geographic corroboration. Extra citations are allowed but do not replace each finding's decisive pair. All alternative conclusions must fail explicitly; omitting either member of a decisive pair must yield NEEDS SUPPORT.

## Progression and saves

- Retain Case 1 as a concise introduction; do not inflate its existing evidence.
- A visible Cases selector lists both investigations, with not-started/in-progress/complete/save-attention states. Either case can be opened directly.
- Completing Case 1 enables a Continue to Case 2 shortcut. Finishing Case 2 says no third case is available, not that the eventual campaign is complete.
- Case 1 retains its existing version-1 save path. Case 2 has a separate save. Switching normally saves the current case before loading the target.
- A failed/locked save prevents automatic departure; the player must explicitly confirm switching without saving or stay. A corrupt case must not disable the other investigation.
- Reset and recovery apply only to the selected case. Existing first-case progress is never migrated destructively or reset to introduce Case 2.
- Restart opens Case 1 by default; the player can select Case 2 to resume. Last-selected-case persistence is intentionally out of scope.

## Testing strategy

Native desktop, existing Godot runner only. Browser, HTTP, credentials and external infrastructure remain not applicable.

1. Retain baseline 140 canonical checks.
2. Extend content tests: both fixtures validate; each new wrong conclusion fails; each missing required citation needs support; all new observation points are offshore. Display capture/index times without pre-solving the UTC conversion.
3. Add a real scene/file journey: edit Case 1, switch to Case 2, complete it, switch back, restart and resume both; compare notes, hints, citations and completion independently.
4. Test failed-switch cancel/confirm, corrupt Case 2 preservation/recovery and Case-2-only reset without changing Case 1.
5. Render both cases, inspect the longer seven-record list, selector and progression control at 1280 x 900; export and rerun the multi-case journey against the embedded resource pack, plus actual release startup.

All tests use isolated paths, clean up named files and enter the canonical Test command. Every final command must exit 0. Existing player saves are not test fixtures.

## Acceptance and limits

Both cases must be completable offline and resume independently. New-case guide and feedback must not mention Case 1's accepted answers. A future owner playtest must record unfamiliar-case time, hints and confusion; neither 15-25 minutes nor a two-hour campaign is claimed by this implementation.
