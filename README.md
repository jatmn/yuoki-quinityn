# Yuoki Industries: Quinityn

A Factorio **2.1 + Space Age** planet addon for **Yuoki Industries and Yuoki Industries Engines**, maintained by jatmn.

Quinityn is the contract world named in YuokiTani's original stories. This adaptation turns it into a polluted industrial wasteland: weathered soil, dead turf, ash, slag, buried machinery, salvage, native biters and purple seas of **Yuoki Liquid Unicomp A2**. Offshore pumps extract unicomp; shore inserters discard items into it using Factorio's native lava disposal mechanic.

## Development toward 0.1.0

Development updates retain version **0.1.0** until `main` is stable for the initial release. This branch revises the starting area to irregular, seed-varied 125k–150k ore deposits, removes the artificial pond, and adds organic connected terrain, clustered stockpiles and decayed natural ground. Weathered soil and dead turf weave between industrial scars, with non-mineable poisoned shrubs, dry tufts, withered grasses and ordinary stone fragments. A winding dry land connection prevents isolated landing islands. Fulgora-style cliffs generate only on machinery-covered ruined districts, primarily near shorelines, and sparse purple dead-tree groves have their own generation sliders and disable checkbox, with tree placement reduced by 20% from the preceding development revision. Original salvage and science-bottle icons are included. Science now runs only in the three Yuoki factories; a dedicated expensive recipe supplies Technic Signs. The bootstrap machine is a slower primitive Cimota that can burn raw F7 at 1 MJ.

Initial enemy nests and worms generate on brown slag; later colonies can expand onto other walkable terrain.

Use a fresh Quinityn surface or map to see all generation changes; existing surfaces can retain their saved generation settings and existing terrain is not rewritten. [Revision validation](docs/validation.md) includes biter pathfinding and actual factory operation checks.

## Download

**[Earlier private development snapshot](https://github.com/jatmn/yuoki-quinityn/releases/tag/v0.1.0)** — this snapshot predates the latest PR changes. For current development, build the desired branch using [the packaging instructions](docs/development.md). Install the three mod zips with Factorio **2.1.21** and Space Age. The release includes the unmodified pending 2.1 dependency builds and checksums.

- [Yuoki 1.3.0 / 2.1 PR #11](https://github.com/jatmn/Yuoki-Factorio-2.0/pull/11), commit `ce7918f`.
- [Engines 1.3.0 / 2.1 PR #3](https://github.com/jatmn/Yuoki-Engines-Factorio-2.0/pull/3), commit `dd13f42`.

The published 2.0 dependency versions cannot substitute for these builds. This addon does not modify or merge either upstream branch.

## Play

Research Planet discovery Quinityn and travel from Nauvis. Yuoki and Engines recipes remain locked until a character physically lands. A force-wide technology tree then guides materials, power, Cimota reconstruction, Mechanical Force, refining, farming, defense, trade and advanced industry. **59 native Tips and Tricks chapters** explain the stages in game.

Arriving with no items is supported after researching planet discovery. The field survey requires discovery and physical landing. Crafting milestones guide crushing through components and the first factory before science unlocks; every pack-based planet research consumes Quinityn science. Small N4/F7 starting patches support emergency hand processing; the existing Yuoki unicomp conversions supply ordinary resources for long-term production. Water, electricity, science and rocket materials all have local paths. Initial spawn and normal platform travel remain unchanged.

**Durotal foundations**, unlocked and manufactured here, work wherever ordinary foundations work and are required to expand over unicomp. Planet-exclusive research data also feeds **infinite mining productivity and Yuoki plasma damage research**, giving the planet a continuing endgame role.

## Evidence and documentation

The official headless engine loads the mod and tests terrain on three seeds, recipe gating, real unicomp pumping, burner water production, item disposal, infinite research and rocket construction/launch. Separate dependency and finite-stock analyses check the empty-inventory bootstrap. This is a first playable preview; a full graphical playthrough and balance review remain outstanding. See [validation and limitations](docs/validation.md).

- [Progression and local-resource guide](docs/progression.md)
- [History, lore, production research and primary sources](docs/research.md)
- [Forum coverage index](docs/forum-index.json)
- [Engine-generated recipe unlock manifest](docs/recipe-unlocks.json)
- [Installation, pinned dependencies, tests and reproducible packaging](docs/development.md)

The research distinguishes original lore from new gameplay. Unicomp oceans and this particular industrial landscape are an adaptation; they are not presented as details established by the original stories. World graphics reference installed Factorio/Yuoki assets. The salvage and science icons are original generated assets; [prompts and references](graphics/README.md) are included.
