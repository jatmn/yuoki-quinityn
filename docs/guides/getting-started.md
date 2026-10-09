# Getting started

[Documentation index](../README.md) · [Progression guide](progression.md)

Quinityn is a playable development preview for **Factorio 2.1 + Space Age**.
The source and the historical preview ZIP are different snapshots: choose a
source build for the terrain, progression and enemies described in today's guides.

## Requirements

| Component | Required by the mod | Recorded test baseline |
| --- | --- | --- |
| Factorio | 2.1.21 or later in the 2.1 series | 2.1.21, build 87673 |
| Space Age | 2.1.21+ | Bundled with the pinned engine |
| [Yuoki Industries](https://mods.factorio.com/mod/Yuoki) | 1.3.0+ | 1.3.0 pinned source |
| [Engines](https://mods.factorio.com/mod/yi_engines) | 1.3.0+ | 1.3.0 pinned source |

Yuoki and Engines have released Factorio 2.1 versions. Install them through the
in-game mod manager or their linked Mod Portal pages. Their older Factorio 2.0
releases do not satisfy Quinityn's requirements. The
[exact source pins](../contributing/development.md#exact-dependency-revisions)
make development tests reproducible; they do not establish that every later
release or the published dependency ZIPs have been tested byte for byte.

## Install the current source

1. Download or clone [this repository](https://github.com/jatmn/yuoki-quinityn).
   Open a terminal in its root directory, beside `info.json`.
2. With Python 3 installed, build the add-on:

   ```sh
   python3 tools/package.py
   python3 tools/validate_package.py
   ```

3. Copy the generated `yuoki-quinityn_<version>.zip` from `build/dist/` into
   your Factorio mods directory. Keep it zipped. Factorio's default user-data
   locations are listed in the [application directory guide](https://wiki.factorio.com/Application_directory).
4. Enable **Space Age**, **Yuoki Industries**, **Yuoki Industries - Engines**
   and **Yuoki Industries: Quinityn**, then restart Factorio when prompted.

Build output uses the next patch version when `Unreleased` notes exist. Replace
older snapshots with the same mod/version rather than keeping competing copies;
the ZIP filename identifies the packaged version. Quinityn's package does not
contain the game, DLC or dependency mods. To build the pinned dependencies too,
use the [development guide](../contributing/development.md).

## Install the historical preview

The [public 0.1.0 preview](https://github.com/jatmn/yuoki-quinityn/releases/tag/v0.1.0-preview.2)
contains an installable Quinityn ZIP, license notices and checksums. Install its
Quinityn ZIP with the released Factorio 2.1 dependencies described above.
This older snapshot **does not contain the Uni-touched enemies or all current
terrain and progression changes**; it is not a build of the latest source.

Its bundled dependency ZIPs are historical source builds and remain unchanged:

| Preview dependency | Historical source revision |
| --- | --- |
| Yuoki 1.3.0 | [`ce7918f`](https://github.com/jatmn/Yuoki-Factorio-2.x/commit/ce7918f2b252f2d79ba86b9ae05d991e7af1f261) |
| Engines 1.3.0 | [`dd13f42`](https://github.com/jatmn/Yuoki-Engines-Factorio-2.x/commit/dd13f421f68010fd0180cda4fb9273f9b582198e) |

Current reproducible source builds instead pin Yuoki `c865cf0`, including the
optional adjustable-inserter cleanup setting. For future downloadable builds,
check the [release listing](https://github.com/jatmn/yuoki-quinityn/releases)
and the notes attached to the particular snapshot.

## Begin your expedition

Research Quinityn's discovery and travel from Nauvis using normal Space Age
platform travel. A character must physically land to complete the field survey;
discovery and remote viewing alone do not open Yuoki's recipes. Teammates on
the same force share the unlock.

An empty-inventory landing is supported after discovery. Quinityn is not an
alternative starting-planet mode, and the mod does not provide a rescue platform.
The [progression guide](progression.md) walks from local salvage to water,
power, factory science and a locally built rocket. Check the
[enemy field guide](enemies.md) before expanding into the slag districts.

## Existing saves

Back up development saves before changing mods. Use a **fresh Quinityn surface
or map** to see all current terrain, rock and enemy generation. Existing chunks,
ore and enemies are preserved, and old surfaces can retain saved generation
settings. Ordinary nests on an older save retain ordinary offspring; existing
Uni-touched nests can produce Stomp-a-trons in the current source.

Completed technologies and built machines remain. Recipes moved into separate
research tiers need their new research; existing primitive Cimotas may need
pipe reconnection, and science belongs in a Yuoki factory with a flyash supply.
For the intended discovery balance, use a save that has not already established
Yuoki industry. Read the detailed
[save compatibility record](../contributing/validation.md#limits-and-save-compatibility)
before updating a factory.

## Preview limits and feedback

The [validation record](../contributing/validation.md) separates actual engine
checks from resource analysis and injected test fixtures. A complete graphical
playthrough, combat balance and compatibility with other overhauls remain to be
tested. If you find a problem, [report it](https://github.com/jatmn/yuoki-quinityn/issues)
with the game/mod versions, source revision or ZIP, map seed, relevant settings
and steps to reproduce it.
