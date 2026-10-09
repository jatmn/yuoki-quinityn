# Development and installation

## Install a development preview

Use Factorio **2.1.21** with Space Age enabled. Install **Yuoki 1.3.0** and **yi_engines 1.3.0** through the in-game mod manager or their released Mod Portal downloads: [Yuoki Industries](https://mods.factorio.com/mod/Yuoki) and [Engines](https://mods.factorio.com/mod/yi_engines). Both releases target Factorio 2.1; the older 2.0 releases are not substitutes.

Build the current Quinityn source with `python3 tools/package.py`, or download its ZIP from the [public preview](https://github.com/jatmn/yuoki-quinityn/releases/tag/v0.1.0-preview.2). Put the Quinityn ZIP in your Factorio mods directory and enable Yuoki, Engines and Yuoki Industries: Quinityn. Remove older simultaneous copies of the same mod/version if needed through the normal mod manager.

The public preview also retains its original dependency ZIPs, built from the historical source revisions recorded in the [README](../README.md#get-started). Use the released dependencies above for installation. Rebuilding dependencies is only needed to reproduce the pinned source baseline below. Original license files remain in source-built packages; Quinityn's preview includes its license and attribution notices.

## Exact dependency revisions

These immutable source revisions remain the recorded engine-test baseline.
They are not a claim that the published Mod Portal ZIPs were tested byte for
byte. Both dependencies are released; their former development branches are
not installation prerequisites.

| Dependency | Commit | Purpose |
| --- | --- | --- |
| Yuoki 1.3.0 | `c865cf05d5009d7f2224b32900272d4b1f012f21` | Reproducible source tests/builds |
| yi_engines 1.3.0 | `dd13f421f68010fd0180cda4fb9273f9b582198e` | Reproducible source tests/builds |
| Factorio + Space Age | 2.1.21, build 87673 | Official headless Linux archive |

Prepare dependency source checkouts using Python 3 and Git:

```sh
python3 tools/prepare_dependencies.py
```

The script creates isolated checkouts under `build/dependencies`, verifies their exact revisions, and refuses to overwrite a different or modified checkout. It does not patch source, edit an installed game, or change upstream branches.

The Yuoki pin includes the merged Factorio 2.1 port and adjustable-inserter
cleanup setting. If an older pin is already prepared, pass `--directory` with
a new empty directory and use it for the test/package `--dependencies` argument.
The published preview still bundles the older Yuoki source build; it does not
track later source or Mod Portal releases.

Get the official test engine from [Factorio's 2.1.21 headless download](https://factorio.com/get-download/2.1.21/headless/linux64). Extract it to a development directory. This repository does not redistribute the game.

## Run the checks

```sh
python3 tools/test.py \
  --factorio /absolute/path/to/factorio/bin/x64/factorio \
  --dependencies build/dependencies
```

The runner creates isolated mod links and an isolated game write directory inside `build/test`. Engine invocations are sequential. It checks actual loading, prototype contracts, zero-inventory resource/technology closure, finite starting-stock cost, terrain on three seeds, native walking routes across 20 seed/setting combinations, independent generation controls, native crafting milestones, ordinary-rock isolation on all planets, Quinityn flyash discovery, unfiltered/filtered Fatmice operation, alternate rocket fuel and runtime fixtures. It saves logs and temporary test maps under `build/test`.

The test harness is a separate test-only mod. It never ships in the playable zip. Native fixtures inject ingredients and power to isolate machinery, research and rocket behavior; the separate dependency and budget checks verify where the materials come from. Player landing uses a narrow facade because the headless API cannot create a LuaPlayer. These distinctions are recorded in [validation](validation.md).

The enemy fixture uses flat arenas on Nauvis and Quinityn to check native nest
offspring, the engine's colony-building command and laser damage for all enemy
sizes. It also fires capture rockets using normal enemy targeting at both native
and contaminated nests on Quinityn, checking ammunition use and captive ownership.
Natural generation and planet isolation remain covered by map-control
samples. This does not simulate the autonomous expansion timer or render sprites.

The inserter fixture uses Yuoki's real `yuoki-inserter-cleanup` setting and all
eight affected recipes. A detection-only `bobinserters` stub activates the
setting; it does not simulate recipe visibility or prove Bob's adjustment UI.
Checks cover cleanup off/on, saved-game toggles in both directions and removal
of the supported mod, for researched and unresearched forces. Ordinary inserters,
recycling unlocks, completed research and unrelated recipe state are preserved.

## Build installable zips

```sh
python3 tools/package.py --dependencies build/dependencies
```

This produces the addon, Yuoki and Engines zip files plus `SHA256SUMS` under `build/dist`. Zip timestamps and ordering are deterministic. The addon package includes `LICENSE`, `NOTICE` and artwork provenance, and excludes tests, tooling, research docs, contributor/agent instructions, GitHub configuration and build output; those remain available in the repository. Both dependency packages retain their source, graphics and upstream license files. See [CONTRIBUTING.md](../CONTRIBUTING.md) for change-specific validation and [repository administration](repository-administration.md) for public-release preparation.

For the addon alone:

```sh
python3 tools/package.py
```

Ordinary development keeps the last stable mod version. Release Please starts
with **0.1.1**. Write player-facing notes in `changelog.txt`'s `Unreleased`
section in each contribution PR; the release workflow assigns version/date
headers automatically. Development packages turn pending notes into a numeric
upcoming-patch section without changing tracked source files.
GitHub-only nightlies use the upcoming patch version and require replacing
earlier snapshots of the same version. See [releases and nightlies](releases.md)
for the version policy, credentials, publication and retries. The historical
`v0.1.0-preview.2` tag and its 0.1.0 mod ZIP remain unchanged.

## Lightweight CI

CI runs on pull requests and pushes to `main`. One small `changes` job reads the
complete Git diff, then invokes only the affected reusable validation workflows.
This avoids GitHub's capped file list for event-level path filters. Unrelated
validation jobs do not start runners; docs-only PRs pay only for change detection.
Topic branch pushes do not trigger duplicate runs, and a new update cancels the
superseded CI run for that PR. No CI job downloads or runs Factorio, Space Age,
Yuoki or Engines; engine validation remains local.

| Changed surface | Checks that run |
| --- | --- |
| Runtime Lua | Lua syntax, Luacheck, StyLua; addon packaging |
| Test-only Lua | Lua checks only |
| Python outside packaging tools | Python syntax only; no game tests execute |
| `tools/package.py` or `tools/validate_package.py` | Python syntax and packaging |
| `info.json`, locale, graphics, other shipped files | Metadata and package validation |
| `.luacheckrc` or `.stylua.toml` | Lua checks only |
| One validation workflow file | actionlint plus the workflow being changed |
| Dispatcher (`ci.yml`) or `tools/ci_changes.py` | All four validation workflows |
| Release configuration/version records or release workflows | Python release tests and package validation; actionlint for workflows |
| `docs/`, `AGENTS.md`, `CONTRIBUTING.md` | Change detection only |

The README, changelog, license files and `graphics/README.md` ship in the addon,
so changes to them trigger packaging. A mixed change runs the union of its
affected checks. The router disables rename detection so both the old and new
paths are considered; deletions also select their affected checks. An unavailable
comparison revision fails the routing job instead of silently skipping validation.
On pull requests, Lua syntax, lint and formatting check only added, modified or
renamed Lua files, including changes between regular files and symlinks; deleted
files are excluded. After merge, a push to `main` checks all
tracked Lua files when the Lua surface changes, including lint or formatter
configuration changes. Configuration is parsed even when a PR changes no Lua
files. The one-time repository-wide formatting baseline from
[issue #9](https://github.com/jatmn/yuoki-quinityn/issues/9) is complete; ordinary
PRs should leave unrelated Lua files untouched.

The Lua workflow uses Lua 5.2 syntax, Luacheck 1.2.0 and StyLua 2.5.2. Factorio
data/runtime globals are declared separately in `.luacheckrc`; line length is
left to StyLua. The intentional empty heavy-oil opt-out in `data-final-fixes.lua`
retains a file-local exemption; its unused bridge-loop index now uses `_` and
needs no exemption.

Run the same checks locally from the repository root:

```sh
# Replace these paths with the Lua files you changed. Format before checking.
luac5.2 -p .luacheckrc
luac5.2 -p control.lua
luacheck control.lua
stylua --config-path .stylua.toml control.lua
stylua --check --config-path .stylua.toml control.lua
actionlint
python3 tools/package.py
python3 tools/validate_package.py
```

For the full Lua baseline check used after merge:

```sh
git ls-files -z '*.lua' | xargs -0 -r -n1 luac5.2 -p
git ls-files -z '*.lua' | xargs -0 -r luacheck --
git ls-files -z '*.lua' | xargs -0 -r stylua --check --config-path .stylua.toml --
```

The Python syntax step parses tracked `.py` files without importing or running them. Package
validation checks metadata, the versioned ZIP root, every tracked release file
and its bytes, required entrypoints/notices, developer-file exclusions and the
SHA256 checksum. It also validates Factorio changelog formatting and matching
version records. Python CI runs `python3 tools/test_releases.py` for release
packages and simulated portal upload responses. The addon ZIP/checksum is
attached to its validation workflow run for seven days; publishing is handled
by the separate release/nightly workflows. These checks do not prove game API usage,
recipe correctness, graphics rendering or gameplay.

Python CI also runs `python3 tools/test_ci_changes.py`, a standard-library CI
regression suite. It checks surface isolation and the real Git-to-router path
with 3,500 documentation files followed by a Lua change, plus cross-surface
renames, deletions, unusual filenames and an invalid comparison revision.
Lua CI runs its focused file-selection case so workflow-only changes also check
both directions of regular-file/symlink changes without scanning untouched Lua.

## Source layout

- `prototypes/planet.lua`: planet, navigation route, wasteland terrain, unicomp sea and generation controls.
- `prototypes/production.lua`: bootstrap, science, foundations and orbital recipes.
- `prototypes/technology.lua`: finite and infinite research.
- `prototypes/research-tiers.lua`: explicit production upgrades, their prerequisites, representative icons and recipe assignments.
- `prototypes/recipe-stages.lua`: upstream recipe ownership and progression families.
- `data-final-fixes.lua`: final visit gates, preservation of prior unlock requirements and foundation compatibility.
- `scripts/progression.lua`: physical arrival, research bridges, configuration reconciliation and limited starter patches.
- `prototypes/tips.lua` and `locale/en/quinityn.cfg`: native in-game progression guide.
- `tests/`: engine-backed contract tests and bootstrap analysis.
- `docs/research.md`: historical sources, lore and adaptation boundaries.

The addon references installed dependency/Space Age art rather than copying it. Planet/world graphics reuse and tint existing assets. Original salvage and science icons are included under `graphics/icons`; their prompts and references are recorded in `graphics/README.md`. The mod has English localization; other languages can add the same localization keys.
