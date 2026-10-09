# Creature screenshots

[Documentation index](../README.md) · [Enemy field guide](../guides/enemies.md)

## Capture status

The [enemy gallery](../guides/enemies.md#visuals-and-validation) was captured
on **2026-10-09** in the licensed graphical Factorio client. All four scenes
are **editor-staged in-game captures** on Quinityn, not naturally encountered
formations. The landscape and earlier creature concepts are separate artwork.

## Capture record

| Input | Exact baseline |
| --- | --- |
| Quinityn source | [`cf0684d7fbc817e3bab355ff1b1cbb218954a49a`](https://github.com/jatmn/yuoki-quinityn/commit/cf0684d7fbc817e3bab355ff1b1cbb218954a49a) |
| Graphical client | Factorio **2.1.21**, build **87673**, Windows x64, Steam, with installed Space Age graphics |
| Official mods | Base, Space Age, Quality, Elevated Rails and Recycler **2.1.21** |
| Yuoki | **1.3.0**, source `c865cf05d5009d7f2224b32900272d4b1f012f21` |
| Engines | **1.3.0**, source `dd13f421f68010fd0180cda4fb9273f9b582198e` |
| Quinityn package | **0.1.1** development artifact produced by `tools/package.py`; source `info.json` remains **0.1.0** |
| Map | Fresh disposable freeplay save, seed **424242**; generated Quinityn surface seed **420575443** |
| Renderer | High graphics quality; integrated-GPU preset, low rotation quality and low-quality DXT texture compression; default brightness/contrast/saturation |

The dependencies were built from the pinned, unmodified sources. The package
tool derives its development version from the existing pending changelog;
the capture did not change source versions, gameplay or dependency pins.
An isolated config, mod directory and user-data directory kept the capture
save separate from existing player saves. No additional third-party mods ran.

### Scene setup and camera

The `/editor` surface tool generated the planets and selected Quinityn.
Console placement then arranged the exact prototypes listed below at known
coordinates. Four cleared patches centered at x = 0, 80, 160 and 240 used
`quinityn-slag` (brown slag / “Cracked industrial slag”), extending 30 tiles
either side horizontally and 24 vertically. Local entities and decoratives
were cleared before placement. Daytime was fixed at `0`, with
`freeze_daytime = true` and the editor's **Always render as day** enabled.
The planet's normal color treatment was retained.

Enemy expansion was disabled for staging. Subjects used the enemy force;
units received stop commands and the two nests were disabled by script to
prevent extra offspring. This altered the disposable scene, not the mod.

| File in `docs/images/enemies/` | Arrangement, left to right | Camera center | Screenshot zoom | Original output |
| --- | --- | --- | --- | --- |
| `biters.png` | Small, medium, big, behemoth at x = -7, -3, 2, 8; y = 0 | (0.5, 0) | 2.5 | `screenshot-tick-10629.png` |
| `spitters.png` | Small, medium, big, behemoth at x = 73, 77, 82, 88; y = 0 | (80.5, 0) | 2.5 | `screenshot-tick-44268.png` |
| `colony.png` | Biter nest (154, -4), spitter nest (166, -4); small through behemoth worms at x = 151, 157, 163, 169; y = 5 | (160, 0) | 1.8 | `screenshot-tick-40782.png` |
| `stomp-a-trons.png` | Small, medium, big, initially at (230, 2), (240, 2), (251, 2), then moving toward offsets (+2, -5) | (240, -2) | 1.3 | `screenshot-tick-21466.png` |

Each image used `/screenshot 1920 1080 <zoom>`. The built-in capture hid the
GUI, cursor and selection overlays. Zoom is identical for every subject
within a shot; different shots are not a cross-family scale comparison.
Off-camera player-force characters at y = 18 made the four worms emerge
before the colony capture. They were initially invulnerable for 90 ticks,
then made vulnerable for another 90 ticks to trigger the emergence.

### Inspection and processing

All four full-size images and their thumbnails were visually inspected.
The violet shades and size progression are visible, both nest forms and all
four emerged worm tiers are recognizable, and bodies, legs and shadows fit
inside the frames. Yellow Stomp-a-tron sensors are visible at full size;
use the linked originals for small details that the thumbnails cannot show.

The simulation ran for 60 settling ticks, followed by a 120-tick native
`go_to_location` movement interval for all three Stomp-a-trons. Their legs
changed position and remained attached to the bodies while walking; no
obvious body/leg separation or sensor placement defect was observed in that
short inspection. Worm emergence was also observed. This does not cover
every orientation or animation state, natural spawn frequency, combat
balance, terrain traversal or a complete landing-to-launch playthrough.

The full-size PNGs are unchanged bytes from the client. Pillow **12.2.0**
resized each entire frame with Lanczos to **320 × 180**, saved as an optimized
PNG with the `-thumb` suffix. No cropping, color adjustment, generated
content, repainting or independent subject scaling was applied. These
Wube-derived captures have the exceptions recorded in [NOTICE](../../NOTICE)
and [artwork provenance](../../graphics/README.md#in-game-enemy-screenshots).

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
`docs/images/enemies/`. Link each thumbnail to its full-size
image in the field guide, then feature a compact selection under the README's
“The locals have changed” section. Use descriptive alt text and keep names
and combat facts in Markdown captions, where they can be corrected and translated.

Only crop and resize the captured scene; do not recolor, synthesize details or
alter apparent size relationships. Record the capture revision, client
version, dependencies, scene setup and edits here, link the record from
`graphics/README.md`, and add
the resulting images to the Wube-derived exceptions in `NOTICE`. Documentation
captures remain outside the playable ZIP; packaged README links must point to
the hosted images. Do not redistribute raw game sprite sheets.
