# Development and installation

## Install the private preview

Download the three mod zip files from this repository's private `v0.1.0` prerelease and put them in your Factorio mods directory. Use Factorio **2.1.21** with Space Age enabled. Enable Yuoki, Engines and Yuoki Industries: Quinityn. Remove older simultaneous copies of the same mod/version if needed through the normal mod manager.

The dependency zips are unmodified builds of the user's pending 1.3.0 branches. They are provided privately for reproducibility; this does not publish, merge or change either upstream branch. Any original license files remain in their packages.

## Exact dependency revisions

| Dependency | Commit | Branch |
| --- | --- | --- |
| Yuoki 1.3.0 | `ce7918f2b252f2d79ba86b9ae05d991e7af1f261` | `codex/yuoki-1.3.0-factorio-2.1` |
| yi_engines 1.3.0 | `dd13f421f68010fd0180cda4fb9273f9b582198e` | `codex/engines-1.3.0-factorio-2.1` |
| Factorio + Space Age | 2.1.21, build 87673 | Official headless Linux archive |

Prepare dependency source checkouts using Python 3 and Git:

```sh
python3 tools/prepare_dependencies.py
```

The script creates isolated checkouts under `build/dependencies`, verifies their exact revisions, and refuses to overwrite a different or modified checkout. It does not patch source, edit an installed game, or change upstream branches.

Get the official test engine from [Factorio's 2.1.21 headless download](https://factorio.com/get-download/2.1.21/headless/linux64). Extract it to a development directory. This repository does not redistribute the game.

## Run the checks

```sh
python3 tools/test.py \
  --factorio /absolute/path/to/factorio/bin/x64/factorio \
  --dependencies build/dependencies
```

The runner creates isolated mod links and an isolated game write directory inside `build/test`. Engine invocations are sequential. It checks actual loading, prototype contracts, zero-inventory resource/technology closure, finite starting-stock cost, terrain on three seeds, native walking routes across 20 seed/setting combinations, independent generation controls and native runtime fixtures. It saves logs and temporary test maps under `build/test`.

The test harness is a separate test-only mod. It never ships in the playable zip. Native fixtures inject ingredients and power to isolate machinery, research and rocket behavior; the separate dependency and budget checks verify where the materials come from. Player landing uses a narrow facade because the headless API cannot create a LuaPlayer. These distinctions are recorded in [validation](validation.md).

## Build installable zips

```sh
python3 tools/package.py --dependencies build/dependencies
```

This produces the addon, Yuoki and Engines zip files plus `SHA256SUMS` under `build/dist`. Zip timestamps and ordering are deterministic. The addon package excludes tests, tooling, research docs and build output; those remain available in the repository. Both dependency packages retain their source, graphics and any upstream license files.

For the addon alone:

```sh
python3 tools/package.py
```

All development updates remain **0.1.0** until `main` is stable for the initial release. The existing `v0.1.0` prerelease is an earlier development snapshot. Build the desired branch with the commands above for current changes. Replace the previous `yuoki-quinityn_0.1.0.zip` when installing a new build; do not install multiple copies.

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
