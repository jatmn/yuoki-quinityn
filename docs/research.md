# Yuoki Industries: historical and design research

Research date: 6 October 2026. This document distinguishes original fiction, historical implementation, community proposals and this addon's inventions. Links are primary sources unless explicitly identified as a community contribution.

## Coverage and limits

Both pages of the dedicated forum were indexed, yielding 62 distinct topic links and 157 topic pages, including the 60-page main discussion, the nine-page Engines thread, player builds, graphics, bugs, release announcements, PFW and railways. The local extraction contained 2,254 post records. [The index](forum-index.json) preserves titles, URLs and page counts; the counts include linked/sticky topics and are not a claim of 62 newly listed topics. Relevant author posts, the two original German stories, current English localization, recipes, machines, settings and Space Age integrations were examined in depth.

This is a comprehensive design-oriented survey, not a claim that every historical screenshot, video, external download or forum reply was independently verified. Raw forum pages and full story PDFs are not republished here. Historical recipes describe their version, not necessarily today's balance. The source snapshots for implementation are the pending 2.1 branches, not a 2015 recipe guide.

## How the mod developed

| Period | Evidence and significance |
| --- | --- |
| May 2014 | The main thread began on 8 May 2014. Early development included lamps, dirt washing, purified ores, contaminated water and alternatives to acquiring alien science through combat. This predates the 2015 dedicated-subforum era. [Original thread](https://forums.factorio.com/viewtopic.php?t=3453) |
| June 2014 | YuokiTani explained that a stranded engineer already knows considerable technology. Research was not the central progression mechanism; building a resource-hungry factory was. The planet-owner monument and industrial dominance over hostile natives also appear in early discussion. [Early design discussion](https://forums.factorio.com/viewtopic.php?t=3453&start=100) |
| September 2014 | The AMFC was renamed Cimota Restructor. Waste-to-unicomp recipes, fuel and crystal processing were already being developed. [Version 0.2.9 discussion](https://forums.factorio.com/viewtopic.php?t=3453&start=200) |
| October 2014 | Laika-Gate was described as a trade post connecting worlds with continuing demand for goods. Trade justified exotic technology without having to manufacture everything from mundane inputs. [Trade concept](https://forums.factorio.com/viewtopic.php?t=3453&start=220) |
| Early 2015 | Discussion explored closed industrial cycles, fuel value, liquid unicomp density and the relationship between matter conversion, processing and trade. [Energy/conversion discussion](https://forums.factorio.com/viewtopic.php?t=3453&start=280) |
| March–May 2015 | Trade concepts developed into Profit From War/Weapons. Engines and PFW received dedicated threads on 11 May 2015. The broader setting included a violent interstellar economy that buys manufactured goods. [Trade conception](https://forums.factorio.com/viewtopic.php?t=3453&start=400), [PFW thread](https://forums.factorio.com/viewtopic.php?t=12217) |
| Mid-2015 | Engines combined alternate power generation and transmission with crops, livestock and unusual biological products. Vugar, Trifitan and Rabio were intentionally fictional names. MF connected machinery through fluid-like power transmission. [Engines thread](https://forums.factorio.com/viewtopic.php?t=12216) |
| Late 2015 | Railways became a distinct extension; December brought railway additions and the dedicated fiction thread. The two German stories establish Quinityn and the corporate-contract setting. [Railways core](https://forums.factorio.com/viewtopic.php?t=15303), [Story thread](https://forums.factorio.com/viewtopic.php?t=18145) |
| 2016–2017 | A community technology-tree mod demonstrated demand for more discoverable progression. Engines experimented with recipes and packaging; the author described reputation-based blueprint acquisition as an idea constrained by the then-current research system. [Tech-tree thread](https://forums.factorio.com/viewtopic.php?t=32593), [Author's design notes](https://forums.factorio.com/viewtopic.php?t=3453&start=1020) |
| 2017–2019 | Mastercrafted equipment, personal equipment and graphics continued evolving. PFW was marked obsolete rather than a permanent required component of all Yuoki gameplay. The author also discussed self-sustaining conversion/trade factories as a deliberate challenge. [2017 changes](https://forums.factorio.com/viewtopic.php?t=3453&start=1040), [2018 balance discussion](https://forums.factorio.com/viewtopic.php?t=45259&start=40), [Graphics work](https://forums.factorio.com/viewtopic.php?t=13436&start=40) |
| 2020–2021 | Forum releases document the 1.0 and 1.1 era and contributions from ChurchOrganist. jatmn's October 2021 feedback request predates the later maintainer handoff. [Archive index](https://forums.factorio.com/viewforum.php?f=70), [Feedback request](https://forums.factorio.com/viewtopic.php?t=100360) |
| 2024 onward | The current portal statement says YuokiTani transferred maintenance to jatmn around Factorio 2.0 and that jatmn published updates from November 2024. Compatibility, Space Age and integrations became explicit priorities. [Maintainer statement](https://mods.factorio.com/mod/Yuoki) |
| October 2026 | The implementation baseline is Yuoki and Engines 1.3.0 from the pending Factorio 2.1 branches. Both load in official headless 2.1.21. [Yuoki PR](https://github.com/jatmn/Yuoki-Factorio-2.0/pull/11), [Engines PR](https://github.com/jatmn/Yuoki-Engines-Factorio-2.0/pull/3) |

## Original fiction: why Quinityn is the right name

The dedicated story thread introduces fictional context and links two German PDFs. It explicitly treats this as entertaining background, rather than a technical manual. The PDFs were successfully fetched directly and read in German; no inference from the English link titles was needed. [Story introduction](https://forums.factorio.com/viewtopic.php?t=18145)

**F001, 1 December 2015.** Commander Thorbs runs the merchant ship *Vortizer* near Quinityn. A burdensome Yuoki Industries contract and failing finances motivate him to exploit distress calls from the surface. He refuses evacuation, sends old equipment, suppresses the emergency and sees stranded people as customers for supplies purchased with their resources. Fiege, his inexperienced first officer, objects but is intimidated. The premise supports discarded industrial equipment, hostile indigenous life, trade dependence and corporate exploitation. [Original F001](https://johnsmith.ktec.de/factorio/storys/story_de2151201.pdf)

**F002, 2 December 2015.** Marwin E. is recruited under a deceptive employment arrangement and dropped onto Quinityn during a supposed capsule exercise. After building industry and a rocket, he attempts escape. His contract is invoked to return him to the surface. Meanwhile the *Vortizer* continues business and the corporate ship *Frantiss*, under Deems, prepares another worker for an established base; that worker is Klaus Fiege. Quinityn is explicitly identified in the location headings. The story gives the planet its identity and explains repeated industrial development, but it does not describe purple oceans. [Original F002](https://johnsmith.ktec.de/factorio/storys/story_de2151202.pdf)

The addon adopts the name and industrial-survival premise. It deliberately allows successful rocket launches, as requested. It does not enforce a contract prison, reset a factory, prevent departure or reenact the characters' fate.

## Material language and production identity

The current source and localization are more reliable than old shorthand for naming present-day items. Some historical discussions mix N4/F7 and N7/F4; this addon follows the maintained identifiers and labels. [Yuoki localization](https://github.com/jatmn/Yuoki-Factorio-2.0/blob/ce7918f/locale/en/Yuoki.cfg)

| Concept | Current identifiers | Role in the new planet |
| --- | --- | --- |
| Durotal, N4 | `y-res1`, `y-crush-yres1`, `y-refined-yres1`, `y-unicomp-raw` | Local mineral, crushed feed, pellets and structural metal. `y-unicomp-raw` is **not** the UC-A2 matter currency. |
| Nuatreel, F7 | `y-res2`, `y-crush-yres2`, `y-refined-yres2`, `y-raw-fuelnium` | Companion mineral and energy/material processing chain. |
| Unicomp A2 | `y-unicomp-a2`, `y-liquid-uc2` | Universal reconstructed matter. The ocean uses the existing liquid, avoiding a second incompatible fluid. |
| Cimota Restructor | `y-atomic-constructor` | The established route from UC-A2 into ordinary resources and crude oil. |
| Technic Signs | `y_rwtechsign` | Industrial knowledge earned as production output; included in planet science. |
| Merchant Signs and reputation | `ypfw_trader_sign`, `y-fame` | Trade progression, kept distinct from technical knowledge and universal matter. |
| Quantrinum | `y-quantrinum` and related forms | Advanced material, equipment and energy progression. |
| Laika-Gate | `y-stargate` | Late industrial trade. Its memorial naming is documented by the mod itself. |

The actual N4/F7 processing uses crushers and form presses, with water and slag handling as important constraints. Their refined products combine into reactor fuel that awards Technic Signs. These existing steps provide a concrete foundation for science rather than inventing a disconnected ore family. [Metal-processing recipes](https://github.com/jatmn/Yuoki-Factorio-2.0/blob/ce7918f/prototypes/recipe/r_metal-process.lua)

The maintained atomic recipes exchange 5 liquid UC-A2 for 25 solid units and reverse that exchange. They reconstruct normal resources and crude oil through the Cimota. An infinite ocean makes energy and processing capacity the practical limit; importing a second "dilute unicomp" fluid would undermine the user's requested material identity. Emergency hand dressing is consequently limited to hand crafting and intentionally inefficient. [Atomic recipes](https://github.com/jatmn/Yuoki-Factorio-2.0/blob/ce7918f/prototypes/item/ir_atomics.lua)

Engines' farming, seed, animal, DNA, food, packaging and export recipes form connected production families. Mechanical Force, fluid temperatures, lubricant and condensate are operational details, not interchangeable with ordinary electric power. The addon preserves these recipe names and fluid types. [Engines recipes](https://github.com/jatmn/Yuoki-Engines-Factorio-2.0/blob/dd13f42/prototypes/z_recipes.lua), [MF recipes](https://github.com/jatmn/Yuoki-Engines-Factorio-2.0/blob/dd13f42/prototypes/recipes_mf.lua)

## Research-tree precedents and the new design

Yuoki's absence of a conventional comprehensive technology tree is a historical design choice, not evidence that the mod lacks progression. Material dependencies, power requirements, industrial byproducts, signs and trade already provide progression. The 2016 community tech-tree discussion also shows that players benefited from a visible explanation of those relationships. This addon adds an explicit tree because that is the requested gameplay, while retaining the production families. [Community tree discussion](https://forums.factorio.com/viewtopic.php?t=32593)

The new industrial research data combines a Durotal block, compressed F7, a Technic Sign and recovered flyash. It can only be made on Quinityn. Finite research teaches the production families; infinite mining productivity and plasma damage consume this same science with the six standard science packs. This gives the home industry a lasting export role. These mechanics are new work, not an attributed YuokiTani design.

A December 2024 community proposal suggested deeper Space Age integration: alternative crafting machines, productivity, expanded food trades, quality modules and new conversions. That thread is evidence of community ideas, not original lore or a maintainer commitment. This addon does not silently implement the entire proposal. [Space Age suggestions](https://forums.factorio.com/viewtopic.php?t=123950)

The addon interprets flyash trapped in unicomp-stained rocks as settled industrial fallout. Finding a sample reveals science; powered Fatmice air scrubbing supplies ongoing research and removes pollution. Reusable filters arrive as a later research upgrade. The pinned Engines cleaning recipe already returns a clean filter and six flyash, with no wastewater; its outputs are retained. Its waste-condensation recipe supplies mixed fuel, which Yuoki can convert into rocket fuel. The geological explanation and staged unlocks are this addon's adaptation, not a claim about the original stories. [Engines scrubbing and filter recipes](https://github.com/jatmn/Yuoki-Engines-Factorio-2.0/blob/dd13f421f68010fd0180cda4fb9273f9b582198e/prototypes/z_recipes.lua), [waste condensation](https://github.com/jatmn/Yuoki-Engines-Factorio-2.0/blob/dd13f421f68010fd0180cda4fb9273f9b582198e/prototypes/r_externs.lua)

## Explicit boundary between evidence and invention

**Grounded in the original material:** Quinityn, corporate contracts, stranded industrial workers, hostile native life, recycled or old machinery, universal matter conversion, interworld commerce, the N4/F7 material families, MF engineering, fictional agriculture, signs, reputation and Laika trade.

**New adaptation for this addon:** basalt archipelagos; purple unicomp seas; item dissolution; the map's specific geography; small starting deposits; emergency hand dressing and burner separation; physical-landing unlocks; the staged research tree; industrial research data; local petrochemical research; rocket-component variants; and infinite research.

**Not asserted:** that Fulgora's builders were Yuoki; that Vulcanus has a canonical connection to Quinityn; that the original stories contain an ocean of unicomp; that PFW or Railways must be installed; or that a community post is canon. The requested resemblance is expressed through industrial salvage, volcanic terrain, restricted land and fluid-resource exploitation, with biters retained as the native threat.

## Technical primary references

Implementation follows the actual 2.1 prototype and runtime contracts, including native tile disposal and scripted research triggers. This matters because the 2.0 recipe categories, probability fields and certain runtime structures changed in 2.1.

- [Official Factorio data source](https://github.com/wube/factorio-data)
- [Factorio 2.1.21 TilePrototype](https://lua-api.factorio.com/2.1.21/prototypes/TilePrototype.html)
- [Factorio 2.1.21 PlanetPrototype](https://lua-api.factorio.com/2.1.21/prototypes/PlanetPrototype.html)
- [Factorio 2.1.21 scripted technology trigger](https://lua-api.factorio.com/2.1.21/types/ScriptedTechnologyTrigger.html)
- [Factorio 2.1.21 Tips and Tricks entries](https://lua-api.factorio.com/2.1.21/prototypes/TipsAndTricksItem.html)

The dependency commits and verification commands are recorded in [development](development.md) and [validation](validation.md). The old published 2.0 branches were initially inspected, but are not used in the delivered implementation.
