import { readdirSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join, relative } from 'node:path';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const projectRoot = dirname(scriptDir);
const sourceDir = join(projectRoot, 'src');
const allowedExtensions = new Set(['.ts', '.tsx', '.css']);
const violations = [];

function walk(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(path);
      continue;
    }

    const dotIndex = entry.name.lastIndexOf('.');
    const extension = dotIndex >= 0 ? entry.name.slice(dotIndex) : '';
    if (!allowedExtensions.has(extension)) {
      continue;
    }

    const lines = readFileSync(path, 'utf8').split(/\r?\n/);
    lines.forEach((line, index) => {
      if (/[ \t]+$/.test(line)) {
        violations.push(`${relative(projectRoot, path)}:${index + 1}`);
      }
    });
  }
}

walk(sourceDir);

if (violations.length > 0) {
  console.error('Trailing whitespace found in professional_portal sources:');
  for (const violation of violations) {
    console.error(` - ${violation}`);
  }
  process.exit(1);
}

console.log('No trailing whitespace found in professional_portal sources.');
