# Contributing

Bug reports, translations, playtest feedback and focused pull requests are
welcome. Quinityn is direction-led: a change may be declined if it duplicates
work, changes the intended progression or adds more maintenance than the
project can support.

## Before starting

1. Search existing issues and open pull requests for overlap.
2. Read [README.md](README.md), [development](docs/development.md),
   [progression](docs/progression.md) and [validation](docs/validation.md).
3. Discuss major progression, balance, compatibility or tooling changes in an
   issue before implementing them. Keep ordinary fixes small and reviewable.
4. Fork the repository, create a topic branch and open a PR against `main`.
   Public contributors do not need collaborator access to submit a PR once
   the repository is public.

Only **jatmn and explicitly designated maintainers** may merge into `main`.
Contributor credit or a CODEOWNERS entry alone does not grant merge access.
The owner grants collaborator access only to designated maintainers; see
[repository administration](docs/repository-administration.md).

## What belongs here

- Reproducible gameplay fixes, save compatibility repairs and useful regression
  coverage.
- Clearer in-game guidance, documentation and translations using existing keys.
- Playtest reports with Factorio/mod versions, map seed, generation settings,
  steps, expected/actual results and a minimal mod list.
- Artwork with documented origins and compatible permissions.

Keep implementation in the existing Lua and Python standard-library tools.
Do not introduce a new language, framework, package dependency or automated
update service without prior discussion. Dependabot is intentionally absent;
game and mod compatibility is validated against explicit revisions.

## Validation before commits and PR updates

Run `git diff --check` for every change. Inspect the entire diff, including
prose, links, localization and asset attribution.

For documentation or repository-policy changes, check links and commands.
If package contents or licensing change, also run:

```sh
python3 tools/package.py
```

Inspect the resulting zip for the intended files and license notices. A
documentation-only change does not require a new Factorio engine run.

For Lua, gameplay, localization, runtime assets, dependency pins, or test-harness
changes, prepare the pinned dependencies and run the complete existing suite:

```sh
python3 tools/prepare_dependencies.py
python3 tools/test.py \
  --factorio /absolute/path/to/factorio/bin/x64/factorio \
  --dependencies build/dependencies
python3 tools/package.py --dependencies build/dependencies
```

Follow [development.md](docs/development.md) for the required engine and setup.
Use tests that prove the behavior and would fail without a bug fix; do not add
tests that only repeat the implementation. Report graphical playtesting
separately from headless checks and resource analysis. If you cannot run a
required check, state exactly why and leave the PR as a draft; a maintainer
must resolve the validation gap before merge.

Re-run affected checks after each update, before requesting review. Include
commands, versions and results in the PR; do not rely on CI as a substitute for
local validation. [Lightweight CI](docs/development.md#lightweight-ci) runs Lua,
Python, workflow and package checks only for affected surfaces. It never runs
Factorio or downloads the game/dependency mods. The local gameplay checks above
remain required for their applicable changes.

For added or modified Lua files, use StyLua 2.5.2 with the root `.stylua.toml`,
then run `stylua --check` on those files. The repository-wide formatting baseline
is complete. PR CI checks syntax, Luacheck and formatting only on changed Lua
files. After merge, pushes to `main` check all tracked Lua files when the Lua
surface changes, including lint or formatter configuration changes.
Leave unrelated Lua files untouched during ordinary work.

## Pull requests and follow-up

Explain the problem, resulting behavior and validation. Link related issues and
confirm that you checked for duplicate PRs. Use a Conventional Commit title:
`fix(progression): preserve existing unlocks`, `docs: clarify installation`, or
`feat(locale): add a translation`. See [AGENTS.md](AGENTS.md) for agent rules.

Keep changes focused. Do not bump `info.json` or publish a release as part of
ordinary contribution work. Release Please proposes maintainer release PRs,
starting at 0.1.1. In each normal PR, update the top `Version: Unreleased`
section in `changelog.txt` with player-facing notes, creating it if absent and
preserving numbered history. Automation assigns its version and date; do not
add CI-only details. See [the release guide](docs/releases.md).
Never include credentials, private logs, player
data, game binaries or local machine paths in commits.

Stay available for follow-up. PRs without a response for one week after review
feedback may be closed as abandoned. If you return later, ask to reopen the PR
or submit a fresh one.

## Licensing contributions

Submit only work you have permission to contribute under [LICENSE](LICENSE)
and the third-party exceptions in [NOTICE](NOTICE). Preserve upstream credit,
license notices and modification history. Identify the source, author, license
and changes for borrowed material; document generated artwork and its
references in [graphics/README.md](graphics/README.md). Do not treat publicly
visible assets as automatically free to reuse.
