# Repository administration

[Documentation index](../README.md)

## Intended access policy

Anyone may open an issue or submit a fork PR once the repository is public.
Only **jatmn and designated maintainers** may merge into `main`. On this
personal-account repository, grant collaborator/write access only to those
maintainers. Ordinary contributors use forks and need no write access.

GitHub personal repositories have an owner and collaborators; they do not
provide the separate organization `Maintain` role. Audit collaborators and
installed GitHub Apps with write access before opening the repository. No
additional collaborator is designated by this change; jatmn is the current
owner and sole maintainer. Add approved maintainers to CODEOWNERS as appropriate.
CODEOWNERS requests review and does not grant or restrict merge permission.

## Main protection: active

The repository became public on October 7, 2026. The
[Main branch protection ruleset](https://github.com/jatmn/yuoki-quinityn/rules/24691504)
is active, and the effective rules for `main` were verified through GitHub's API.
Its ID is `24691504`. Private-repository plan restrictions had previously blocked
activation; public visibility removed that limitation.

[`.github/main-ruleset.json`](../../.github/main-ruleset.json) is an importable
repository ruleset targeting only `refs/heads/main`. It requires PRs and resolved
review threads, blocks force pushes and deletion, and has **no bypass actors**,
including for administrators. Access permissions limit who can merge.

The required approval count is zero so the sole maintainer can merge their own
PRs. This matches the owner-driven review model in Codex Warp. It does not let
outside contributors merge their PRs. Review and validation are still maintainer
responsibilities. No required status-check names are configured. Lightweight CI
always reports its change-detection job, then skips unrelated validation jobs.
Do not use change detection alone as a required validation gate: success only
means the affected surfaces were identified. Enforcing the complete CI result
as a merge gate is a separate policy decision. Adding these workflows does not
change live protections or the ruleset JSON.

The JSON is the versioned policy; editing it does not change live settings.
For an authorized policy update, inspect the current rule and apply the reviewed
JSON from the repository root using an authenticated owner session:

```sh
gh api repos/jatmn/yuoki-quinityn/rulesets/24691504
gh api --method PUT repos/jatmn/yuoki-quinityn/rulesets/24691504 \
  --input .github/main-ruleset.json
```

Preserve other rulesets and avoid duplicate policies. If the rule has been
recreated, obtain its current ID from `gh api repos/jatmn/yuoki-quinityn/rulesets`
before updating it.

Verify the returned ID and effective rules, then audit access:

```sh
gh api repos/jatmn/yuoki-quinityn/rulesets/24691504
gh api repos/jatmn/yuoki-quinityn/rules/branches/main
gh api repos/jatmn/yuoki-quinityn/collaborators \
  --jq '.[] | {login, role_name, permissions}'
```

Confirm active enforcement, the exact `main` target, no bypass, and the PR,
force-push and deletion restrictions. Check that an outside fork PR can be
opened and that only the owner/maintainers have merge access. Do not test by
force-pushing or deleting `main`. Public visibility and rule activation are
separate operations, so avoid merging or pushing during that transition.

## Public preview and future releases

PR #3 merged the licensing and contributor preparation. The old `v0.1.0`
release listing is now a draft, with its original tag and assets retained for
maintainers. The replacement [public preview](https://github.com/jatmn/yuoki-quinityn/releases/tag/v0.1.0-preview.2)
includes current Quinityn license notices and the unchanged pinned dependency
packages with their own licenses. No Factorio game files are distributed.

For future releases:

1. Merge reviewed changes through the owner/maintainer workflow.
2. Review the Git history, tracked files, releases and attachments for material
   that should not become public. Existing ZIPs do not gain new license notices
   just because source changes are merged; rebuild release artifacts as needed.
3. Build from the intended release commit. Confirm `LICENSE`, `NOTICE` and
   `graphics/README.md` are present in the add-on zip and preserve each dependency's
   own license. Keep the Factorio engine and Space Age data outside releases.
4. Confirm public users can obtain the documented dependencies. Yuoki 1.3.0 and
   Engines 1.3.0 are released for Factorio 2.1 on the
   [Yuoki](https://mods.factorio.com/mod/Yuoki) and
   [Engines](https://mods.factorio.com/mod/yi_engines) Mod Portal listings. Keep
   current installation guidance distinct from pinned test revisions and
   historical preview bundles.
5. Verify branch protection as above and keep collaborator access limited to
   designated maintainers.
6. For a separately approved Mod Portal release, select CC BY-NC-SA 4.0 and link
   NOTICE for the third-party exceptions. Add genuine in-game screenshots after
   graphical playtesting; do not present concept art as gameplay.

Dependabot is intentionally not configured. The Python tools use the standard
library; Factorio, Space Age, Yuoki and Engines compatibility is maintained
through explicit versions and the existing engine-backed test suite.

## Reference policies and presentation research

- [Codex Warp contribution policy](https://github.com/jatmn/Codex-warp/blob/main/CONTRIBUTING.md)
  and [agent rules](https://github.com/jatmn/Codex-warp/blob/main/AGENTS.md): focused
  PRs, duplicate checks, local validation, Conventional Commits and review follow-up.
  Quinityn retains its own languages and validation tools.

The October 8, 2026 documentation pass revisited three widely downloaded planet
mods on the Mod Portal. Their presentation suggests useful patterns for Quinityn:

| Planet | Presentation pattern | Application here |
| --- | --- | --- |
| [Maraxsis](https://mods.factorio.com/mod/maraxsis) | Introduces a distinctive world, then shows its machines and logistics challenges | Lead with unicomp seas and explain what the player builds around them |
| [Cerys](https://mods.factorio.com/mod/Cerys-Moon-of-Fulgora) | Uses exploration, visual examples and recoverable ruins to connect atmosphere with a production puzzle | Connect buried machinery and salvage to rebuilding industry |
| [Muluna](https://mods.factorio.com/mod/planet-muluna) | Shows new entities and resources and explains the progression impact | Pair salvage/science art with concrete uses; explain physical landing and point to detailed guides |

The README restores the opening from the
[first tagline version](https://github.com/jatmn/yuoki-quinityn/blob/6ed1e485f074047247b5651794f5d2f184edcf97/README.md),
using original wording and verified Quinityn features. Keep the showcase focused
on the setting, challenge and rewards; put spawn curves, recipe ratios, full lore,
test records and release history in their linked documents. Creature screenshots
remain pending; follow the [capture guide](../contributing/screenshots.md) and
keep concept artwork visibly labeled.

GitHub references:
[personal repository permissions](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/repository-access-and-collaboration/permission-levels-for-a-personal-account-repository),
[available rules and plan requirements](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets).
