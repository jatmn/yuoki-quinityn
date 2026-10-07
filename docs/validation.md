# Validation record

Validated on **2026-10-06**, using the official Linux headless **Factorio 2.1.21 (build 87673)** with Space Age and the unmodified pending Yuoki / Engines commits pinned in [development](development.md). This is a first playable preview, with the limits below.

## Passed

| Check | Evidence |
| --- | --- |
| Actual prototype load | Official engine loads the complete required mod set without prototype errors. The final three installable zip packages also create a fresh save without the test harness. |
| Visit and progression gates | 907 upstream/integration recipes receive Quinityn gates; all 867 recipes with upstream name prefixes are checked explicitly, including generated recycling. Technology ancestry reaches physical arrival without cycles. Discovery alone and remote viewing do not grant arrival. |
| Starting terrain | Seeds **1, 42, 8675309** each generate a dry plateau, a pumpable unicomp inlet, exactly **9,800 N4 + 9,800 F7** in small starting patches, salvage and biter bases. The generated test area has no iron/copper/crude deposits or vanilla liquid tiles. |
| Local dependency closure | From zero inventory and zero research after arrival: **512 items, 181 technologies and 85 machines** become reachable in 21 closure iterations. Required outputs include a powered Cimota, planet science, Durotal foundations, rocket silo, rocket parts and their ingredients. Imports and recycling are excluded. |
| Finite bootstrap stock | A constructive bill of materials reaches powered Cimota production using **4,784 N4 / 2,627 F7**, below the 9,800 of each available. It reserves early research, machines, 500 coal and does not count salvage or distant ore. |
| Offshore extraction | A normally placeable shore pump actually fills an attached pipe with `y-liquid-uc2`. |
| Water without electricity | A real burner separator, supplied coal and unicomp in the fixture, produces water. |
| Native item disposal | A shore burner inserter empties normal and rare iron plates into unicomp; no dropped item entities remain. |
| Research and configuration | Landing enables bootstrap but not advanced recipes; Materials unlocks the crusher. Local crude research grants Oil processing. A new force remains gated. Reconciliation preserves researched Yuoki unlocks and unrelated recipe state. |
| Endgame science | A real powered lab consumes the specified sciences and completes research that increases native mining productivity and plasma damage. Both technologies have infinite maximum level. |
| Local launch behavior | A real silo on Quinityn constructs and launches a rocket to a receiving platform. |
| Foundation contracts | Durotal foundation inherits every normal foundation destination and adds unicomp. No other built-in tile item includes unicomp. Mining, frozen/thawed variants, planet restriction and required research are checked. |
| Native guide | 17 Tips and Tricks prototypes load; every item/entity/fluid/recipe/technology/planet rich-text reference in the English locale resolves. |
| Startup options | The optional upstream starting suit is forced off. Disabling upstream heavy-oil-to-unicomp conversion leaves it disabled with no research unlock. |

The [saved check output](test-results.txt) contains the compact evidence. Run `tools/test.py` to reproduce full engine logs and temporary maps. The [recipe manifest](recipe-unlocks.json) comes from the engine's actual default-settings prototype dump.

## What these checks do and do not establish

The dependency closure is an availability analysis, not a factory simulator. It includes recipe unlocks, trigger research, machine categories, fuel, surface restrictions, water and the initial power dependency. It does not prove production rates, pollution survival, exact later-game stock requirements or economic balance. The separate constructive budget checks that the early path fits within the limited starting ore.

Runtime fixtures deliberately insert ingredients, research prerequisites and power for isolated machine, lab and rocket checks. The rocket test demonstrates native construction and launching on the planet; it does **not** claim a bot played from empty inventory to launch. The resource proof is separate and uses the actual loaded recipes.

The headless API cannot construct a LuaPlayer. The physical-arrival handler is exercised with a narrow player facade backed by real character, surface and force objects. A real graphical player journey, multiplayer travel and force-merge session remain to be exercised manually. The tests do save and reload the generated map before running the fixtures.

Graphical terrain seams, fog readability, tutorial presentation, manual inventory dropping and foundation placement by a player have not been visually inspected. Prototype contracts and native inserter disposal are covered. The current graphics reuse installed assets; bespoke planet art and further visual polish are future work.

A full uninterrupted graphical playthrough is still needed to tune research pacing, shoreline expansion, ore availability, pollution pressure, biter difficulty and endgame costs. Compatibility with unrelated overhaul/tech-tree/alternate-start mods and later dependency revisions is not established. Existing machines/items are intentionally not confiscated when adding this mod to an established Yuoki save.
