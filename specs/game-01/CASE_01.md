# Case 01 - The Missing Interval

## Player brief

The fictional coastal supply vessel **Lantern Six** disappears from a public tracking view for part of a morning. A circulating post claims the gap shows a covert northbound voyage toward Taiwan. Determine the best-supported stop, what explains the missing public observations, and whether hostile intent is established.

Real locations: Basco on Batan Island and Itbayat in Batanes, Philippines. All vessel activity, logs, posts, observers and organizations below are invented. The map combines approximate place/scenario markers with public-domain, generalized Natural Earth coastlines; it is not a navigation product.

## Geographic/reference sources

Reviewed 2026-10-20 for basic place identification only:

- [Basco, Batanes](https://en.wikipedia.org/wiki/Basco,_Batanes): Basco is on Batan Island and is the provincial capital.
- [Itbayat](https://en.wikipedia.org/wiki/Itbayat): Itbayat is in Batanes, north of Batan.

No article text, images or map tiles are redistributed. Marker positions are approximate contextual labels, not surveyed coordinates. Fictional vessel fixes are authored scenario data.

The revised map redistributes a six-island subset of **Natural Earth 1:10m land, version 5.0.0**. [Pinned dataset](https://raw.githubusercontent.com/nvkelso/natural-earth-vector/ace5fed0eaf3c6c03c951e75b439ba8fffbc218e/geojson/ne_10m_land.geojson) and [public-domain license](https://github.com/nvkelso/natural-earth-vector/blob/ace5fed0eaf3c6c03c951e75b439ba8fffbc218e/LICENSE.md) were reviewed. **Made with Natural Earth.** The [game README](../../games/regional-desk/README.md#coastline-provenance-and-reproduction) records the source hash, extraction bounds and reproducible transformation. Generalization and dataset age limit accuracy; geographic source dates are not incident dates.

The coastlines revealed two originally authored vessel positions on land. Both source text and timeline fixes were corrected together: 07:40 moved to 20.760 N, 121.775 E, west of Itbayat; 09:00 moved to 20.675 N, 121.820 E, south of Itbayat. All plotted vessel observations now test offshore. These are corrections to synthetic scenario geometry, not historical claims. The assessment rubric and version-1 save compatibility are unchanged.

## Author-only truth and uncertainty

- Lantern Six leaves the Basco area with a consignment of communications batteries.
- An unplanned request leads to an Itbayat delivery. A lookout observation and a receipt independently support the stop.
- A public relay outage overlaps the missing observations and affects another vessel as well.
- The outage is the best-supported explanation for the public gap; these records do not prove the transmitter stayed on throughout it.
- There is no evidence sufficient to establish hostile intent. A routine delivery is supported, but this limited case does not prove every action or motive.

## Evidence graph

| ID | UTC | Record | Reasoning role |
|---|---|---|---|
| manifest | 05:30 | Dispatch extract | Establishes vessel identifier, cargo and initial plan; a plan is not a completed voyage |
| tracks | 10:00 | Public receiver export | Fixes at 06:00, 06:30, 09:00 and 10:00; no observed track within the gap |
| lookout | 07:40 | Annotated lookout entry | Identifies LN-6 approaching Itbayat; corroborates receipt |
| receipt | 08:05 | Delivery receipt | Records battery unloading at Itbayat and matches LN-6; corroborates lookout |
| rumor | 08:30 | Public post | Claims a covert voyage; explicitly supplies no independent location observation |
| relay | 09:20 | Receiver service notice | Reports the relay outage and missing observations for multiple vessels |

All records are available immediately. The player is not required to guess search terms or unlock sources in an exact order.

### Assessment rubric

| Finding | Accepted conclusion | Required support | Limitation in debrief |
|---|---|---|---|
| Best-supported stop | Itbayat delivery stop | lookout + receipt | Does not reconstruct every minute of the voyage |
| Best explanation of public gap | Receiver relay outage | tracks + relay | Not proof that the vessel's transmitter never stopped |
| Hostile intent | Not established by this evidence | receipt + relay | Not equivalent to proving all possible misconduct absent |

Citations are selected per finding from pinned sources. Extra citations do not compensate for missing required support. No partial numerical score or confidence penalty. Players can revise after explanatory feedback.

## Suggested walkthrough

1. Read the briefing and dispatch record.
2. Select timeline/map observations and compare the public track interval.
3. Read the post; distinguish its inference from a direct sighting.
4. Compare the lookout with the receipt; pin both.
5. Compare the receiver export with the service notice; pin both.
6. File the three findings with their individual citations.
7. Read limitations in the debrief. Revisit unsupported claims if needed.

The mission/help guide explains this procedure without exposing the accepted answers above. Every submission shows a supported-finding count and result dialog; three supported findings explicitly finish the case. Saved submitted results are recomputed on load. Older saves without submission metadata retain their progress but require resubmission.

Reverse-order discovery must work equally well. This is a small interaction prototype, not a claim of completed two-hour content.

## Expansion after playtesting

Only if the core loop is engaging: add a genuine chronology ambiguity, a sourced geographic inference or a second plausible identity requiring disambiguation. Do not add extra documents just to stretch playtime.
