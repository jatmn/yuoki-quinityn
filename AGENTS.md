# Agent guidance

Read [CONTRIBUTING.md](CONTRIBUTING.md) before making changes. Its validation,
scope, licensing and review rules also apply to coding agents.

## Project and source ownership

Quinityn is a Factorio 2.1 + Space Age planet add-on for Yuoki Industries and
Engines. Keep changes in the existing Lua prototypes/runtime and Python
standard-library tooling. Use [docs/contributing/development.md](docs/contributing/development.md) for
the source map, pinned dependencies, engine tests and packaging commands.

- `prototypes/planet.lua`: terrain, resources, route and generation controls.
- `prototypes/production.lua`, `technology.lua`, `research-tiers.lua` and
  `recipe-stages.lua`: production and research ownership.
- `data-final-fixes.lua`: final recipe gates and foundation compatibility.
- `scripts/progression.lua`: physical arrivals, force-wide progress and saves.
- `prototypes/tips.lua` and `locale/en/quinityn.cfg`: player-facing guidance.
- `tests/` and `tools/`: existing engine-backed checks and release packaging.

## Keep the gameplay contract intact

- Distinguish researching discovery, physically landing and remote viewing.
  Do not grant visit-gated recipes to another force or an unlanded character.
- Preserve researched technologies, existing entities and generated terrain
  unless a requested migration explicitly changes them.
- Retain the empty-inventory route to water, power, science and local rockets.
  Check both recipe reachability and finite starting-resource cost.
- Keep planet-specific generation controls and recipe restrictions local.
  Preserve upstream opt-outs and existing unlock requirements.
- Reference installed upstream assets rather than copying game files. Read
  [NOTICE](NOTICE) before changing artwork or licensing.
- Separate established Yuoki lore from this add-on's interpretation.

## Work and validation

Search existing issues/PRs first. Make the smallest coherent change for the
requested behavior; avoid unrelated refactors and new tooling. Use
`apply_patch` for manual edits. Do not alter pinned dependency sources to make
a test pass.

Before a commit, PR submission or PR-update push, run the applicable checks in
[CONTRIBUTING.md](CONTRIBUTING.md#validation-before-commits-and-pr-updates).
Review every changed hunk, affected contracts, spelling and localization.
Re-run affected checks after repairs. Do not weaken assertions or claim an
engine fixture, injected resources or a player facade proves a full playthrough.
For changed gameplay, report the actual engine/dependency versions and any
remaining graphical-client validation.

Format every added or modified Lua file with StyLua **2.5.2**, using the root
`.stylua.toml`, before committing. Run `stylua --check` on those files afterward.
The repository-wide formatting baseline is complete. PR CI checks only changed
Lua files; pushes to `main` check all tracked Lua files when the Lua surface
changes. Do not reformat untouched files as incidental cleanup.
See [development](docs/contributing/development.md#lightweight-ci)
for the lint commands and which changes trigger each workflow.

Do not add new languages, dependency managers, CI frameworks or Dependabot as
incidental cleanup. Do not add tests for prose or tests that mirror code just
to increase counts. Keep credentials, local paths, engine binaries, test saves
and generated build output out of Git.

## Commits and authority

Use a Conventional Commit subject (`feat`, `fix`, `perf`, `refactor`, `docs`,
`test`, `build`, `ci`, `chore`, or `revert`, with an optional scope) and a body
describing the behavior and validation. Use the same format for PR titles.
Do not increment `info.json` or publish/tag a release in ordinary contribution
work. Maintainer release PRs use [the release workflow](docs/maintainers/releases.md);
Release Please updates versions and GitHub notes. Add player-facing notes to
the top `Version: Unreleased` section of `changelog.txt` in each normal PR;
create that section when absent, without editing numbered history or adding a
date. The release workflow assigns version/date headers automatically. Omit
CI-only details from the player changelog.

Work on a topic branch and submit reviewable PRs. Only jatmn and designated
maintainers merge to `main`. Do not merge, change visibility, alter live branch
protections or publish to the Mod Portal without explicit authorization.
CODEOWNERS requests review; it is not an access-control mechanism.
