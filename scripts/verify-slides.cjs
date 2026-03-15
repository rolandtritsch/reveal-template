'use strict';
// Screenshot page 1 of generated slide PDFs into tmp/ for visual verification.
//
// Usage:
//   node scripts/verify-slides.cjs
//
// Requires: pdftoppm (poppler-utils)
// Finds docs/**/*-slides{,_with-notes}.pdf and saves page 1 as a PNG to ./tmp/.

const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const TMP_DIR = path.resolve('./tmp');

function findPdfs(dir, results = []) {
  if (!fs.existsSync(dir)) return results;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      findPdfs(full, results);
    } else if (entry.name.endsWith('-slides.pdf') || entry.name.endsWith('-slides_with-notes.pdf')) {
      results.push(full);
    }
  }
  return results;
}

if (!fs.existsSync(TMP_DIR)) {
  fs.mkdirSync(TMP_DIR, { recursive: true });
}

const files = [
  ...findPdfs(path.resolve('./public')),
];

if (files.length === 0) {
  console.log('No slide PDFs found. Run make generate-print-pdf first.');
  process.exit(0);
}

let failed = false;

for (const file of files) {
  const basename = path.basename(file, '.pdf');
  const outPrefix = path.join(TMP_DIR, `verify-${basename}-p`);

  // pdftoppm -f 1 -l 1 -r 120 -png <input> <prefix>
  // Produces <prefix>-1.ppm or <prefix>-01.png etc.
  const result = spawnSync(
    'pdftoppm',
    ['-f', '1', '-l', '1', '-r', '120', '-png', file, outPrefix],
    { stdio: 'inherit' },
  );

  if (result.status !== 0) {
    console.error(`ERROR: pdftoppm failed for ${file}`);
    failed = true;
    continue;
  }

  // pdftoppm names the output <prefix>-<padded-page>.png
  const produced = fs.readdirSync(TMP_DIR)
    .filter(n => n.startsWith(`verify-${basename}-p`) && n.endsWith('.png'))
    .map(n => path.join(TMP_DIR, n));

  for (const p of produced) console.log(`Saved: ${p}`);
}

process.exit(failed ? 1 : 0);
