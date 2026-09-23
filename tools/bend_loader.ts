/**
 * Local Bun preload: `import X from './m.bend'` yields the ES module that the
 * pinned Bend 2.0.25 compiler itself emits for m.bend (its load_js/js_lib path,
 * reached through the official `bend <page.html> -o <dir>` bundler).
 * No Bend algorithm is reimplemented here; this file only compiles, caches
 * and re-exports the compiler's output. Compile errors abort the import.
 */
import {plugin} from 'bun';
import {createHash} from 'node:crypto';
import {existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, realpathSync, renameSync, rmSync, statSync, writeFileSync} from 'node:fs';
import {join, relative, resolve} from 'node:path';

const ROOT = resolve(import.meta.dir, '..');
const LOCK = JSON.parse(readFileSync(join(ROOT, 'benchmarks/toolchain.json'), 'utf8'));
const BEND: string = LOCK.bend.path;
const CACHE = join(ROOT, 'build/bend-loader');

function sha256(data: string | Buffer): string {
  return createHash('sha256').update(data).digest('hex');
}

function pinned(): string {
  const parts = ['bend', 'base'].map(key => {
    const actual = sha256(readFileSync(LOCK[key].path));
    if (actual !== LOCK[key].sha256) throw Error(`bend loader: pinned ${key} changed (${actual})`);
    return actual;
  });
  return LOCK.version + ':' + parts.join(':');
}

// Every workspace .bend file enters the cache key, so no stale import survives an edit.
function sources(dir: string, out: string[] = []): string[] {
  for (const name of readdirSync(dir).sort()) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) {
      if (!['build', 'fixtures', 'node_modules', '.git'].includes(name)) sources(path, out);
    } else if (name.endsWith('.bend')) out.push(path);
  }
  return out;
}

let toolchain: string | undefined;
let tree: string | undefined;

function compile(file: string): string {
  toolchain ??= pinned();
  tree ??= sha256(sources(ROOT).map(p => relative(ROOT, p) + ' ' + sha256(readFileSync(p))).join('\n'));
  const real = realpathSync(file);
  const key = sha256([toolchain, tree, real, sha256(readFileSync(real))].join('\n'));
  const global = '__bend_local_loader_' + key.slice(0, 16);
  const cached = join(CACHE, key + '.js');
  if (!existsSync(cached)) {
    mkdirSync(CACHE, {recursive: true});
    const dir = mkdtempSync(join(CACHE, 'work-'));
    try {
      writeFileSync(join(dir, 'entry.js'), `import M from ${JSON.stringify(real)};\nglobalThis[${JSON.stringify(global)}] = M;\n`);
      writeFileSync(join(dir, 'page.html'), '<!doctype html><script type="module" src="./entry.js"></script>\n');
      const run = Bun.spawnSync([BEND, 'page.html', '-o', 'out'], {cwd: dir, env: {...process.env, BEND_NO_TELEMETRY: '1'}, stdout: 'pipe', stderr: 'pipe'});
      const chunks = existsSync(join(dir, 'out')) ? readdirSync(join(dir, 'out')).filter(f => f.endsWith('.js')) : [];
      if (run.exitCode !== 0 || chunks.length !== 1) {
        throw Error(`bend loader: compiling ${relative(ROOT, real)} failed (exit ${run.exitCode})\n${run.stdout}${run.stderr}`);
      }
      const code = readFileSync(join(dir, 'out', chunks[0]), 'utf8');
      const temporary = cached + '.' + process.pid;
      writeFileSync(temporary, code + `\nconst __bend_local_loader_module = globalThis[${JSON.stringify(global)}];\n` +
        `if (__bend_local_loader_module === undefined) throw Error("bend loader: no module for ${relative(ROOT, real)}");\n` +
        'export default __bend_local_loader_module;\n');
      renameSync(temporary, cached);
    } finally {
      rmSync(dir, {recursive: true, force: true});
    }
  }
  return readFileSync(cached, 'utf8');
}

plugin({
  name: 'bend-local-loader',
  setup(build) {
    build.onLoad({filter: /\.bend$/}, args => ({contents: compile(args.path), loader: 'js'}));
  },
});
