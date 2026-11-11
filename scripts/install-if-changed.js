#!/usr/bin/env node
/*
 * Installs npm dependencies only in the folders whose dependencies changed since that
 * folder's last successful install. run.sh, run.bat and switch-mode.js call it instead of
 * running npm ci / npm install unconditionally.
 *
 * After a successful install it writes node_modules/.install-stamp.json. The stamp holds a
 * fingerprint of what decides the contents of node_modules:
 *   - package-lock.json without the package's own name and version, so a version bump
 *     alone does not reinstall;
 *   - the dependency fields of package.json, and those of each --with folder;
 *   - the platform, the CPU architecture and the dependency types npm leaves out
 *     (NODE_ENV=production, npm_config_omit, npm_config_include, npm_config_production).
 * The stamp also holds a hash of npm's own record of the installed tree
 * (node_modules/.package-lock.json), so an npm install or npm ci run by hand is noticed.
 *
 * A folder is skipped while its stamp matches. It is installed when node_modules is
 * missing, the stamp or npm's record differs, a --with folder has no node_modules, or its
 * last install did not finish: <dir>/.install-pending is written before npm starts and
 * removed only after the stamp is written, so a failed or interrupted install runs again.
 * If package.json or package-lock.json change while npm runs, no stamp is written either.
 * Deleting node_modules (run.sh --clean) forces an install.
 *
 * A folder installed before this script existed has no stamp. It is adopted, that is
 * stamped without a reinstall, only when
 *   - npm recorded a finished install (node_modules/.package-lock.json exists);
 *   - its node_modules/.bin launchers were written on this kind of system;
 *   - package.json's dependencies are the ones package-lock.json was made for;
 *   - every package in package-lock.json is installed at the locked version, apart from
 *     optional packages npm leaves out on this platform;
 *   - every --with folder passes the same checks, and a folder with its own install
 *     scripts has --with folders that cover them (the root's postinstall installs shared).
 *
 * Usage: node scripts/install-if-changed.js [options] DIR...
 *   --ci             use npm ci, falling back to npm install if it fails (default: npm install)
 *   --force          install even when the stamp matches
 *   --concurrency N  folders to install at the same time (default: $INSTALL_CONCURRENCY or 3)
 *   --allow-stale    when an install fails and the folder has a finished earlier install, warn
 *                    and keep it instead of failing (run.sh/run.bat --offline). Uses npm install
 *                    --prefer-offline, because npm ci deletes node_modules before it installs.
 *   --with DIR       every DIR's install also installs this folder (the root's postinstall
 *                    installs shared): add its dependencies to the fingerprint and require
 *                    its node_modules
 */
'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { spawn, spawnSync } = require('child_process');

const STAMP_FILE = '.install-stamp.json';
const PENDING_FILE = '.install-pending';
const DEPENDENCY_FIELDS = [
  'dependencies', 'devDependencies', 'optionalDependencies', 'peerDependencies',
  'peerDependenciesMeta', 'bundleDependencies', 'bundledDependencies', 'overrides', 'workspaces',
];
// The fields npm copies into package-lock.json's root entry. npm ci refuses to run when
// they differ from package.json.
const LOCKED_FIELDS = ['dependencies', 'devDependencies', 'optionalDependencies', 'peerDependencies'];
const INSTALL_SCRIPTS = ['preinstall', 'install', 'postinstall', 'prepare'];
// npm is npm.cmd on Windows, which Node only starts through a shell.
const SHELL = process.platform === 'win32';

function stableStringify(value) {
  if (Array.isArray(value)) return `[${value.map(stableStringify).join(',')}]`;
  if (value && typeof value === 'object') {
    return `{${Object.keys(value).sort()
      .map((key) => `${JSON.stringify(key)}:${stableStringify(value[key])}`)
      .join(',')}}`;
  }
  return JSON.stringify(value);
}

function readText(file) {
  try {
    return fs.readFileSync(file, 'utf8');
  } catch (error) {
    if (error.code === 'ENOENT') return null;
    throw error;
  }
}

function readJson(file) {
  const text = readText(file);
  if (text === null) return null;
  try {
    return JSON.parse(text);
  } catch (error) {
    return null;
  }
}

function display(dir) {
  return path.relative(process.cwd(), path.resolve(dir)) || path.basename(path.resolve(dir));
}

// The dependency fields of DIR/package.json, in a stable order.
function dependencySpec(dir) {
  const text = readText(path.join(dir, 'package.json'));
  if (text === null) return 'no package.json';
  let pkg;
  try {
    pkg = JSON.parse(text);
  } catch (error) {
    return `unparsable package.json: ${text}`;
  }
  const picked = {};
  for (const field of DEPENDENCY_FIELDS) {
    if (pkg[field] !== undefined) picked[field] = pkg[field];
  }
  return stableStringify(picked);
}

// DIR/package-lock.json without the package's own name and version.
function lockSpec(dir) {
  const text = readText(path.join(dir, 'package-lock.json'));
  if (text === null) return 'no package-lock.json';
  let lock;
  try {
    lock = JSON.parse(text);
  } catch (error) {
    return `unparsable package-lock.json: ${text}`;
  }
  delete lock.name;
  delete lock.version;
  if (lock.packages && lock.packages['']) {
    delete lock.packages[''].name;
    delete lock.packages[''].version;
  }
  return stableStringify(lock);
}

// The dependency types npm leaves out, as set through the environment. Settings in .npmrc
// files are not read: delete node_modules after changing them there.
function omitSetting() {
  const env = {};
  for (const [key, value] of Object.entries(process.env)) env[key.toLowerCase()] = value;
  const list = (value) => String(value || '').split(/[\s,]+/).filter(Boolean);
  const omit = new Set(list(env.npm_config_omit));
  if (env.node_env === 'production' || ['true', '1'].includes(String(env.npm_config_production))) {
    omit.add('dev');
  }
  for (const kind of list(env.npm_config_include)) omit.delete(kind);
  return [...omit].sort().join(',');
}

function fingerprint(dir, withDirs = []) {
  const hash = crypto.createHash('sha256');
  const add = (label, value) => hash.update(`${label}\0${value}\0`);
  add('platform', `${process.platform}-${process.arch}`);
  add('omit', omitSetting());
  add('package.json', dependencySpec(dir));
  add('package-lock.json', lockSpec(dir));
  for (const withDir of withDirs) {
    add(`with ${path.relative(path.resolve(dir), path.resolve(withDir))}`, dependencySpec(withDir));
  }
  return hash.digest('hex');
}

// A hash of npm's record of the installed tree, which every npm install and npm ci rewrites,
// without the package's own name and version (a version bump does not change the tree).
function treeHash(dir) {
  const text = readText(path.join(dir, 'node_modules', '.package-lock.json'));
  if (text === null) return null;
  let record = null;
  try {
    record = JSON.parse(text);
  } catch (error) {
    record = null;
  }
  if (record && typeof record === 'object') {
    delete record.name;
    delete record.version;
  }
  return crypto.createHash('sha256').update(record ? stableStringify(record) : text).digest('hex');
}

function hasDependencies(dir) {
  const pkg = readJson(path.join(dir, 'package.json'));
  return Boolean(pkg) && ['dependencies', 'devDependencies', 'optionalDependencies']
    .some((field) => pkg[field] && Object.keys(pkg[field]).length > 0);
}

// null when package.json's dependencies are the ones package-lock.json was made for.
function syncProblem(dir) {
  const pkg = readJson(path.join(dir, 'package.json'));
  const lock = readJson(path.join(dir, 'package-lock.json'));
  if (!pkg) return 'package.json cannot be read';
  if (!lock || !lock.packages || !lock.packages['']) return 'there is no package-lock.json to compare with';
  const root = lock.packages[''];
  const isEmpty = (value) => !value || Object.keys(value).length === 0;
  for (const field of LOCKED_FIELDS) {
    if (isEmpty(pkg[field]) && isEmpty(root[field])) continue;
    if (stableStringify(pkg[field] || {}) !== stableStringify(root[field] || {})) {
      return `the ${field} in package.json differ from the ones in package-lock.json`;
    }
  }
  return null;
}

// npm on Windows writes .cmd launchers into node_modules/.bin, npm elsewhere does not. A tree
// from the other kind of system may also hold the wrong platform packages.
function launcherProblem(dir) {
  let bins;
  try {
    bins = fs.readdirSync(path.join(dir, 'node_modules', '.bin'));
  } catch (error) {
    return null;
  }
  const windows = bins.some((name) => name.toLowerCase().endsWith('.cmd'));
  if (bins.length === 0 || windows === (process.platform === 'win32')) return null;
  return windows ? 'npm on Windows installed it' : 'npm outside Windows installed it';
}

// null when node_modules holds a finished install of the current package-lock.json,
// otherwise why it cannot be trusted. npm writes node_modules/.package-lock.json at the end of
// every successful install, and npm ci deletes node_modules before it starts. The versions are
// read from each installed package.json, because npm install --package-lock-only rewrites
// npm's record without installing anything.
function adoptionProblem(dir, withDirs = []) {
  const lock = readJson(path.join(dir, 'package-lock.json'));
  if (!lock || !lock.packages) return 'there is no package-lock.json to compare with';
  if (!fs.existsSync(path.join(dir, 'node_modules', '.package-lock.json'))) {
    return 'npm left no record of a finished install';
  }
  const problem = launcherProblem(dir) || syncProblem(dir);
  if (problem) return problem;
  for (const [key, entry] of Object.entries(lock.packages)) {
    if (key === '' || entry.link) continue;
    const installed = readJson(path.join(dir, key, 'package.json'));
    if (!installed) {
      // npm leaves out optional packages for other platforms (fsevents on Linux) and the
      // packages only they need. devOptional packages are installed with devDependencies.
      if (entry.optional) continue;
      return `${key} is not installed`;
    }
    if (entry.version && installed.version !== entry.version) {
      return `${key} is ${installed.version} but the lockfile has ${entry.version}`;
    }
  }
  for (const withDir of withDirs) {
    const withProblem = adoptionProblem(withDir);
    if (withProblem) return `${display(withDir)} cannot be adopted: ${withProblem}`;
  }
  const pkg = readJson(path.join(dir, 'package.json')) || {};
  const scripts = INSTALL_SCRIPTS.filter((name) => pkg.scripts && pkg.scripts[name]);
  if (scripts.length > 0 && withDirs.length === 0) {
    return `what its ${scripts.join(' and ')} script does cannot be checked`;
  }
  return null;
}

function decide(dir, options) {
  const nodeModules = path.join(dir, 'node_modules');
  if (options.force) return { action: 'install', reason: '--force' };
  if (fs.existsSync(path.join(dir, PENDING_FILE))) {
    return { action: 'install', reason: 'its last install did not finish' };
  }
  if (!fs.existsSync(nodeModules)) return { action: 'install', reason: 'node_modules is missing' };
  const missing = options.with.find((withDir) => hasDependencies(withDir)
    && !fs.existsSync(path.join(withDir, 'node_modules')));
  if (missing) return { action: 'install', reason: `${display(missing)}/node_modules is missing` };
  const stamp = readJson(path.join(nodeModules, STAMP_FILE));
  if (stamp) {
    if (stamp.fingerprint !== fingerprint(dir, options.with)) {
      return { action: 'install', reason: 'its dependencies or install settings changed since the last install' };
    }
    if (stamp.tree !== treeHash(dir)) {
      return { action: 'install', reason: 'node_modules was changed by an npm install or npm ci run by hand' };
    }
    return { action: 'skip', reason: 'dependencies unchanged since the last install' };
  }
  const problem = adoptionProblem(dir, options.with);
  return problem
    ? { action: 'install', reason: `no install stamp yet and ${problem}` }
    : { action: 'adopt', reason: 'the existing install matches package-lock.json' };
}

function stampPath(dir) {
  return path.join(dir, 'node_modules', STAMP_FILE);
}

function writeStamp(dir, options, how) {
  fs.mkdirSync(path.join(dir, 'node_modules'), { recursive: true });
  const stamp = {
    fingerprint: fingerprint(dir, options.with),
    tree: treeHash(dir),
    how,
    node: process.version,
    at: new Date().toISOString(),
  };
  fs.writeFileSync(stampPath(dir), `${JSON.stringify(stamp, null, 2)}\n`);
}

function snapshot(dir, options) {
  return {
    dependencies: [dir, ...options.with].map(dependencySpec).join('\0'),
    lock: readText(path.join(dir, 'package-lock.json')),
  };
}

// Marks DIR as being installed and returns what its install starts from.
function begin(dir, options) {
  const before = snapshot(dir, options);
  fs.writeFileSync(path.join(dir, PENDING_FILE), `${JSON.stringify({ started: new Date().toISOString() })}\n`);
  fs.rmSync(stampPath(dir), { force: true });
  return before;
}

// After npm succeeded: writes the stamp and removes the pending marker. Returns null, or why
// the folder stays pending so that the next run installs it again.
function finish(dir, options, before, how) {
  const after = snapshot(dir, options);
  if (after.dependencies !== before.dependencies) return 'package.json changed while npm was running';
  if (how === 'npm ci' && after.lock !== before.lock) return 'package-lock.json changed while npm was running';
  if (after.lock !== null) {
    const problem = syncProblem(dir);
    if (problem) return problem;
  }
  writeStamp(dir, options, how);
  fs.rmSync(path.join(dir, PENDING_FILE), { force: true });
  return null;
}

function npmArgs(dir, ci, allowStale) {
  if (allowStale) return ['install', '--prefer-offline'];
  return ci && fs.existsSync(path.join(dir, 'package-lock.json')) ? ['ci'] : ['install'];
}

function withDefaults(options) {
  return { ci: false, force: false, allowStale: false, with: [], ...options };
}

// Starts npm in DIR. With a prefix, its output is piped and every line is prefixed so that
// parallel installs stay readable; without one, npm writes to the terminal directly.
function runNpm(dir, args, prefix) {
  return new Promise((resolve) => {
    const child = spawn('npm', args, {
      cwd: dir,
      shell: SHELL,
      stdio: prefix ? ['ignore', 'pipe', 'pipe'] : 'inherit',
    });
    if (prefix) {
      for (const [stream, out] of [[child.stdout, process.stdout], [child.stderr, process.stderr]]) {
        let rest = '';
        stream.setEncoding('utf8');
        stream.on('data', (chunk) => {
          const lines = (rest + chunk).split(/\r?\n/);
          rest = lines.pop();
          for (const line of lines) out.write(`[${prefix}] ${line}\n`);
        });
        stream.on('end', () => {
          if (rest) out.write(`[${prefix}] ${rest}\n`);
        });
      }
    }
    child.on('error', (error) => {
      console.error(`[${prefix || display(dir)}] could not start npm: ${error.message}`);
      resolve(1);
    });
    child.on('close', (code) => resolve(code === null ? 1 : code));
  });
}

function runNpmSync(dir, args) {
  const result = spawnSync('npm', args, { cwd: dir, shell: SHELL, stdio: 'inherit' });
  return result.status === null ? 1 : result.status;
}

// Skips, adopts or installs DIR. `run` starts npm and returns its exit code, or a promise of
// it; the result is 'skipped', 'adopted' or 'installed', or a promise of it.
function handle(dir, options, say, run) {
  const opts = withDefaults(options);
  const decision = decide(dir, opts);
  if (decision.action === 'skip') {
    say(`⏭️  ${display(dir)}: ${decision.reason}, skipping the install`);
    return 'skipped';
  }
  if (decision.action === 'adopt') {
    writeStamp(dir, opts, 'adopted');
    say(`⏭️  ${display(dir)}: ${decision.reason}, recorded it without reinstalling`);
    return 'adopted';
  }
  const before = begin(dir, opts);
  const args = npmArgs(dir, opts.ci, opts.allowStale);
  say(`📦 ${display(dir)}: ${decision.reason}, running npm ${args.join(' ')}`);
  const done = (code, how) => {
    if (code !== 0 && opts.allowStale && fs.existsSync(path.join(dir, 'node_modules', '.package-lock.json'))) {
      say(`⚠️  ${display(dir)}: ${how} failed (exit code ${code}), continuing with the existing node_modules`
        + ' because of --allow-stale; the next run installs it again');
      return 'stale';
    }
    if (code !== 0) throw new Error(`${display(dir)}: ${how} failed with exit code ${code}`);
    const problem = finish(dir, opts, before, how);
    if (problem) say(`⚠️  ${display(dir)}: ${problem}, so the next run installs it again`);
    return 'installed';
  };
  const afterFirst = (code) => {
    if (code === 0 || args[0] !== 'ci') return done(code, `npm ${args.join(' ')}`);
    say(`⚠️  ${display(dir)}: npm ci failed, falling back to npm install`);
    const second = run(['install']);
    return second instanceof Promise
      ? second.then((c) => done(c, 'npm install'))
      : done(second, 'npm install');
  };
  const first = run(args);
  return first instanceof Promise ? first.then(afterFirst) : afterFirst(first);
}

async function ensureInstalled(dir, options, prefix = null) {
  const say = (message) => console.log(`${prefix ? `[${prefix}] ` : ''}${message}`);
  return handle(dir, options, say, (args) => runNpm(dir, args, prefix));
}

// Synchronous single-folder version for switch-mode.js. Throws when the install fails.
function ensureInstalledSync(dir, options) {
  return handle(dir, options, (message) => console.log(message), (args) => runNpmSync(dir, args));
}

function usage() {
  return [
    'Usage: node scripts/install-if-changed.js [options] DIR...',
    '  --ci             use npm ci, falling back to npm install if it fails (default: npm install)',
    '  --force          install even when the stamp matches',
    '  --concurrency N  folders to install at the same time (default: $INSTALL_CONCURRENCY or 3)',
    '  --allow-stale    if an install fails, keep a finished earlier install instead of failing',
    '  --with DIR       every DIR\'s install also installs this folder: add its dependencies',
    '                   to the fingerprint and require its node_modules',
  ].join('\n');
}

function parseArgs(argv) {
  const fail = (message) => {
    console.error(`install-if-changed: ${message}\n${usage()}`);
    process.exit(2);
  };
  const options = {
    ci: false,
    force: false,
    allowStale: false,
    concurrency: Number(process.env.INSTALL_CONCURRENCY || 3),
    with: [],
    dirs: [],
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--ci') options.ci = true;
    else if (arg === '--force') options.force = true;
    else if (arg === '--allow-stale') options.allowStale = true;
    else if (arg === '--concurrency' || arg === '--with') {
      const value = argv[i + 1];
      if (value === undefined) fail(`${arg} needs a value`);
      i += 1;
      if (arg === '--concurrency') options.concurrency = Number(value);
      else options.with.push(value);
    } else if (arg === '--help' || arg === '-h') {
      console.log(usage());
      process.exit(0);
    } else if (arg.startsWith('-')) fail(`unknown option ${arg}`);
    else options.dirs.push(arg);
  }
  if (!Number.isInteger(options.concurrency) || options.concurrency < 1) {
    fail('--concurrency and INSTALL_CONCURRENCY must be a whole number of at least 1');
  }
  if (options.dirs.length === 0) fail('give at least one folder');
  for (const dir of [...options.dirs, ...options.with]) {
    if (!fs.existsSync(path.join(dir, 'package.json'))) fail(`${dir} has no package.json`);
  }
  return options;
}

async function main(argv) {
  const options = parseArgs(argv);
  const queue = [...options.dirs];
  const parallel = options.concurrency > 1 && queue.length > 1;
  const label = (dir) => path.basename(path.resolve(dir)).replace(/^single-spa-/, '').replace(/-app$/, '');
  const counts = { installed: 0, adopted: 0, skipped: 0, stale: 0 };
  const failed = [];
  const worker = async () => {
    while (queue.length > 0) {
      const dir = queue.shift();
      try {
        counts[await ensureInstalled(dir, options, parallel ? label(dir) : null)] += 1;
      } catch (error) {
        failed.push(display(dir));
        console.error(`❌ ${error.message}`);
      }
    }
  };
  await Promise.all(Array.from({ length: Math.min(options.concurrency, queue.length) }, worker));
  console.log(`📊 Dependencies: ${counts.installed} installed, ${counts.adopted} adopted, `
    + `${counts.skipped} unchanged${counts.stale ? `, ${counts.stale} kept stale (install failed)` : ''}${failed.length ? `, ${failed.length} failed (${failed.join(', ')})` : ''}`);
  return failed.length ? 1 : 0;
}

module.exports = {
  ensureInstalled, ensureInstalledSync, fingerprint, decide, adoptionProblem, syncProblem,
};

if (require.main === module) {
  main(process.argv.slice(2)).then((code) => {
    process.exitCode = code;
  });
}
