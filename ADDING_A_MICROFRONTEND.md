# Adding a New Microfrontend — Step-by-Step Guide

This document explains **how this repository wires a microfrontend into the single-spa
orchestrator**, then gives the exact recipe, the complete file checklist, and the gotchas
learned while adding `single-spa-solid-app` (the 13th app). Everything below was verified
against a real integration — the Solid app in this repo is the reference implementation.

> Useful trick for every step below: pick the most recently added app (`svelte`, or `solid`
> once you're adding the next one) and `grep -rn "svelte" <file>` to see every place that
> enumerates apps. The registration points below are the complete set, but grepping an
> existing app's name is the fastest way to find each site inside a file.

---

## Part 1 — How this app works

### Architecture in one paragraph

A **root orchestrator** (`single-spa-root/`, served on **port 8080**) owns the page. It loads
an import map (SystemJS) that tells the browser where every microfrontend's bundle lives,
registers each app with `single-spa`, and mounts/unmounts apps into dedicated `<div>`s as the
URL changes. The **layout app** renders the navbar/sidebar shell, the **auth app** handles
login, and each **feature app** (Angular, Vue, React, Svelte, Solid, vanilla, …) renders into
its own div when its route prefix matches and the user is authenticated. Apps never talk to
each other directly — shared data flows through a global `window.stateManager` (observable
state: `userState$`, `employees$`, `events$`, plus `emit()`).

### The lifecycle contract (the one rule that decides what can be an MFE)

Every microfrontend must be a **browser JavaScript bundle that exports three functions**:

```js
export function bootstrap() { /* one-time setup; usually a resolved promise */ }
export function mount(props) { /* render your UI into YOUR div */ }
export function unmount(props) { /* clean up completely; dispose listeners, clear the DOM */ }
```

The orchestrator calls `bootstrap` once, then `mount`/`unmount` every time the route enters
or leaves your prefix. Each app builds to a **UMD bundle** with webpack 4
(`libraryTarget: 'umd'`) so SystemJS can consume it in every mode. Framework adapters
(`single-spa-vue`, `single-spa-react`, `single-spa-angular`, …) exist to bridge this contract;
for simpler frameworks (vanilla, jQuery, Solid) you can hand-roll the three functions in
~30 lines — see `single-spa-solid-app/src/single-spa-solid-app.js`.

**Consequence:** anything that cannot export these three functions and render into a DOM
element cannot be an in-page microfrontend here. See
[Known incompatibilities](#part-5--known-incompatibilities--gotchas).

### The five deployment modes

`npm run switch-mode -- <local|npm|nexus|github|aws>` (see `scripts/switch-mode.js`) swaps
`single-spa-root/package.json` and `shared/package.json` with their variants
(`package-{mode}.json`) plus `.npmrc`. What changes between modes is **where bundles are
loaded from** — the module maps inside `single-spa-root/root-application-dynamic.js`:

| Mode | Bundle URL shape |
|---|---|
| `local` | `http://localhost:421X/<bundle>.js` (each app served by its own dev server) |
| `github` | `https://<user>.github.io/single-spa-<name>-app/<bundle>.js` (GitHub Pages) |
| `npm` | published tarballs resolved through an import-map fileMap |
| `nexus` | same, against a private Nexus registry |
| `aws` | `@<org>/<name>-app` from S3/CDN |

Important details:

- **`single-spa-root/root-application-dynamic.js` is the source of truth.** It sniffs the
  current hostname/mode at runtime and picks the matching module map. The file contains
  **nine module-map object literals** (LOCAL prod/dev, GitHub Pages + raw.githubusercontent
  fallback, AWS, npm fileMap, Nexus fileMap + URL ternary, plus a final localhost fallback) —
  **your app must be added to every one of them**, or the app only works in some modes.
- **`single-spa-root/root-application.js` is a stale prebuilt bundle. Never edit it.** It is
  regenerated from the dynamic file by the root build (`prod:build` / `run.sh`); if your
  registration doesn't show up, you edited the wrong file or didn't rebuild the root.
- The repo-root `package.json` is mode-independent (it's the 300+ script orchestrator);
  only `single-spa-root/` and `shared/` have mode variants. `shared/*` contains **no** app
  enumerations, so you never touch it when adding an app.

### Auth gating and shared state

Registration uses `showWhenAuthenticatedAndPrefix(['/<name>'])`, so your app is only mounted
for logged-in users. Log in with **admin / 12345** (the auth app stores the user via
`stateManager.setUser`, persisted in sessionStorage). From your app:

```js
const sm = window.stateManager;
sm.userState$.subscribe(...)    // current user (or null)
sm.employees$.subscribe(...)    // shared employee list (loaded from shared/employees.json)
sm.events$.subscribe(...)       // cross-app event bus
```

Always unsubscribe/dispose in `unmount()` — single-spa will mount your app again later and
duplicate subscriptions leak.

---

## Part 2 — The recipe (adding app `X` on port 421N, route `/x`)

Conventions used below: app directory name `single-spa-x-app`, bundle file
`single-spa-x-app.js`, UMD library global `singleSpaXApp`, port `421N` (next free port:
**4213**), route prefix `/x`, registration name `x`, package version **1.0.18** (all packages
in this repo are kept in lockstep — check any sibling's `package.json` and use that version).

### Step 1 — Create the app directory

Copy the closest sibling as a model: `single-spa-jquery-app` (simplest, no framework
adapter), `single-spa-svelte-app` (compiler-based framework), or `single-spa-solid-app`
(hand-rolled lifecycle + signals). You need five files:

**`single-spa-x-app/package.json`**
- `name`: `@cesarchamal/single-spa-x-app`, `version`: `1.0.18`,
  `main`: `dist/single-spa-x-app.js`
- scripts (copy from a sibling; note every build script carries
  `cross-env NODE_OPTIONS=--openssl-legacy-provider` because webpack 4 runs on Node 18):
  - `build` / `build:dev` / `build:prod` → webpack with the right `--mode`
  - `start` → `webpack serve --mode development --port 421N`
  - `serve` → build + `npx http-server dist -p 421N --cors`
  - `lint` → eslint (keep it tolerant; the root `lint:*` aggregates append `|| exit 0`)
- devDependencies: webpack `^4.41.5`, webpack-cli `^3.3.12`, webpack-dev-server `^3.11.0`,
  babel toolchain (+ your framework's compiler/preset), cross-env
- dependencies: your framework + `solid-js`-equivalent runtime only

**`single-spa-x-app/webpack.config.js`** — the two lines that matter:
```js
output: {
  filename: 'single-spa-x-app.js',
  library: 'singleSpaXApp',
  libraryTarget: 'umd',
  path: path.resolve(__dirname, 'dist'),
},
```
plus `optimization.splitChunks` / `LimitChunkCountPlugin` set to a single chunk (SystemJS
loads one file per app) and a babel-loader rule.

**`single-spa-x-app/src/single-spa-x-app.js`** — the lifecycle. Hand-rolled minimal shape
(real code: `single-spa-solid-app/src/single-spa-solid-app.js`):
```js
export const bootstrap = () => Promise.resolve();
export const mount = () => new Promise((resolve) => {
  const el = document.getElementById('x-app');
  if (!el) { console.error('#x-app not found'); return resolve(); }
  // render your framework into el, keep a dispose handle
  resolve();
});
export const unmount = () => new Promise((resolve) => {
  // dispose / empty the DOM you created
  resolve();
});
export default { bootstrap, mount, unmount };
```

**`single-spa-x-app/src/App.jsx`** (or `.js`/`.vue`/…) — your UI. House style: a title card
naming the framework + version, a short "why this framework" note, one interactive
reactivity demo, and a shared-state section subscribing to `window.stateManager`.

**`single-spa-x-app/README.md`** — every app has one, in the same shape: the full
13-row framework table with your row last and marked `**This repo**`, feature
snippets, lifecycle snippet, dev commands on `421N`. Model: the solid or svelte README.

### Step 2 — Mount point div

`single-spa-root/index.html` — next to the other app divs, in the same order as the navbar:

```html
<div id="x-app" class="spa-mount-point content-mount"></div>
```

The id must be exactly `{registration-name}-app` — that's what your `mount()` looks up.

### Step 3 — Module maps (all nine) + registration

In `single-spa-root/root-application-dynamic.js`:

1. Add an entry for `single-spa-x-app` to **every module-map literal**. Grep for the last
   app added (`'single-spa-svelte-app'` / `'single-spa-solid-app'`) and mirror each entry
   with your URL/bundle name:
   - LOCAL prod: `'/single-spa-x-app.js'` (served by the root static server)
   - LOCAL dev: `'http://localhost:421N/single-spa-x-app.js'`
   - GitHub Pages: `'https://${githubUser}.github.io/single-spa-x-app/single-spa-x-app.js'`
     and the raw.githubusercontent fallback variant
   - AWS: `'@' + AWS_CONFIG.orgName + '/x-app'`
   - npm & Nexus fileMaps: `'single-spa-x-app': 'single-spa-x-app.js'`
   - the Nexus prod/dev URL ternary and the final localhost fallback map
2. Register the app (append after the last app's block, keep the order consistent):
```js
singleSpa.registerApplication(
  'x',
  () => loadApp('single-spa-x-app'),
  showWhenAuthenticatedAndPrefix(['/x']),
);
```

### Step 4 — Navbar entry

`single-spa-layout-app/src/components/Navbar.vue` — copy the last `b-nav-item` block and
change the icon/label/route. Logos: `https://cdn.simpleicons.org/<slug>/<hex>` works well
(verify the URL with curl before committing — vendor sites hotlink-block or 429):

```html
<b-nav-item href="/x" v-on:click.prevent="navigateTo('/x')" class="nav-item-enhanced">
  <img src="https://cdn.simpleicons.org/x/2c4f7c" class="tech-icon" alt="X" />
  <span class="nav-text">X</span>
</b-nav-item>
```

Rebuild the layout app afterwards (`npm --prefix single-spa-layout-app run build`) or the
item won't appear if you're serving prebuilt bundles.

### Step 5 — Orchestrator scripts (repo-root `package.json`)

This file is mode-independent but enumerates every app ~18 times. For app `x` you need:

**Definition keys** (copy the svelte/solid twin and s/svelte/x/):
`install:x`, `install:x:ci`, `build:x`, `build:x:dev`, `build:x:prod`, `serve:x`,
`clean:x`, `publish:npm:x`, `publish:npm:x:{patch,minor,major}`,
`publish:nexus:x`, `publish:nexus:x:{patch,minor,major}`, `sync:s3:x`,
`deploy:github:x`, `trigger:x`.

**Aggregates that must gain a trailing `&& npm run …:x` (sequential) or `"npm run …:x"`
(concurrently, inside the `concurrently … -n NAME,…` name list too)**:
`install:apps`, `install:apps:ci`, `install:apps:concurrent`,
`install:apps:concurrent:ci`, `build`, `build:dev`, `build:prod`, `build:concurrent`,
`build:concurrent:dev`, `build:concurrent:prod`, `clean:apps`, `sync:s3:all`, and
`deploy:github:all` (insert yours **before** `deploy:github:root`, which must stay last —
the root import map is rebuilt from all apps).

Also add the framework name to the `keywords` array.

> Tip: with this many near-identical edits, scripted JSON surgery is safer than hand edits —
> `JSON.parse`, mutate the scripts object (preserving key order), `JSON.stringify(obj, null, 2)
> + '\n'`, and assert the exact tail of each aggregate before writing. A missed `&&` in one of
> 36 variants is invisible in review.

**Root app variants** — `single-spa-root/package.json` **and its five mode variants**
`package-{local,npm,nexus,github,aws}.json` must stay consistent. Each carries six
app-list aggregates: `lint:strict`, `lint:loose` (concurrently, both with `|| exit 0`),
`prod:build:apps` (sequential `&&`), `prod:build:apps:concurrently`, `dev:build:apps`
(`--watch` builders), `dev:serve:apps` (`npx http-server ../single-spa-x-app/dist -p 421N
-c-1 --cors` per app). `scripts/switch-mode.js` swaps this file per mode, so an app present
in `package.json` but missing from a variant breaks that whole mode.

**Trigger script** — `scripts/trigger-x.sh`: copy of `scripts/trigger-svelte.sh` (or
`trigger-solid.sh`) with the app name replaced; referenced by `trigger:x`. `chmod +x`.

### Step 6 — Launcher

`run.sh` (~line 610) — append to the `APPS` array:

```bash
APPS=("auth" "layout" "home" "angular" "vue" "react" "vanilla" "webcomponents" "typescript" "jquery" "svelte" "solid" "x")
```

This drives the `./run.sh github prod` deploy loop (`npm run deploy:github:x` for each app).
`run.sh`'s dependency install needs no change: it installs every `single-spa-*-app` folder
through `scripts/install-if-changed.js`, so name the folder `single-spa-x-app`. The Windows twin
`run.bat` has no `APPS` array: its dependency install also covers every `single-spa-*-app`
folder, and its build loops run off the root package.json scripts. It does have a hand-written `deploy:github:*` menu — add your `call npm run
deploy:github:x` line there too.

### Step 7 — CI workflows

- **`.github/workflows/deploy-x.yml`** — copy `deploy-svelte.yml` (or `deploy-solid.yml`)
  and change exactly five things: workflow `name:`, `paths:` trigger filter,
  `working-directory:`, `cache-dependency-path:`, and the final
  `../scripts/deploy.sh x-app single-spa-x-app.js '{}'` call. The workflows use Node
  18.20.8 and `rm -f package-lock.json` before install (lockfiles are not relied on in CI).
- **`.github/workflows/deploy-github-pages.yml`** — add a matrix entry (keep
  `single-spa-root` last):
  ```yaml
  - { name: "single-spa-x-app", bundle: "single-spa-x-app.js" }
  ```
  `scripts/update-importmap-github.mjs` is driven entirely by this matrix via env vars —
  no other change is needed for Pages deploys.
- **`.github/workflows/deploy-github-simple.yml`** — the "simple" GitHub mode loops
  over an app list inline: add the app to **both** `for app in …` loops and add one
  `./scripts/deploy-github.sh single-spa-x-app` call before the root deploy.

### Step 8 — Deployment helpers (scripts/)

**This is the step that was originally missed for Solid — the app worked locally but
never reached the S3 bucket.** Roughly 30 helper scripts (each with a `.bat` Windows
twin) hardcode the app list for aws/github/npm/nexus status checks, hot-sync,
publishing, dep-fixing, triggering, and version management. Every one needs the new
app, and several have non-obvious mechanics (importmap heredoc commas, `for /l` loop
bounds, indexed arrays where root must stay last, "N packages" counts). The full
file-by-file list lives in **Part 3 — Edit (deployment helpers)** below; work from
that checklist. Two ways to find anything you missed:

```bash
# every file that mentions the previous newest app but not yours is a miss:
grep -ril "svelte" --include="*.sh" --include="*.bat" --include="*.js" . | xargs grep -Li "solid"
```

and for npm/nexus serving, add one `express.static` route to
`single-spa-root/server.js` (Part 3 has the exact line).

### Step 9 — Documentation

Docs enumerate apps too; update them in the same commit:
- **`README.md`**: applications table row, project-structure tree, showcase matrix,
  routes list, framework list, port table, and every "N microfrontends"/"N apps" count.
- **`CLAUDE.md`**: the structure table + heading count, the port range line
  (`ports 4201-421N`), the framework list, and the "framework diversity" counts.
- **Every other app's `README.md`** (12+ files): each carries the full framework
  table — add your row to all of them.
- **`single-spa-root/NPM-PUBLISHING.md`** (importmap example), **`VERSION-MANAGEMENT.md`**
  and **`MODULE-FORMATS-COMPARISON.md`** (app counts).

### Step 10 — Install, build, verify

```bash
cd single-spa-x-app && npm install          # then check .bin shims if you're on WSL (see Part 5)
cd .. && npm run build:x                    # → dist/single-spa-x-app.js
# restart the stack (see Part 4), log in, click the new nav item
```

---

## Part 3 — Complete file checklist

Copy this when adding an app. It is grouped the way you should work: app first,
orchestration second, **deployment helpers third** — that last group is the one that
bit us: the Solid app shipped with every orchestration edit in place, but the
`scripts/` helpers were missed and `npm run deploy:aws:prod` exited 0 while silently
syncing only the 12 old apps to S3 (no `solid-app/` folder in the bucket, no
importmap entry). The helpers — not the npm scripts — are what actually touch
S3/npm/Nexus/GitHub. Treat this group as mandatory, not optional.

**Create (5 + 2 files)**
- [ ] `single-spa-x-app/package.json`
- [ ] `single-spa-x-app/webpack.config.js`
- [ ] `single-spa-x-app/src/single-spa-x-app.js` (lifecycle: bootstrap/mount/unmount)
- [ ] `single-spa-x-app/src/App.jsx` (UI + `window.stateManager` integration)
- [ ] `single-spa-x-app/README.md` (every app has one; framework table row marked
      `**This repo**`, all other apps listed with repo links)
- [ ] `scripts/trigger-x.sh` (copy of `trigger-svelte.sh`, `chmod +x`)
- [ ] `.github/workflows/deploy-x.yml` (copy of `deploy-svelte.yml`, 5-line diff)

**Edit — orchestration (9 files)**
- [ ] `single-spa-root/root-application-dynamic.js` — 9 module-map literals + 1
      `registerApplication` block
- [ ] `single-spa-root/index.html` — `<div id="x-app" class="spa-mount-point content-mount">`
- [ ] `single-spa-layout-app/src/components/Navbar.vue` — one `b-nav-item` block
- [ ] `package.json` (repo root) — ~18 definition keys, 13 aggregates, keywords, in order
- [ ] `single-spa-root/package.json` + `package-{local,npm,nexus,github,aws}.json` —
      6 aggregates each, values byte-identical across variants
- [ ] `run.sh` — `APPS=(… "x")`
- [ ] `.github/workflows/deploy-github-pages.yml` — matrix entry before `single-spa-root`
- [ ] `README.md` — table/tree/matrix/routes/frameworks/ports/counts
- [ ] `CLAUDE.md` — structure table/ports/framework list/counts

**Edit — deployment helpers (every one enumerates all apps; .sh and .bat twins must stay in sync)**

- [ ] `scripts/deploy-s3.sh` — **two spots**: the importmap heredoc entry (add a
      trailing comma to the entry that was last) **and** the `APPS=(… "x")` array.
      This is the script behind `npm run deploy:aws:prod`.
- [ ] `scripts/deploy-s3.bat` — same two spots (echo'd importmap inside the
      `( … ) > importmap.json` block + `set APPS=…`); a missing comma here corrupts
      importmap.json on Windows.
- [ ] `scripts/aws-hot-sync.sh` / `.bat` and `scripts/github-hot-sync.sh` / `.bat` —
      the `APPS[...]` / `set "APPS=…"` enumerations
- [ ] `scripts/check-aws-status.sh` / `.bat` — `APPS[...]` map (+ `for /l` bounds, below)
- [ ] `scripts/check-local-status.sh` / `.bat` — **two maps**: the port map
      `APPS["single-spa-x-app"]="421N"` and `BUNDLE_FILES["single-spa-x-app"]`
- [ ] `scripts/check-npm-status.sh` / `.bat`, `check-nexus-status.sh` / `.bat`,
      `check-github-status.sh` / `.bat` — package/repo maps. In the `.bat` variants
      the root entry must stay last: append the new app **before** root and shift
      root's array index (`apps[11]=…root` → `apps[12]=…root`).
- [ ] `scripts/fix-npm-deps.sh` / `.bat` and `scripts/fix-nexus-deps.sh` / `.bat` —
      one `sed` line per dependency-manifest target, **and** the `for app in …` list
- [ ] `scripts/publish-npm.sh` / `.bat` and `scripts/publish-nexus.sh` / `.bat` — the
      production `APPS` array (root last) and the "N packages" comments/echoes
      (12 → 13)
- [ ] `scripts/trigger-deploy-aws.sh` / `.bat`, `trigger-actions.sh` / `.bat`,
      `trigger-deploy-github.sh` — `APPS` arrays
- [ ] `scripts/version-manager.sh` / `.bat` — the usage `echo` line;
      `scripts/version-manager.js` — the `packages` array (add the trailing comma to
      the entry that was last)
- [ ] `single-spa-root/server.js` — one
      `app.use('/single-spa-x-app.js', express.static(path.resolve(__dirname, '../single-spa-x-app/dist/single-spa-x-app.js')))`
      route. Without it, npm/nexus modes 404 on the bundle when serving locally.
- [ ] `run.bat` — the `call npm run deploy:github:x` menu line (the Windows twin of
      the deploy:github family; `run.sh`'s `APPS` array covers the Linux side)
- [ ] `.github/workflows/deploy-github-simple.yml` — **two** `for app in …` loops
      gain the new app, **plus** one `./scripts/deploy-github.sh single-spa-x-app`
      call before the root deploy

**`.bat` loop bounds.** The batch status/hot-sync scripts iterate indexed arrays with
`for /l %%i in (0,1,N)` and a hardcoded `N`. Adding `apps[12]` without bumping `N`
from 11 to 12 makes the loop silently skip the new entry. Grep case-insensitively —
the flag is lowercase `/l`, which a case-sensitive `grep "for /L"` misses.

**Edit — docs beyond README/CLAUDE**
- [ ] every **other** app's `README.md` — each has a full framework table needing the
      new row (12+ files) and a "one of N microfrontends" count
- [ ] `single-spa-root/README.md` — table row + port bullet + counts
- [ ] `single-spa-root/NPM-PUBLISHING.md` — the importmap example entry
- [ ] `VERSION-MANAGEMENT.md` — "N microfrontends" counts
- [ ] `MODULE-FORMATS-COMPARISON.md` — app count

**No change needed** (verified): `shared/*` (no app enumerations),
`scripts/switch-mode.js` (generic), `scripts/deploy.sh` and `scripts/deploy-github.sh`
(parameterized — take the app name as an argument), `scripts/create-github-repo.sh`,
`scripts/setup-s3.sh`, `scripts/setup-cloudfront.sh`, `scripts/check-cdn-status.*`,
`scripts/download-offline-deps.*`, `scripts/auto-fix-mode.*`, `scripts/stop-github-server.*`,
`scripts/test-{npm,nexus}-auth.*`, `scripts/update-importmap-github.mjs` (env-driven
from the workflow matrix), `scripts/update-importmap.mjs`, `backup/*` (dead snapshots,
referenced by nothing), and `single-spa-root/root-application.js` (**stale prebuilt —
never hand-edit; rebuilt by the root build**).

**Finding them all**: `grep -ril "<previous newest app>" --include="*.sh" --include="*.bat" --include="*.js" --include="*.yml" .`
(svelte, in this case) lists every file that enumerates apps — anything that matches
but has no mention of your new app is a miss. Run it again after editing; the only
survivors should be the previous app's own files (its `trigger-svelte.sh`, its
workflow, its internal sources) and `backup/`.

---

## Part 4 — Verify your new app

1. **Build in isolation**: `npm run build:x` exits 0 and `dist/single-spa-x-app.js` exists;
   sanity-check the UMD export:
   ```bash
   grep -c "bootstrap" dist/single-spa-x-app.js   # lifecycle names present in the bundle
   ```
2. **Restart the full stack** (never `pkill` — it kills unrelated node/MCP processes; kill
   the launcher's process group instead, e.g. `kill -TERM -<PGID>`):
   ```bash
   setsid nohup ./run.sh local dev > /tmp/demo-microfrontends-run.log 2>&1 < /dev/null &
   ```
   Expect **all** app builds to exit 0 (a failure in your app's webpack config stops here).
3. **Ports**: `curl -s -o /dev/null -w '%{http_code}' http://localhost:8080` → 200, and the
   same for your port `421N` and every other app port (8080, 4201-421N).
4. **Browser**: open `http://localhost:8080`, log in (**admin / 12345**), click your navbar
   item (should sit after the previous app's). Your route renders inside the shell.
5. **Lifecycle hygiene**: open DevTools console; navigate to your route → your `mount` log;
   navigate away → your `unmount` log and `#x-app` is left empty. Navigate back → mounts
   cleanly again (no duplicated listeners, no leaked DOM). This validates your
   dispose/unsubscribe path.
6. **Shared state**: your app's user section shows the logged-in user; the employee section
   matches the other apps' lists.

---

## Part 5 — Known incompatibilities & gotchas

### What cannot be a microfrontend here

The lifecycle contract (Part 1) requires a browser bundle exporting
bootstrap/mount/unmount that renders into a div. That rules out:

- **Next.js** — no maintained single-spa adapter exists (`single-spa-nextjs` is dead/404;
  the single-spa maintainers closed the support request: Next.js insists on owning the
  HTML document and the server runtime). **Decision recorded in this repo: Next.js is not
  included.**
- **Any server-rendered backend stack — PHP, Django, Rails, ASP.NET, …** — they produce
  HTML on the server, not a mountable browser module. They *can* participate in the overall
  system only as (a) an **iframe** wrapped in a microfrontend, or (b) a **backend API**
  consumed by a JS app. Both were considered and declined for this demo — it exists to
  showcase in-DOM framework microfrontends.

Rule of thumb: **if it can't run as a plain `<script>`-loaded JS module that renders into a
div you don't own, it can't be an MFE.**

### Gotchas hit during the Solid integration

- **The helpers, not the npm scripts, do the deploying** — the single biggest miss of
  the Solid integration. All orchestration was wired correctly, but ~30 `scripts/`
  helpers still hardcoded the 12-app list. Symptom: `npm run deploy:aws:prod` exited 0
  and the S3 bucket had no `solid-app/` folder, because `scripts/deploy-s3.sh` (not the
  npm script) owns the importmap heredoc and the per-app sync loop. Nothing fails
  loudly — the new app is just silently absent from every non-local mode. Sweep with
  `grep -ril "svelte" --include="*.sh" --include="*.bat" --include="*.js" --include="*.yml" .`
  (Step 8) and see Part 3 for the full helper list.
- **`.bat` enumerations have three coupled parts**: the indexed array
  (`set "apps[12]=…"`), the loop bound (`for /l %%i in (0,1,12)`), and sometimes a
  "N packages" comment. Adding the array entry without bumping the bound makes the
  loop skip it silently. And the flag is lowercase `/l` — a case-sensitive
  `grep "for /L"` finds nothing.
- **JSON commas when appending**: in `deploy-s3.sh`'s importmap heredoc and
  `version-manager.js`'s package array, the previous last entry needs a trailing
  comma. Miss it and you corrupt importmap.json; glue the comma onto the wrong line
  and you break the heredoc.
- **webpack 4 + Node 18**: every build needs `NODE_OPTIONS=--openssl-legacy-provider`
  (already baked into the scripts — don't drop it when copying).
- **Modern packages vs webpack 4 resolution** (hit with `solid-js` 1.9): webpack 4 can't
  read a package's `exports` map, so bare `solid-js` / `solid-js/web` resolved to the
  **server** builds (`dist/server.js`) and the build failed on `seroval-plugins/web`.
  Additionally the browser dists ship optional chaining, which webpack 4's parser can't
  read. Fix in `single-spa-solid-app/webpack.config.js` (copy this pattern for any
  post-2020 framework):
  ```js
  resolve: {
    extensions: ['.js', '.jsx'],
    alias: {
      'solid-js/web': path.resolve(__dirname, 'node_modules/solid-js/web/dist/web.js'),
      'solid-js$': path.resolve(__dirname, 'node_modules/solid-js/dist/solid.js') // $ = exact match only
    }
  },
  module: {
    rules: [{
      test: /\.jsx?$/,
      exclude: /node_modules\/(?!(solid-js)\/)/,   // let babel transpile solid-js dists
      use: { loader: 'babel-loader', options: { presets: ['babel-preset-solid', '@babel/preset-env'] } }
    }]
  }
  ```
- **Never edit `single-spa-root/root-application.js`** — it's a stale prebuilt artifact of
  `root-application-dynamic.js`. Changes there silently do nothing once the root rebuilds.
- **Nine module maps, not one** — forgetting the npm/Nexus fileMaps or the AWS map makes the
  app work in `local` mode and 404 in others.
- **`deploy:github:root` must stay last** in `deploy:github:all` — it rebuilds the root
  import map after all apps deployed.
- **Mode variants must stay byte-identical in their app lists** —
  `single-spa-root/package-{local,npm,nexus,github,aws}.json` are swapped wholesale by
  `scripts/switch-mode.js`.
- **WSL (Windows mount) specifics**:
  - `/mnt/f` npm installs are slow (9p filesystem): a tiny app can take 5-15+ minutes.
    Silence ≠ hang — check `node_modules` growth before assuming it's stuck.
  - If `node_modules` was ever installed from Windows npm, the `.bin` shims are
    verbatim copies instead of symlinks and every `npm run` fails under WSL
    (`cross-env: Permission denied`-style). Fix: `npm rebuild` in that directory, or
    replace the shim files with symlinks.
  - Stop the stack by process group (`kill -TERM -<PGID>; sleep 3; kill -KILL -<PGID>`) —
    never `pkill -f node` (it will kill your MCP servers and unrelated editors).
- **Navbar/HTML changes need rebuilds**: `index.html` edits ship with the root app,
  Navbar.vue edits need the layout app rebuilt — `./run.sh local dev` handles both, but a
  standalone `serve:x` won't.
- **Version lockstep**: all 13 packages sit at the same version (1.0.18 today). Bump your
  new package to match; the `publish:*:{patch,minor,major}` scripts assume it.
- **Logo hotlinking**: verify icon URLs return 200 (simpleicons CDN is reliable;
  vendor sites often 301/429).
