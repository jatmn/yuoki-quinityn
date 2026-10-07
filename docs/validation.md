# Validation record — 0.1.0 development

Checked with official Factorio **2.1.21 + Space Age** and the pinned, unmodified Yuoki/Engines 1.3.0 branches. The [earlier development snapshot validation record](https://github.com/jatmn/yuoki-quinityn/blob/v0.1.0/docs/validation.md) remains available for the earlier preview.

## Feedback checks

| Requested behavior | Evidence |
| --- | --- |
| Larger, irregular, seed-varied starter ore | Actual engine generation on seeds 1, 42 and 8675309: each patch contains 135k–149k ore, has at least 180 tiles, and its centroid changes with the seed. Targets are 125k–150k per patch. |
| Natural coastlines without the artificial pond | The fixed pond expression is removed. Origin and the former inlet remain dry; runtime pumping finds an actual natural shoreline. |
| Smaller but mostly connected land | Warped ridged noise increases terrain frequency. In three 720×720-tile samples, land occupies 26–59% of the sample; 83–91% of sampled land connects to the starting district. Connectivity is measured on a 2-tile sampling grid. |
| Dense, sparse stockpile districts and starter salvage | Three samples have 7–13 occupied 64-tile districts out of 100, with dense clusters; 182–300 stockpiles lie within 160 tiles of the start, and more occur beyond it. Starter clusters replace the previous uniformly rare placement. The shared placement probability is 0.06, tuned down to keep the landscape from filling with wrecks. |
| More cosmetic terrain | All six natural tile types occur, plus more than 100 decorative placements in each tested starter region. Five decorative types cover rocks, cracks, pumice and machinery debris. |
| Impassable unicomp | The engine rejects placement of small/medium/big/behemoth biters and a spitter on unicomp. Native pathfinding cannot leave an island through a unicomp moat. |
| Icons | Original RGBA salvage and bottle icons are packaged at 256×256. The updated bottle is inspected at 32px inventory size; the salvage was inspected at 64px. The bottle contains purple unicomp and a Technic Sign badge. [References and final prompts](../graphics/README.md). |
| Factory-only science | Only the three Yuoki factories receive the category; the character and vanilla assemblers do not. Each real factory manufactures five science packs in an operating fixture, and a vanilla assembler rejects the recipe. |
| Dedicated signs | All three factories produce exactly one Technic Sign from the specified expensive inputs, without byproducts. Recipe work is 30 seconds before machine speed. |
| Primitive Cimota | The machine uses Cimota graphics, retains the bootstrap ID/cost/180 kW/6 pollution/no modules, and runs at 0.5 crafting speed. A real fixture produces water burning raw F7 without grid power. F7 is 1 MJ versus wood's 2 MJ. |
| Unknown localization keys | All 206 Quinityn prototypes are audited against the installed English dictionaries, including explicit references, implicit visible names and surface-property units. Missing custom unit/category/route/generator labels are supplied. |
| Planet controls | N4/F7 control membership lists only Quinityn; native generation on all five other planets produces no Yuoki ores. Paired seed-42 samples cover 768×768 tiles: liquid coverage 0.5/1/2 produces 220,174/380,279/474,451 liquid tiles. Default cliffs number 524; zero cliff frequency produces none. Quinityn enemy frequency/size 4/2 raises nests from 8 to 171; zero frequency produces none. Setting Nauvis enemy frequency/size to zero leaves Quinityn nest positions identical. |
| Salvage path | A naturally generated stockpile mines into 20 salvage; the actual arrival handler unlocks a visible hand-sorting recipe. Its icon now matches the salvage input, and item/guide text links directly to the recipe. The original ingredient/output IDs and unlock remain intact. |
| Research progression | Survey requires discovery; native landing without discovery is rejected, discovery alone grants no recipes, and a discovered physical landing opens the survey. All pack-based Quinityn research after Materials consumes local science. Closure reaches the first packs before Power, all finite Quinityn technologies, local rockets and infinite-science ingredients. |
| Separate tiers and icons | Head-assisted crushing/digging, machine upgrades, accumulators, factories, defenses, modules, robots and successive biological/armor tiers have separate prerequisite-linked owners. Native unlock tests cover plain versus assisted recipes and first versus second crusher. Research icons use representative items/machines, and 51 native guide entries explain the progression. |
| Bootstrap preservation | First factory moved to Materials, before Quinityn-science research. Post-discovery empty-inventory closure still reaches local science, foundations and rockets. The finite budget now includes that factory and extra Circuit network research allowance. |

The constructive budget reserves **600 red, 400 green and 160 Quinityn packs**, the first factory and early machines, and 500 coal. It consumes **6,878 N4 and 3,371 F7**, below even the minimum starter target, without salvage or distant ore. Reactor-fuel byproduct signs remain the economical early route; dedicated qualification is optional.

Existing foundation contracts, visit gates, native disposal (including rare items), infinite research, actual rocket construction/launch, upstream settings and loaded technology/recipe dependencies remain covered. [Compact test results](test-results.txt) record the current run. The packaged `yuoki-quinityn_0.1.0.zip` also passes native save creation without the test harness. Reproduce the complete suite with `tools/test.py` as described in [development](development.md).

## Limits and save compatibility

The terrain images reviewed during development are sampled map schematics, not graphical-client screenshots. Native terrain seams, the map-generator UI itself, full visual clutter and tutorial layout still need graphical playtesting. Control membership and behavior are tested through the engine; hand-crafting menu clicks require a graphical player. Only the listed seeds are asserted; world balance across arbitrary seeds is not guaranteed by three samples.

Machine/lab/rocket fixtures inject ingredients and power to isolate operation. The dependency closure and finite budget independently establish local resource paths; no automated agent played a complete factory from landing to launch. The player-arrival boundary still uses the existing narrow facade because headless cannot construct a LuaPlayer.

Existing completed technologies, generated chunks, ore amounts and built stock are preserved. Recipes moved from broad unlocks into new tier technologies require the new research in existing development saves. Use a **fresh map** to see the changed starter deposits and coastline. Newly explored chunks use the new terrain. Existing separator entities retain their ID and become primitive Cimotas; their input/output connection positions follow the Cimota, so existing pipes may need reconnecting. Move science manufacture into a Yuoki factory.

Other overhaul mods and future upstream dependency revisions remain outside the validated baseline. A full graphical playthrough is still needed for balance and polish.
