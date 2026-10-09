# Creature screenshots

[Documentation index](../README.md) · [Enemy field guide](../guides/enemies.md)

## Capture status

The enemy thumbnail gallery is **not yet captured**. The documentation pass
had access to Factorio 2.1.21 headless, which includes the gameplay definitions
but no sprite images or graphical renderer. These instructions are a capture
plan, not a record of a completed graphical test. Do not substitute the
landscape concept or AI creature concepts for screenshots of the mod.

## Prepare a capture save

Use the **graphical Factorio 2.1.21 client with Space Age**, the
[pinned dependencies](development.md#exact-dependency-revisions) and the current
Quinityn source. The historical preview predates the new creatures. Record
the Quinityn commit, dependency versions and map seed with the resulting images.

Create a disposable test save and generate a fresh Quinityn surface. Use the
map editor's surface and entity tools to arrange the exact Uni-touched
prototypes on a clear patch of Quinityn terrain. Keep this separate from a
normal playthrough: editor placement demonstrates appearance, not natural
spawn frequency or combat balance.

| Shot | Subjects | Caption focus |
| --- | --- | --- |
| Biters | Small, medium, big and behemoth Uni-touched biters | Royal-violet shades and size progression |
| Spitters | All four Uni-touched spitter sizes | Ranged attackers and distinct silhouettes |
| Colony | Uni-touched biter/spitter nests and worms | Brown-slag habitat; distinguish the two nests |
| Stomp-a-trons | Small, medium and big together | Five legs, Spidertron bodies, yellow sensors and blue-to-purple progression |

The entity IDs are `quinityn-<size>-biter`, `quinityn-<size>-spitter`,
`quinityn-<size>-worm-turret`, `quinityn-biter-spawner`,
`quinityn-spitter-spawner` and `quinityn-<size>-stomp-a-tron`.
Stomp-a-trons have small, medium and big sizes; the other size families also
have behemoths. Use the same zoom within each size comparison.

## Capture and inspect

Use Factorio's built-in `/screenshot` command in the graphical client. Frame
each group with room around the legs and shadows, hide the interface, move the
cursor off the subjects and keep daylight consistent. Images are written to
`script-output` in Factorio's [user-data directory](https://wiki.factorio.com/Application_directory).
The [console reference](https://wiki.factorio.com/Console#Normal_commands)
documents screenshot resolution and zoom arguments.

Inspect the full-size captures before making thumbnails. Check body/leg
alignment, all five Stomp-a-tron legs, sensor visibility, violet shading and
silhouette readability. Also inspect movement in the client; a still image
does not prove animation quality. Do not paint over a rendering defect.

Keep full-size images and a 320-pixel-wide thumbnail for each shot under
`docs/images/enemies/`. This directory is for the future captures and is not
populated by this documentation pass. Link each thumbnail to its full-size
image in the field guide, then feature a compact selection under the README's
“The locals have changed” section. Use descriptive alt text and keep names
and combat facts in Markdown captions, where they can be corrected and translated.

Only crop and resize the captured scene; do not recolor, synthesize details or
alter apparent size relationships. Document the capture revision, client
version, dependencies, scene setup and edits in `graphics/README.md`, and add
the resulting images to the Wube-derived exceptions in `NOTICE`. Documentation
captures remain outside the playable ZIP; packaged README links must point to
the hosted images. Do not redistribute raw game sprite sheets.
