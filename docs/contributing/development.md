# Development and installation

[Documentation index](../README.md)

## Install a development preview

For player installation, required versions and existing saves, start with
[Getting started](../guides/getting-started.md). The steps below reproduce the
source baseline and build the mod from this repository. Run commands from the
repository root.

## Exact dependency revisions

These immutable source revisions remain the recorded engine-test baseline.
They are not a claim that the published Mod Portal ZIPs were tested byte for
byte. Both dependencies are released; their former development branches are
not installation prerequisites.

| Dependency | Commit | Purpose |
| --- | --- | --- |
| Yuoki 1.3.1 | `bafe79d0278afc61e0a2ccfc52905bba7bf5fffe` | Reproducible source tests/builds |
| yi_engines 1.3.1 | `3fc8761858e6d8d592ec1978ca51f7a57d44e882` | Reproducible source tests/builds |
| Factorio + Space Age | 2.1.24, build 87808 | Official headless Linux archive |

Prepare dependency source checkouts using Python 3 and Git:

```sh
python3 tools/prepare_dependencies.py
```

The script creates isolated checkouts under `build/dependencies`, verifies their exact revisions, and refuses to overwrite a different or modified checkout. It does not patch source, edit an installed game, or change upstream branches.

Both pins are the tagged 1.3.1 releases, which include the Factorio 2.1.24
compatibility fixes and Yuoki's adjustable-inserter cleanup setting. If an
older pin is already prepared, pass `--directory` with a new empty directory
and use it for the test/package `--dependencies` argument.
The published preview still bundles the older Yuoki source build; it does not
track later source or Mod Portal releases.

Get the official test engine from [Factorio's 2.1.24 headless download](https://factorio.com/get-download/2.1.24/headless/linux64). Extract it to a development directory. This repository does not redistribute the game.

## Run the checks

```sh
python3 tools/test.py \
  --factorio /absolute/path/to/factorio/bin/x64/factorio \
  --dependencies build/dependencies
```

The runner creates isolated mod links and an isolated game write directory inside `build/test`. Engine invocations are sequential. It checks actual loading, that the engine uses every field of Quinityn's own prototypes (`--check-unused-prototype-data`), prototype contracts, zero-inventory resource/technology closure, finite starting-stock cost, terrain on three seeds, native walking routes across 20 seed/setting combinations, independent generation controls, native crafting milestones, ordinary-rock isolation on all planets, Quinityn flyash discovery, unfiltered/filtered Fatmice operation, alternate rocket fuel and runtime fixtures. It saves logs and temporary test maps under `build/test`.

The test harness is a separate test-only mod. It never ships in the playable zip. Native fixtures inject ingredients and power to isolate machinery, research and rocket behavior; the separate dependency and budget checks verify where the materials come from. Player landing uses a narrow facade because the headless API cannot create a LuaPlayer. These distinctions are recorded in [validation](validation.md).

For Transport Drones compatibility, prepare an unmodified checkout of
[`Klonan/Transport_Drones`](https://github.com/Klonan/Transport_Drones) at
`c5d0ce2b1238d7f13373826979539d002be1168f` (2.1.4), then add
`--transport-drones /absolute/path/to/Transport_Drones` to the command above.
The focused check can also run via `tools/test_transport_drones.py` with the
same engine, dependency and Transport Drones arguments. It compares every
generated helper field against a control with Quinityn's final rewrite absent,
retaining its local items in both loads. It checks zero Quinityn helper unlocks,
native selection, requester/buffer item and fluid delivery before Trade/Engines,
and reloads a save with reconstructed legacy helper gates. Both default fuel and
Yuoki hydrogen fuel settings are covered. Roads, drones and stock are injected;
this is headless integration evidence, not a graphical or progression playthrough.
Each focused invocation creates and prints a unique directory under `--output`
(default `build/transport-drones`), retaining logs and saves there. Repeated or
concurrent focused runs use separate files, including legacy-save fixtures.

The enemy fixture uses flat arenas on Nauvis and Quinityn to check native nest
offspring, the engine's colony-building command and laser damage for all enemy
sizes. It also fires capture rockets using normal enemy targeting at both native
and Uni-touched nests on Quinityn, checking ammunition use and captive ownership.
Natural generation and planet isolation remain covered by map-control
samples. This does not simulate the autonomous expansion timer or render sprites.

The Stomp-a-tron fixture checks native nest spawning at 0%, 45%, 80% and 100%
evolution, both nest types, actual death loot and laser damage. Quinityn nests
are also deliberately placed on all five other built-in planets to exercise
the off-planet spawn guard. Prototype checks cover the full evolution curves,
half-size body/leg geometry and referenced attack/death effects, including the
absence of wrigglers, mineable egg shells and Gleba nest construction. These
flat-arena fixtures do not establish graphical fidelity or combat balance.

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

This produces the addon, Yuoki and Engines zip files plus `SHA256SUMS` under `build/dist`. Zip timestamps and ordering are deterministic. The addon package includes `LICENSE`, `NOTICE` and artwork provenance, and excludes tests, tooling, research docs, contributor/agent instructions, GitHub configuration and build output; those remain available in the repository. Release and nightly ZIPs also exclude the full-resolution README landscape (`graphics/quinityn-landscape.png`); the mod thumbnail and in-game graphics are included. Both dependency packages retain their source, graphics and upstream license files. See [CONTRIBUTING.md](../../CONTRIBUTING.md) for change-specific validation and the [release guide](../maintainers/releases.md#publication-checks) for publication checks.

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
earlier snapshots of the same version. See [releases and nightlies](../maintainers/releases.md)
for the version policy, credentials, publication and retries. The historical
`v0.1.0-preview.2` tag and its 0.1.0 mod ZIP remain unchanged.

## Lightweight CI

CI runs on pull requests and pushes to `main`. One small `changes` job reads the
complete Git diff, then invokes only the affected reusable validation workflows.
This avoids GitHub's capped file list for event-level path filters. Unrelated
validation jobs do not start runners; docs-only PRs pay only for change detection.
Topic branch pushes do not trigger duplicate runs, and a new update cancels the
superseded CI run for that PR; each push to `main` has its own concurrency group,
so a later documentation-only push cannot cancel an earlier push's full Lua checks.
The router is loaded from the comparison revision, so a PR that edits it cannot
disable its own validation. A final `CI result` job always runs and fails if any
selected check failed or was cancelled; it is the stable check name to require in
branch rules. No CI job downloads or runs Factorio, Space Age, Yuoki or Engines;
engine validation remains local. This CI matches the other Yuoki mod repositories.

| Changed surface | Checks that run |
| --- | --- |
| Runtime Lua | Lua syntax, Luacheck, StyLua; addon packaging |
| Test-only Lua | Lua checks only |
| Python outside packaging tools, or `.ruff.toml` | Python syntax, Ruff lint and CI/release regressions; no game tests execute |
| `tools/package.py` or `tools/validate_package.py` | Python syntax, Ruff lint, regressions and packaging |
| `info.json`, locale, graphics, other shipped files | Metadata and package validation |
| `.luacheckrc` or `.stylua.toml` | Lua checks on every tracked Lua file |
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
files are excluded. The exception is PRs that change `.luacheckrc`, `.stylua.toml` or
`.github/workflows/lua.yml`: they check all tracked Lua files, so lint, formatter or
tool-version changes are validated against the baseline before merge. After merge,
a push to `main` checks all tracked Lua files when the Lua surface changes. Configuration is parsed even when a PR changes no Lua
files. The one-time repository-wide formatting baseline from
[issue #9](https://github.com/jatmn/yuoki-quinityn/issues/9) is complete; ordinary
PRs should leave unrelated Lua files untouched.

The Lua workflow uses Lua 5.2 syntax, Luacheck 1.2.0 and StyLua 2.5.2, as separate
**Lua / Luacheck** (syntax and lint) and **Lua / StyLua** (formatting) checks. Factorio
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
git ls-files -z -- '*.py' | xargs -0 -r ruff check --config .ruff.toml --
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

The Python syntax step parses tracked `.py` files without importing or running them.
Ruff 0.17.3 then lints them with the shared correctness-only `.ruff.toml` (E9 syntax
errors and Pyflakes: undefined names, unused imports/variables; no style rules). Package
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
It also proves that an edited router cannot disable its own checks, that
configuration-only PRs select every Lua file, and that the file-selection step
shared by the Luacheck and StyLua jobs stays identical. Lua CI runs the focused
file-selection and compiler cases, including filenames beginning with `-`.

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
- `docs/lore/research.md`: historical sources, lore and adaptation boundaries.

The addon references installed dependency/Space Age art rather than copying it. Planet/world graphics reuse and tint existing assets. Original salvage and science icons are included under `graphics/icons`; their prompts and references are recorded in [graphics/README.md](../../graphics/README.md). The mod has English localization; other languages can add the same localization keys.
