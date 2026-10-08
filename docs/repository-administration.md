# Repository administration

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

## Main protection: prepared, not yet active

During public-release preparation, GitHub returned HTTP 403 for both rulesets
and branch protection: this private repository needs GitHub Pro or public
visibility to use the feature. Committing the JSON below **does not activate
protection**. Do not describe `main` as protected until live API readback confirms
it. The visibility change is a separate owner decision.

[`.github/main-ruleset.json`](../.github/main-ruleset.json) is an importable
repository ruleset targeting only `refs/heads/main`. It requires PRs and resolved
review threads, blocks force pushes and deletion, and has **no bypass actors**,
including for administrators. Access permissions limit who can merge.

The required approval count is zero so the sole maintainer can merge their own
PRs. This matches the owner-driven review model in Codex Warp. It does not let
outside contributors merge their PRs. Review and validation are still maintainer
responsibilities. No required status-check names are configured because this
repository has no PR CI workflow; inventing a check name would block all merges.

Once the account plan supports private rulesets, or immediately after an
explicitly authorized visibility change, apply the reviewed policy from the
repository root using an authenticated owner session:

```sh
gh api repos/jatmn/yuoki-quinityn/rulesets
gh api --method POST repos/jatmn/yuoki-quinityn/rulesets \
  --input .github/main-ruleset.json
```

First inspect the list. If `Main branch protection` already exists, inspect it
and use `PUT /repos/jatmn/yuoki-quinityn/rulesets/RULESET_ID` with the same input
to update that rule, rather than creating duplicates. Preserve other rulesets.
Alternatively import the JSON in Settings → Rules → Rulesets.

Verify the returned ID and effective rules, then audit access:

```sh
gh api repos/jatmn/yuoki-quinityn/rulesets/RULESET_ID
gh api repos/jatmn/yuoki-quinityn/rules/branches/main
gh api repos/jatmn/yuoki-quinityn/collaborators \
  --jq '.[] | {login, role_name, permissions}'
```

Confirm active enforcement, the exact `main` target, no bypass, and the PR,
force-push and deletion restrictions. Check that an outside fork PR can be
opened and that only the owner/maintainers have merge access. Do not test by
force-pushing or deleting `main`. Public visibility and rule activation are
separate operations, so avoid merging or pushing during that transition.

## Before the public release

1. Merge the reviewed preparation PR through the owner/maintainer workflow.
2. Review the Git history, tracked files, releases and attachments for material
   that should not become public. The existing `v0.1.0` prerelease contains
   older add-on and dependency zips: they do not gain the new Quinityn license
   files just because this PR is merged. Decide whether to replace or withdraw
   that snapshot before changing visibility.
3. Build from the intended release commit. Confirm `LICENSE`, `NOTICE` and
   `graphics/README.md` are present in the add-on zip and preserve each dependency's
   own license. Keep the Factorio engine and Space Age data outside releases.
4. Confirm public users can obtain the documented pinned dependencies. The
   README must continue to distinguish pending 2.1 builds from published 2.0 mods.
5. Change visibility only when authorized, then activate and verify protection
   as above. Keep collaborator access limited to designated maintainers.
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
- [Maraxsis](https://mods.factorio.com/mod/maraxsis): world introduction, distinctive
  logistics and a clear explanation of progression.
- [Tenebris](https://mods.factorio.com/mod/tenebris): a brief atmospheric hook,
  concrete challenges/rewards and an explicit work-in-progress notice.
- [Terra Palus](https://mods.factorio.com/mod/terrapalus): a strong environmental
  identity followed by a scannable feature list.

The Quinityn README uses those presentation patterns with its own wording and
verified features, existing inventory art and explicit preview limitations.

GitHub references:
[personal repository permissions](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/repository-access-and-collaboration/permission-levels-for-a-personal-account-repository),
[available rules and plan requirements](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets).
