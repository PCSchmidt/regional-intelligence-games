# Offline map sources and licenses

This map is geographic context, not case evidence or a navigational chart.
Incident positions and fictional work labels are not geographic facilities.

## OpenStreetMap

Map data (c) OpenStreetMap contributors.
https://www.openstreetmap.org/copyright

The derived database `offline_map.json`, including clipped streets/buildings,
port/coast lines, selected names and complete coastline rings, is available under
the Open Data Commons Open Database License, version 1.0 (ODbL).
License: https://opendatacommons.org/licenses/odbl/1-0/
Individual database contents: https://opendatacommons.org/licenses/dbcl/1-0/

The same machine-readable derived database, with source URLs, SHA256 input hashes,
snapshot date, bounded coverage and processing notes, is freely available at:
https://github.com/PCSchmidt/regional-intelligence-games/blob/main/games/regional-desk/content/offline_map.json
It is also included in the executable's embedded resource pack.
The relief raster's Batan/Itbayat land mask is a produced work derived from those
coastlines; OpenStreetMap attribution applies to that image as well.
These data terms do not impose a project-wide license on the game code.

Town snapshots: 20 October 2026. Basco has mapped buildings, roads and five supplied
pier/breakwater/quay lines. Itbayat has buildings, roads and named port points,
but no supplied pier outlines. Unmapped features and building multipolygon
relations are not reconstructed. Detail ends at the declared town bounds.

## Elevation and shaded relief

Mapzen Global Terrain / Tilezen Joerd, AWS public elevation tiles, Skadi format.
USGS SRTM and GMTED2010 elevation data courtesy of the U.S. Geological Survey.
Global ETOPO1: DOC/NOAA/NESDIS/NCEI, National Centers for Environmental Information,
NESDIS, NOAA, U.S. Department of Commerce.
These global U.S. government source datasets are public domain in the United States.

Documentation and attribution reviewed at revision:
https://github.com/tilezen/joerd/tree/0b86765156d0612d837548c2cf70376c43b3405c/docs
Raw source URLs and hashes are recorded in `offline_map.json`.

Two merged Skadi grids were cropped, colored and hillshaded with approximate
100 m elevation-contour crossings. The output grid is one arc second
(approximately 30 m), NOT a guarantee of 30 m effective source resolution.
The merged grids can contain coarser data; per-pixel source identity is not
supplied. Do not describe this extract as uniformly high-resolution SRTM.
Complete OpenStreetMap coastlines replace the coarse Batan/Itbayat land mask.
Flat styled sea is not bathymetry. No elevation voids were silently filled.
No source agency endorses the modifications or warrants fitness for navigation.

## Earlier generalized coastline reference

Made with Natural Earth. Public-domain 1:10m land data, version 5.0.0.
https://github.com/nvkelso/natural-earth-vector
Revision: ace5fed0eaf3c6c03c951e75b439ba8fffbc218e.
The earlier six-island subset remains a separate generalized reference/test asset,
not a source of fabricated street or harbor detail.
