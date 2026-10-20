// Extract whole island exteriors; never invent or simplify coastline coordinates.
const fs = require('node:fs');
const crypto = require('node:crypto');

const [input, output] = process.argv.slice(2);
if (!input || !output) {
  throw new Error('Usage: node tools\\extract-coastline.cjs input.geojson output.json');
}
const bytes = fs.readFileSync(input);
const sha256 = crypto.createHash('sha256').update(bytes).digest('hex');
if (sha256 !== '1ac90796408bc6ad6911d69448485d3c4dbf2190370080368a09976e1c9f7416') {
  throw new Error('Input does not match the reviewed Natural Earth revision.');
}
const source = JSON.parse(bytes);
const polygons = [];
for (const feature of source.features) {
  const geometry = feature.geometry;
  const parts = geometry.type === 'MultiPolygon' ? geometry.coordinates :
    geometry.type === 'Polygon' ? [geometry.coordinates] : [];
  for (const part of parts) {
    const ring = part[0];
    const inBounds = ([x, y]) => x >= 121.55 && x <= 122.25 && y >= 20.1 && y <= 21.15;
    if (!ring.some(inBounds)) continue;
    if (!ring.every(inBounds)) throw new Error('Selected island crosses the extraction bounds.');
    if (part.length !== 1) throw new Error('Selected polygon contains holes; review extraction.');
    polygons.push(ring);
  }
}
if (!polygons.length) throw new Error('No Batanes coastlines found.');
const data = {
  source: 'Natural Earth 1:10m land, version 5.0.0',
  revision: 'ace5fed0eaf3c6c03c951e75b439ba8fffbc218e',
  sha256,
  license: 'Public domain; made with Natural Earth. Generalized, not for navigation.',
  coordinate_order: 'longitude, latitude (WGS84 degrees)',
  polygons
};
fs.writeFileSync(output, JSON.stringify(data) + '\n');
console.log(`Extracted ${polygons.length} complete island polygons (${polygons.reduce((n, p) => n + p.length, 0)} vertices).`);
