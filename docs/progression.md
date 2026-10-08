# Quinityn progression

The same progression is available inside Factorio through **65 Tips and Tricks chapters**, which appear at the relevant research milestones. Recipe and item links in those chapters open the game's own information views.

## Arrive, then establish industry

Discovery is researched through the normal Space Age route. The connection runs from Nauvis to Quinityn. Discovery or remote viewing alone does not unlock Yuoki; a character must physically arrive. The unlock belongs to the force, so teammates share it. The initial spawn remains unchanged.

If a character changes to an undiscovered force while already on Quinityn, finishing discovery completes that force's survey without another landing. The same physical-character checks apply; remote viewing and characterless controllers do not count.

The world is an industrial wasteland: weathered soil, dead turf, dark ash, cracked slag, buried machinery, scattered industrial salvage, purple unicomp seas and smog. New-map terrain settings include **Unicomp liquid** (coverage and scale), **Quinityn cliffs** (enabled by default), independent **Quinityn enemy bases** and **Quinityn dead trees** (frequency, coverage and disable). The dry landing core remains protected from liquid and cliffs. Sparse purple dead and decaying trees provide wood outside the landing core. Surface pollution absorption is extremely low. Your machines' existing pollution emissions therefore matter to the biter population. Pollution is not artificially multiplied on other worlds.

The starting plateau provides **125,000–150,000 N4 and 125,000–150,000 F7**, in larger irregular patches whose positions, outline and richness vary by map seed. There are no natural iron, copper, coal, stone or crude-oil ore deposits. Mineable ash-coated rocks do provide normal stone, huge-rock coal, and small flyash samples. Large native starting ore patches are suppressed inside a 200-tile radius; modest distant N4/F7 deposits remain. The intended long-term resource source is unicomp conversion, not mining larger starter fields.

1. Mine N4/F7 or salvage. For salvage, select **Sort industrial salvage** (the scrap icon) in the Yuoki crafting tab; one scrap yields 2 N4, 2 F7, 2 stone and 1 wood. Hand-sort enough stone, carbon, iron ore, copper ore and emergency timber to build a furnace and early equipment. These emergency recipes are **hand-crafting only**.
2. Smelt plates. A fresh force can trigger vanilla Steam power and Electronics by crafting plates, then build its first lab and make red science.
3. Make the burner separator from 10 iron plates, 5 copper plates and 10 stone. Pump the purple ocean into it and fuel it with raw F7 chunks (1 MJ each), wood or coal. It produces water without electricity.
4. Crafting the primitive Cimota completes N4 and F7 crushing and unlocks the first crusher, wet crushing recipes and basic mining drill. Feed separated water to a boiler and steam engine; build poles, labs and assemblers. Produce 50 crushed N4 to unlock pressing and the heat form press, then follow the crafting milestones below to establish refined materials, Durotal structures and basic electronics.
5. Mine an ash-coated Quinityn rock after landing to reveal the science and dedicated sign recipes. This discovery works before or after factory research and only recognizes the two Quinityn rock types. Complete Fuelnium reactor fuel and First Yuoki factory research to manufacture the inputs and factory. Reactor-fuel manufacture awards Technic Signs. Research vanilla Circuit network for its arithmetic combinator; `ye_fassembly1` unlocks at First Yuoki factory, after making 20 basic chips. The science recipes are already exposed by rock discovery, but only the Yuoki factories can manufacture them. Five flyash, a Durotal block, compressed F7 and a sign produce five Quinityn research data packs in a Yuoki factory on Quinityn. Only `ye_fassembly1`, `ye_fassembly2` and `ye_fassembly_sp` accept the new science category.
6. Use rock flyash to make the first packs: Yuoki power costs 60 and the separate **Fatmice air scrubbing** unlock costs 40, together requiring 100 flyash. Build a Fatmice and small electric motor for sustained collection, then research Cimota reconstruction. Solidify ocean unicomp in a Cimota and use the **existing Yuoki recipes** for ordinary resources. This replaces manual ore dressing for sustained production.

Eight manufacturing milestones use native crafting triggers after their prerequisites are complete. Science instead uses native rock mining after the field survey:

| Milestone | Prerequisites within Quinityn | Discovery or crafting trigger | Main unlocks |
| --- | --- | --- | --- |
| N4 and F7 crushing | Field survey | 1 primitive Cimota Restructor | First crusher, wet N4/F7 crushing, basic mining drill |
| N4 and F7 pressing | N4 and F7 crushing | 50 crushed N4 | Heat form press and refined N4/F7 |
| Durotal and Fuelnium compaction | N4 and F7 pressing | 30 refined N4 | Durotal blocks and Fuelnium |
| Rich dust and Orange Stuff | N4 and F7 pressing | 50 crushed F7 | Rich dust mixing and Orange Stuff smelting |
| Durotal structures and reinforced gears | Durotal and Fuelnium compaction | 20 Durotal blocks | Structural elements, pressure-proof elements and reinforced gears |
| Conductive wire and basic chips | Rich dust and Orange Stuff | 30 Orange Stuff | Conductive wire, chip plates and basic chips |
| Fuelnium reactor fuel | Durotal and Fuelnium compaction | 10 Fuelnium | Reactor fuel with Technic Sign byproducts |
| First Yuoki factory | Durotal structures and reinforced gears, Conductive wire and basic chips | 20 basic chips | First-tier MF components and first factory |
| Quinityn industrial science | Field survey | Mine an ash-coated Quinityn rock | Reveal industrial research data and dedicated Technic Sign qualification; factory still required to manufacture |

A constructive budget reserves 600 red packs, 400 green packs, 260 Quinityn data packs, two labs, the first Yuoki factory, a Cimota, a Fatmice, its small electric motor and 500 coal. Its first 100 Quinityn packs use 100 finite rock flyash to unlock Power and Fatmice; native generation checks require at least 100 near the landing area. The remaining 160 packs use renewable ash through the actual unfiltered water/MF recipe. Build the Fatmice before spending the remaining science budget on Cimota and other research. The current material totals are recorded in [validation](validation.md), before incidental salvage or remote deposits. This is a finite-material check, not a speedrun or an assertion that no additional defenses will ever be needed.

The new dedicated **Qualify a Technic Sign** recipe produces only one sign from 12 reinforced gears, 8 Durotal structures, 20 conductive wire and 4 basic Yuoki chips, with 30 seconds of recipe work. It unlocks with Quinityn industrial science and uses the same three factories on Quinityn. Reactor-fuel byproduct signs remain available and cheaper for the initial bootstrap.

The terrain uses warped coastlines and narrow connecting land corridors. There is no forced origin pond; find a natural shore for your first pump. Salvage forms dense clusters in sparse industrial districts, with two nearby starter clusters. Weathered soil and dead turf form broad remnants of the former natural surface between ash, rubble, cracked slag and buried machinery. Mixed ash-covered earth forms transition zones around those remnants, with cooler soil tones and irregular turf edges. Poisoned shrubs, dry tufts, withered grasses and ordinary stones are non-mineable ground decorations; volcanic fragments and machinery debris stay on their matching scarred terrain. Dead trees are slightly less dense by default. Unicomp blocks walking biters and spitters like ordinary water.

## Technology map

```mermaid
flowchart TD
  Discovery[Planet discovery - space science] --> Arrival[Physical landing / field survey]
  Arrival --> Materials[N4/F7 crushing - craft primitive Cimota]
  Materials --> Pressing[Pressing - make 50 crushed N4]
  Pressing --> Compacting[Compaction - press 30 refined N4]
  Pressing --> Alloying[Alloying - make 50 crushed F7]
  Compacting --> Structures[Structures - make 20 Durotal blocks]
  Alloying --> Electronics[Electronics - smelt 30 Orange Stuff]
  Compacting --> Fuel[Fuel processing - press 10 Fuelnium]
  Structures --> BasicFactory[First factory unlock - make 20 chips]
  Electronics --> BasicFactory
  Arrival --> Science[Industrial science - mine ash-coated rock]
  BasicFactory --> Production[Factory production of science]
  Fuel --> Production
  Science --> Production
  Production --> Power[Power - requires Quinityn science]
  Power --> Air[Fatmice air scrubbing]
  Air --> Filters[Reusable air filters]
  Washing --> Filters
  Engines --> Filters
  Production --> Excavation[Plain excavation]
  Production --> Washing[Plain washing]
  Excavation --> Tooling[Tool and drill-head processing]
  Washing --> Tooling
  Production --> Machining[Second crusher and form press]
  Power --> Cimota[Cimota reconstruction]
  Cimota --> Oil[Local crude oil milestone]
  Oil --> Components[Advanced components]
  Cimota --> Engines[Basic Mechanical Force]
  Engines --> Refining[Refining]
  Components --> Refining
  Refining --> Crystals[Crystal processing]
  Components --> Storage[First energy storage]
  Crystals --> Quantum[Quantum materials]
  Storage --> Quantum
  Engines --> Factories[Y2-Factory]
  Machining --> Factories
  Factories --> P3[P3-Factory - 1000 units]
  AdvancedEngines[Advanced engines] --> P3
  AdvancedModules[Advanced modules] --> P3
  P3 --> Center[Research center - 5000 units / 40 seconds]
  Mastery[Mastercrafted industry] --> Center
  Robotics[Yuoki robotics - includes chemical science] --> Network[8080 network expansion]
  Robotics --> RobotProduction[Craft 500 YI Logistikers]
  RobotProduction --> AdvancedRobots[Advanced robots - 1000 science units]
  Refining --> Crops[Crop production]
  Crops --> Animals[Husbandry and later genetics]
  Factories --> Animals
  Quantum --> Trade[Trade and later mastery]
  Quantum --> Orbital[Orbital manufacturing]
```

The survey is a descendant of **Planet discovery Quinityn**, not an available starter technology. Discovery costs the normal space-age sciences and unlocks travel; only physical landing completes the survey. The eight crafting milestones and rock discovery consume no research packs. Materials is the first crushing milestone; factory manufacture still needs its production chain even if science has already been revealed. **Every pack-based Quinityn technology uses red, green and Quinityn packs** (later factories, robots, the research center and infinite research also use advanced packs). Prerequisite bridges and the local crude-oil milestone retain their specific technology requirements.

The broad base disciplines now cover their first usable production stage. Upgrades have separate research:

| Research | Prerequisites within Quinityn | Packs of each required science |
| --- | --- | --- |
| Fatmice air scrubbing | Yuoki power and infrastructure | 40 |
| Reusable air filters | Fatmice air scrubbing, Ore washing and residue recovery, Mechanical Force engineering | 100 |
| Deep excavation | Quinityn industrial science, First Yuoki factory, Fuelnium reactor fuel | 50 |
| Ore washing and residue recovery | Quinityn industrial science, First Yuoki factory, Fuelnium reactor fuel | 40 |
| Tool-assisted processing | Deep excavation, Ore washing and residue recovery | 80 |
| Advanced crushing and forming | Quinityn industrial science, First Yuoki factory, Fuelnium reactor fuel | 80 |
| Advanced industrial components | Reconstructed petrochemistry | 100 |
| Maintenance workshops | Tool-assisted processing, Advanced crushing and forming, Advanced industrial components, Yuoki logistics | 100 |
| Industrial energy storage | Yuoki power and infrastructure, Ore washing and residue recovery, Advanced industrial components | 100 |
| Crystal accumulator upgrades | Industrial energy storage, Quantrinum and advanced electronics | 160 |
| Mixed-oxide reactor engineering | Yuoki industrial refining, Advanced industrial components, Contract world defense, Advanced electric generation | 160 |
| Quantum power systems | Crystal accumulator upgrades, Mixed-oxide reactor engineering | 250 |
| Industrial fluid handling | Mechanical force engineering | 80 |
| Y2-Factory | Mechanical force engineering, Advanced crushing and forming | 140 |
| P3-Factory | Y2-Factory, Advanced Mechanical Force engines, Advanced industrial modules | 1,000 |
| Yuoki research center | P3-Factory, Mastercrafted industry | 5,000 |
| Advanced Mechanical Force engines | Y2-Factory, Advanced industrial components | 180 |
| Advanced transport tubes | Mechanical force engineering, Advanced industrial components | 120 |
| Crystal and emulsion processing | Yuoki industrial refining, Ore washing and residue recovery | 150 |
| Animal husbandry and aquaculture | Yuoki agronomy and biology, Y2-Factory, Industrial fluid handling | 160 |
| First-generation industrial biology | Animal husbandry and aquaculture | 200 |
| Second-generation industrial biology | First-generation industrial biology, Quantrinum and advanced electronics | 250 |
| Third-generation industrial biology | Second-generation industrial biology | 300 |
| Advanced industrial inserters | Yuoki logistics, Quantrinum and advanced electronics | 160 |
| Yuoki robotics | Yuoki logistics, Quantrinum and advanced electronics, Industrial energy storage | 180 |
| 8080 network expansion | Yuoki robotics | 300 |
| YI Logistiker production | Yuoki robotics | Craft 500 YI Logistikers; no packs |
| Advanced Yuoki robots | YI Logistiker production | 1,000 |
| Advanced industrial defenses | Contract world defense, Advanced industrial components, Industrial energy storage | 160 |
| Yuoki powered armor | Laika trade network, Advanced industrial defenses, Industrial energy storage | 200 |
| Yuoki powered armor II | Yuoki powered armor, Crystal accumulator upgrades | 240 |
| Yuoki powered armor III | Yuoki powered armor II | 300 |
| Yuoki walker | Yuoki powered armor III, Mastercrafted industry | 400 |
| Advanced Yuoki walker | Yuoki walker | 500 |
| Industrial modules | Advanced industrial components | 100 |
| Advanced industrial modules | Industrial modules, Quantrinum and advanced electronics | 180 |
| Quantum module engineering | Advanced industrial modules | 250 |
| Industrial packaging | Yuoki agronomy and biology, Industrial fluid handling | 120 |
| Advanced electric generation | Yuoki power and infrastructure, Advanced industrial components, Mechanical force engineering, Yuoki industrial refining | 140 |
| Industrial fluid and electric infrastructure | Yuoki power and infrastructure, Advanced industrial components | 80 |

Y2 research unlocks only the Y2-Factory at the existing point in the tree. P3 follows advanced engines and modules, costing 1,000 each of red, green, blue, purple, yellow and Quinityn science at 30 seconds per unit. The research center follows P3 and Mastercrafted industry: **5,000 each of automation, logistic, military, chemical, production, utility, space and Quinityn science, at 40 seconds per unit**. Its free Scientific Reputation recipe moves with it. Existing factory ingredients stay unchanged: Scientific Reputation is available earlier as a byproduct of radar construction, Quantrinum production and other recipes. The local dependency check reaches both factories without the research center; the center alone waits for space science from an orbital supply in the no-import/no-trade scenario.

Yuoki robotics unlocks only the basic roboport and two robots; The 8080 has its own 300-unit research. All three robot lab technologies require **chemical science as well as logistic science**, retaining red and Quinityn science. After Yuoki robotics, craft **500 YI Logistikers** to complete the force-wide production milestone. Existing stock does not count, and other forces do not share the progress. The milestone grants no robot recipes: advanced robots then cost **1,000 each of red, green, blue, purple, yellow and Quinityn science**. Robot lab research retains 20-second units.

The tree separates **upgrades** while keeping related processing steps and same-tier variants together. For example, empty/charged battery cells are steps of one battery process; long, directional and underground transport variants are not successive machine tiers. Some optional products still need inputs from other industrial branches. Existing non-Yuoki research requirements on upstream unlocks are retained through automatic prerequisite bridges. The engine-generated [recipe manifest](recipe-unlocks.json) records every assigned unlock for review.

## Flyash, clean air and discovery

Only Quinityn generates **ash-coated unicomp rocks**: grey-purple versions of Nauvis big and huge rocks, retaining all 20 big and 16 huge sprite shapes. Normal mineable rock types are suppressed on Quinityn. Big rocks retain 20 stone and add 2 flyash. Huge rocks retain 24–50 stone and 24–50 coal and add 4 flyash. Ordinary rock prototypes are unchanged, including on other planets; their mining cannot trigger Quinityn science. Mining either Quinityn rock after arrival reveals science immediately, even if the factory is still far away in the production chain.

These deposits are the settled residue of the planet's former industry, an addition to this addon's interpretation of Quinityn. Keep the samples instead of throwing them into unicomp. The science recipe consumes **5 flyash per 5 packs** (one per pack). Rocks provide finite startup stock; a Fatmice supplies sustained industry while removing pollution.

**Fatmice air scrubbing** is a separate 40-pack research after Power. It unlocks the Fatmice, the small electric motor and its basic components, plus the motor's MF conversion. Supply electricity, water and Mechanical Force to the unfiltered Fatmice: 60 water + 0.2 MF produces 1 flyash every 2 seconds. The motor provides MF without oil. Keep the ash output moving so the machine continues operating.

**Reusable air filters** comes later, after Fatmice, Washing and Engines. Make filters from iron sticks, stone dust and coal dust. A filtered capture consumes a filter, 60 water and 0.2 MF in 10 seconds, removes twice the pollution while operating, and returns a dirty filter. Wash it in a dirt washer with 110 water and 8 coal dust: **1 clean filter + 6 flyash**, with no wastewater. Return the clean filter to the Fatmice. The filtered capture provides six ash per ten seconds versus five unfiltered; budget a separate washer and coal-dust supply. Keep at least two filters circulating per Fatmice, plus transport buffers, so washing does not leave capture waiting for its only filter. The unfiltered recipe remains available.

At normal quality without modules, the science recipe now demands five times as much ash. One unfiltered Fatmice supports **30 packs/minute**; one filtered Fatmice with a dedicated washer supports **36 packs/minute**. These are nominal rates with uninterrupted power, inputs and output handling. Factory capacity and the ash supply required to keep it running are:

| Factory | Packs/minute | Unfiltered Fatmice | Filtered Fatmice + washers |
| --- | --- | --- | --- |
| C1-Factory (`ye_fassembly1`) | 120 | 4 | 4 + 4 |
| Y2-Factory (`ye_fassembly2`) | 180 | 6 | 5 + 5 |
| P3-Factory (`ye_fassembly_sp`) | 300 | 10 | 9 + 9 |

Start with one scrubber and let the first factory work intermittently. An unfiltered scrubber uses **30 water/s and 0.1 MF/s**; a filtered capture/washer pair uses **17 water/s, 0.02 MF/s and 48 coal dust/minute** (32 coal/minute through dust production). A small electric motor produces 0.4 MF/s, enough for four unfiltered scrubbers or twenty filtered ones. The Fatmice uses **1.25 MW while working**, the washer 350 kW and the motor up to 350 kW; these are machine loads before supporting processing and electricity generation.

A primitive burner Cimota provides only 25 water/s, so even one unfiltered Fatmice needs more than one separator at full speed. Boilers need water too. A single 900 kW steam engine cannot run the Fatmice at full speed: expand the power plant and water supply before scaling. The bootstrap budget proves finite materials, not full-speed simultaneous operation of every machine.

Power plus Fatmice needs **100 rock ash**. Reaching filters costs **460 Quinityn packs total** across Power, Fatmice, Cimota, Engines, Washing and Filters: the additional 360 ash takes 12 minutes of unfiltered capture with one fully supplied Fatmice, excluding research/construction time. All finite Quinityn research totals 15,410 Quinityn packs; the first level of either infinite technology consumes another 2,000. Scale scrubbing with labs; the capture and cleaning recipes remain unchanged.

Quinityn replaces Engines' Fatmice startup toggle with these research tiers; both modes use the overhaul's 1x crafting speed and base -250 pollution/minute while active. Filter capture uses a 2x recipe emission multiplier. It does not require actual pollution as a consumed recipe input: it produces ash while running and removes pollution where present, following the upstream mechanic.

## Water and disposal

The ocean is the actual `y-liquid-uc2` fluid. The primitive Cimota converts 1 fluid into 100 water with a 2-second recipe at 0.5 crafting speed: 100 water every 4 seconds, at 180 kW of burner power. It uses the Cimota building and icon, with the previous separator identifier retained for save compatibility. Water and unicomp networks must remain separate. Later machinery can scale or replace bootstrap infrastructure using the existing mod recipes.

Items dropped into unicomp are destroyed by the same native tile capability used by lava. A shore inserter can dispose of surplus. This gives no resource refund and does not reduce the sea. Filter disposal to protect science, fuel and seed reserves. Item quality does not prevent disposal.

## Foundations and expansion

Only **Durotal foundations** cover unicomp seas. Ordinary landfill, normal foundation and other built-in paving do not. The starting plateau supports the bootstrap until this research becomes available after industrial refining.

In a Yuoki form press **on Quinityn**:

- 2 Durotal structure elements
- 1 pressure-proof element
- 5 Orange Stuff
- 10 stone bricks
- Result: **4 Durotal foundations**, in 8 seconds

This is a separate item and tile. Its placement destinations inherit the normal foundation list, plus unicomp, so it can be exported anywhere normal foundations work. Its frozen variant thaws back to the Durotal version, and mining returns the corresponding item. It does not change the vanilla foundation recipe or unlock Aquilo's other technology.

## Local oil and rockets

A local production run that conservatively withholds prior Oil processing would otherwise be stuck at Oil processing because that vanilla technology asks for crude-oil mining. Quinityn has no oil deposit. The alternate local technology instead requires crafting 80 crude oil after Cimota and Oil gathering; completing it grants the normal Oil processing technology.

Follow the vanilla chemistry and rocket prerequisites with locally reconstructed resources. Steel, plastic, sulfuric acid, engines, circuits, concrete, low density structures, processing units and rocket fuel all have local production paths. Trade and incoming platform supplies are **not required** for the rocket-material dependency proof.

**Mechanical Force engineering** explicitly unlocks the existing alternative fuel chain: `y-waste-condense` turns **150 flyash into 2 mixed fuel and 1 Green Sign**; `y_mixedfuel2rocketfuel` turns **10 mixed fuel into 1 rocket fuel** in a chemical plant. This costs **750 flyash per rocket fuel**, now competing with 750 science packs. One fully supplied unfiltered Fatmice needs 25 minutes to collect that ash; a filtered capture/washer pair needs 20 minutes 50 seconds. Reserve science feed first and route only surplus ash to fuel. Normal rocket fuel remains available.

Orbital manufacturing later offers local variants using Durotal structures and Yuoki chips. You can launch before completing every optional Yuoki discipline by using the vanilla component recipes. Launching and interplanetary travel still use normal Space Age platform rules; this addon does not conjure a rescue platform.

## Persistent endgame use

Quinityn research data can only be manufactured on Quinityn. Export it to a central research world, or import the other sciences and run labs locally.

Two technologies repeat indefinitely:

- **Quinityn extraction productivity:** +10 percentage points of mining productivity each level.
- **Yuoki plasma amplification:** +10 percentage points of plasma ammunition damage each level.

Each level costs `1000 × 1.5^(level − 1)` units. Each unit takes 60 seconds at base research speed and consumes two Quinityn packs plus one each of red, green, blue, purple, yellow and space science. Neither benefit runs into a recipe-productivity cap. Continuous planet science production remains useful after all finite technology is complete.

## Existing saves and compatibility

New and existing forces are reconciled on configuration changes. Already researched Quinityn unlocks are retained. Unrelated recipe flags are preserved. A force already physically on the planet receives its survey; a new or unvisited force remains gated. Native force-merge research behavior is followed.

This development revision of 0.1.0 changes newly generated chunks. Already explored terrain and existing ore amounts are preserved; generate a new map to evaluate the revised starter layout. Placed separators retain their IDs and become primitive Cimotas. Move science production into a Yuoki factory and supply flyash. Existing completed science research is preserved. New forces must mine a Quinityn rock; new research separates Fatmice and filters from the old Engines unlock. Existing generated chunks remain unchanged: use a fresh Quinityn surface to see its new rock placement settings.

Adding the mod does not erase previously built Yuoki machines, items or ore patches from an existing save. Existing stock and queued machine crafting are not confiscated. For the intended discovery balance, use a save that has not already established Yuoki industry. The upstream optional starting suit is forced off because it bypasses the visit gate.

The supported baseline is the required Yuoki/Engines/Space Age set. Other overhaul mods, separate Yuoki tech-tree mods, alternative-start mods and later dependency revisions need separate compatibility testing.

### Updating an existing development save

Completed technologies stay completed. Recipes moved into the new upgrade technologies require those new technologies to be researched; this deliberately replaces the old bulk unlocks. Existing buildings and items remain. Discovery and arrival are required for a new force; debug teleporting an undiscovered force is not a supported starting-planet mode.
