# Tutorial coverage

All 145 Quinityn tips have native simulations; there are no text-only exceptions.
This mapping covers issue #24 and the merged gameplay/progression dependencies
#25, #26 and #29–#39. IDs below omit the common `quinityn-` tip prefix.

Issue #63 adds five conversion scenes, each visible only after its corresponding
research. The Vulcanus and Fulgora research requires that force's physical
arrival; preview scenes run on Quinityn because that is still a valid operating
location. No scene grants arrival or research to the real playing force.

| Issue | Tip | Trigger | Processes | Simulation |
| --- | --- | --- | --- | --- |
| #63 | `cimota-resources` | Mineral reconstruction | Both N4, F7 and uranium-ore directions | `tutorial-demo / cimota-resources` |
| #63 | `cimota-fluids` | Chemical conversions | Oil fractions/lubricant recovery, plastic reconstruction, UC-A2 liquefaction | `tutorial-demo / cimota-fluids` |
| #63 | `cimota-residues` | Residue recovery | Slag, dry mud, toxic dust, blue crystals and contaminated water recovery | `tutorial-demo / cimota-residues` |
| #63 | `cimota-vulcanus` | Vulcanus conversions, after physical arrival | Both calcite and tungsten-ore directions | `tutorial-demo / cimota-vulcanus` |
| #63 | `cimota-fulgora` | Fulgora conversions, after physical arrival | Both scrap and holmium-ore directions | `tutorial-demo / cimota-fulgora` |

The original Cimota scene retains its basic local conversions. Maintenance now
also demonstrates Krakon repair tools.

The simulation column names the module and stage. Recipe rows use real machines,
live prototype quantities, separate fluid ports, fuel and native input/output
inserters. Operating scenes add connected networks, construction, combat,
equipment, mining or recycling loops where crafting alone does
not teach the process. Ingredients, equipment and preview power are staged;
these are demonstrations, not empty-inventory playthroughs or throughput tests.
Long preview crafts show their final eight seconds; native regressions run the
full duration. Crusher sorting runs three consecutive crafts and removes all
four products before resetting. Upstream hidden inserters are omitted when its
cleanup option is enabled.

Broad chapters retain roadmaps, explicitly naming later technologies. The
current stage's scene teaches its own usable processes; follow the named later
tip for each subsequent branch. Industrial-science shows the discovery action
at its actual mining milestone; Manufacturing Quinityn research data demonstrates
sign and data production once the factory is also unlocked. Oil-processing shows reconstructed crude and initial refining;
Orbital demonstrates the Yuoki-derived component recipes and explains their
unlocks. It deliberately excludes vanilla rocket construction and launching.

Ordering follows prerequisite depth, with stable chapter/tier ties. Visibility
uses the research triggers below, so existing researched saves retain access.
The science-production, Y2 factory and infinite-research previews add the equipment/science
requirements they actually need. No simulation module is registered in the
real save's `control.lua`.

One native failure exposed an upstream recipe-category defect: substrat
neutralization needs two fluid inputs and two outputs, while both eligible
washers provide one of each. It now runs in a chemical plant; ingredients,
results, duration and research ownership are unchanged.

## Entry mapping

| Progression issue | Tip / stage | Visibility | Native process sequence | Simulation |
| --- | --- | --- | --- | --- |
| #29 | `accumulator-capacity` | `quinityn-accumulator-capacity` | assembling-machine-2 → y-accumulator-b; Operation: storage / y-accumulator-b | `tutorial-demo / accumulator-capacity` |
| #24 | `advanced-components` | `quinityn-advanced-components` | assembling-machine-2 → y-basic-t2-mf; assembling-machine-2 → y-chip-2; assembling-machine-2 → y-conductive-coil-1; y-heat-form-press → y_block_cold; assembling-machine-2 → y_dotzetron; assembling-machine-2 → y_structure_electric; assembling-machine-2 → yi_magnetron | `tutorial-demo / advanced-components` |
| #35 | `advanced-defense` | `quinityn-advanced-defense` | assembling-machine-2 → y-ammo-acid-2; assembling-machine-2 → y-ammo-biggun; assembling-machine-2 → y-ammo-explosiv; assembling-machine-2 → y-ammo-hohlspitz; assembling-machine-2 → y-ammo-krakon; assembling-machine-2 → y-ammo-poison; assembling-machine-2 → y_turret_gun2f12; Operation: turret / y_turret_gun2f12 | `tutorial-demo / advanced-defense` |
| #24 | `advanced-efficiency-module` | `quinityn-advanced-efficiency-module` | assembling-machine-2 → y-green-module-2 | `tutorial-demo / advanced-efficiency-module` |
| #32 | `advanced-engines` | `quinityn-advanced-engines` | assembling-machine-2 → y-ffe; y-ffe → y-mf2a; y-ffe → y-mf2b; ye_gasmotor → y-mf2c; ye_gasmotor → y-mf2d; y-ffe → y-mf2e; assembling-machine-2 → ye_gasmotor | `tutorial-demo / advanced-engines` |
| #32 | `advanced-factories` | `quinityn-advanced-factories AND (quinityn-quantum OR quinityn-utility-science)` | assembling-machine-2 → ye_fassembly2; ye_fassembly2 → quinityn-research-data | `tutorial-demo / advanced-factories` |
| #29 | `advanced-generation` | `quinityn-advanced-generation` | assembling-machine-2 → y-seg; Operation: power / y-seg | `tutorial-demo / advanced-generation` |
| #39 | `advanced-genetic-trade` | `quinityn-advanced-genetic-trade` | ye_trade_node → ye_export03; ye_trade_node → ye_export06 | `biology-demo / advanced-genetic-trade` |
| #37, #38 | `advanced-genetics` | `quinityn-advanced-genetics` | ye_dnasplicer → ye_dna_animal3; ye_meatfarm → ye_grow_animal3; ye_fassembly1 → ye_futtermittel_c; ye_meatfarm → ye_grow_animal3fast; ye_dnasplicer → ye_dna_plant4; ye_farm → ye_grow_plant2; ye_fassembly1 → ye_package_verotin; ye_fassembly1 → ye_package_carni | `biology-demo / advanced-genetics` |
| #34 | `advanced-logistics` | `quinityn-advanced-logistics` | assembling-machine-2 → y-inserter-smart; assembling-machine-2 → y-inserter-smart-long; assembling-machine-2 → y_inserter_diagonal; assembling-machine-2 → y_inserter_evade_shortL; assembling-machine-2 → y_inserter_evade_shortR; assembling-machine-2 → y_inserter_smart_LL; assembling-machine-2 → y_inserter_smart_RR; assembling-machine-2 → y_inserter_smart_leftR2; assembling-machine-2 → y_inserter_smart_rightR2; Operation: transport / y-inserter-smart; Operation: transport / y-inserter-smart-long; Operation: transport / y_inserter_diagonal; Operation: transport / y_inserter_evade_shortL; Operation: transport / y_inserter_evade_shortR; Operation: transport / y_inserter_smart_LL; Operation: transport / y_inserter_smart_RR; Operation: transport / y_inserter_smart_leftR2; Operation: transport / y_inserter_smart_rightR2 | `tutorial-demo / advanced-logistics` |
| #24 | `advanced-machining` | `quinityn-advanced-machining` | assembling-machine-2 → y_crusher2; assembling-machine-2 → y_formpress2 | `tutorial-demo / advanced-machining` |
| #24 | `advanced-modules` | `quinityn-advanced-modules` | assembling-machine-2 → y-speed-module-2 | `tutorial-demo / advanced-modules` |
| #24 | `advanced-productivity-module` | `quinityn-advanced-productivity-module` | assembling-machine-2 → y-pink-module-2 | `tutorial-demo / advanced-productivity-module` |
| #34 | `advanced-robotics` | `quinityn-advanced-robotics` | assembling-machine-2 → j_construction2-robot; assembling-machine-2 → j_logistic2-robot; Operation: robots | `tutorial-demo / advanced-robotics` |
| #29 | `advanced-storage` | `quinityn-advanced-storage` | assembling-machine-2 → y-accumulator-b-t2; assembling-machine-2 → y-accumulator-m-t2; Operation: storage / y-accumulator-b-t2; Operation: storage / y-accumulator-m-t2 | `tutorial-demo / advanced-storage` |
| #32 | `advanced-transmission` | `quinityn-advanced-transmission` | y-heat-form-press → ye_buechsenblech; foundry → ye_tranport_tube_green; foundry → ye_tranport_tube_green_splitter; foundry → ye_tranport_tube_green_underground | `tutorial-demo / advanced-transmission` |
| #37 | `agriculture` | `quinityn-agriculture` | ye_fassembly1 → ye-seed_a1; ye_farm → ye-growcorn; ye_fassembly1 → ye-seed_a2; ye_fassembly1 → ye_seed_b; ye_farm → ye_cornb; y-heat-form-press → ye-corn2fluid; chemical-plant → ye-cf2lubricant; y-crusher → ye_celluose; ye_fassembly1 → ye_synwood; ye_fassembly1 → ye_sugar; ye_fassembly1 → ye_biomixed | `biology-demo / agriculture` |
| #24 | `air-filters` | `quinityn-air-filters` | assembling-machine-2 → j-airfilter; y-electric-air-heater → j-airfilter_dirty; y-dirtwasher → j-airfilter_cleaning; Operation: filters | `tutorial-demo / air-filters` |
| #24 | `air-scrubbing` | `quinityn-air-scrubbing` | assembling-machine-2 → y-emotor-s; y-emotor-s → y-mf1c; assembling-machine-2 → y-electric-air-heater; y-electric-air-heater → y-rmvpol; Operation: scrubbing | `tutorial-demo / air-scrubbing` |
| #24 | `alloying` | `quinityn-alloying` | assembling-machine-2 → y-mixing-rich; stone-furnace → y-orange-stuff | `tutorial-demo / alloying` |
| #35 | `ammunition-cases` | `quinityn-ammunition-cases` | y-heat-form-press → y_ammo_case | `tutorial-demo / ammunition-cases` |
| #30 | `archaeology` | `quinityn-archaeology` | y-dirtwasher → y-wash-dirt; y-dirtwasher → y-wash-special | `tutorial-demo / archaeology` |
| #35 | `armor-2` | `quinityn-armor-2` | assembling-machine-2 → yi_armor_red; y-atomic-quantum-composer → yi_equip_shield_b; Operation: equipment / yi_armor_red | `tutorial-demo / armor-2` |
| #35 | `armor-3` | `quinityn-armor-3` | assembling-machine-2 → yi_armor_gold; Operation: equipment / yi_armor_gold | `tutorial-demo / armor-3` |
| #35 | `artillery-shells` | `quinityn-artillery-shells` | assembling-machine-2 → yi_artillery_shell | `tutorial-demo / artillery-shells` |
| #31 | `asteroid-crushing` | `quinityn-asteroid-crushing` | crusher → j_crushing_to_f7; crusher → j_crushing_to_n4 | `tutorial-demo / asteroid-crushing` |
| #24 | `basic-factory` | `quinityn-basic-factory` | assembling-machine-2 → y-basic-t1-mf; assembling-machine-2 → ye_fassembly1 | `tutorial-demo / basic-factory` |
| #29 | `big-generation` | `quinityn-big-generation` | assembling-machine-2 → y-beg; Operation: power / y-beg | `tutorial-demo / big-generation` |
| #31 | `biological-feedstock` | `quinityn-biological-feedstock` | y-crusher → ye_biofuel; y-crusher → ye_granulate_corn; y-crusher → ye_granulate_trifitan; y-crusher → ye_granulate_vuger | `tutorial-demo / biological-feedstock` |
| #26 | `bootstrap` | `quinityn-arrival` | character → quinityn-hand-sort; character → quinityn-iron; character → quinityn-copper; character → quinityn-carbon; character → quinityn-stone; character → quinityn-timber; character → quinityn-burner-separator; Operation: mining; Operation: mining / ash rock; Operation: water | `tutorial-demo / bootstrap` |
| #24 | `briefing` | `planet-discovery-quinityn` | Operation: landscape | `tutorial-demo / briefing` |
| #34 | `bulk-storage` | `quinityn-bulk-storage` | assembling-machine-2 → y_sc44; Operation: chest / y_sc44 | `tutorial-demo / bulk-storage` |
| #39 | `chemical-science` | `quinityn-chemical-science` | y-atomic-constructor → y_chemical_science | `biology-demo / chemical-science` |
| #35 | `chemical-weapons` | `quinityn-chemical-weapons` | assembling-machine-2 → y_ammo_flame; assembling-machine-2 → y_turret_flame; Operation: turret / y_turret_flame | `tutorial-demo / chemical-weapons` |
| #24 | `cimota` | `quinityn-cimota` | assembling-machine-2 → y-atomic-constructor; y-atomic-constructor → y-liquid2uc; y-atomic-constructor → y-ac-stone2uc; y-atomic-constructor → y-ac-wood2uc; y-atomic-constructor → y-ac-uc2coal; y-atomic-constructor → y-ac-uc2iron-ore; y-atomic-constructor → y-ac-uc2copper-ore; y-atomic-constructor → y-ac-uc2wood; y-atomic-constructor → y-uc2crudeoil | `tutorial-demo / cimota` |
| #24 | `combined-module` | `quinityn-combined-module` | assembling-machine-2 → y_modul_red2 | `tutorial-demo / combined-module` |
| #24 | `compacting` | `quinityn-compacting` | y-heat-form-press → y-raw-fuelnium; y-heat-form-press → y-unicomp-raw | `tutorial-demo / compacting` |
| #29 | `compressed-fuel` | `quinityn-compressed-fuel` | y-heat-form-press → y-coal-stack | `tutorial-demo / compressed-fuel` |
| #31 | `crystal-processing` | `quinityn-crystal-processing` | assembling-machine-2 → y_mixer_emu; assembling-machine-2 → y_hppump; assembling-machine-2 → y_crystalizer; assembling-machine-2 → y_trockner; y_mixer_emu → y_emulsion; y_hppump → y_richemulsion; y_trockner → y_crystal_dust; y_crystalizer → y_chunks1; y_crystalizer → y_chunks2 | `tutorial-demo / crystal-processing` |
| #35 | `defense` | `quinityn-defense` | y-heat-form-press → y-bullet-case; assembling-machine-2 → y-mud-wall; assembling-machine-2 → y_turret_gun1f12; assembling-machine-2 → y_wood_wall; assembling-machine-2 → yi_cannon_shell; Operation: turret / y_turret_gun1f12 | `tutorial-demo / defense` |
| #35 | `durotal-walls` | `quinityn-durotal-walls` | assembling-machine-2 → y-rare-wall-basic | `tutorial-demo / durotal-walls` |
| #24 | `efficiency-module` | `quinityn-efficiency-module` | assembling-machine-2 → y-green-module-1 | `tutorial-demo / efficiency-module` |
| #29 | `electric-water` | `quinityn-electric-water` | assembling-machine-2 → y-water-gen-e; y-water-gen-e → y-water-gen-fluid | `tutorial-demo / electric-water` |
| #24 | `electronics` | `quinityn-electronics` | assembling-machine-2 → y-chip-1; assembling-machine-2 → y-conductive-wire-1; assembling-machine-2 → y_chip_plate | `tutorial-demo / electronics` |
| #24 | `endgame` | `quinityn-mastery AND quinityn-orbital AND production-science-pack AND utility-science-pack AND space-science-pack` | ye_fassembly1 → quinityn-technic-sign; ye_fassembly1 → quinityn-research-data; Operation: research | `tutorial-demo / endgame` |
| #29 | `energy-storage` | `quinityn-energy-storage` | assembling-machine-2 → y-accumulator-m; assembling-machine-2 → y-battery-rip1; assembling-machine-2 → y-battery-single-use1; assembling-machine-2 → y-battery-single-use2; assembling-machine-2 → y-battery-single-use3; assembling-machine-2 → y_blocked_capa; Operation: storage / y-accumulator-m | `tutorial-demo / energy-storage` |
| #32 | `engines` | `quinityn-engines` | assembling-machine-2 → y-1stirling-engine; y-sfe → y-mf1a; y-sfe → y-mf1a1; y-sfe → y-mf1f; assembling-machine-2 → y-mftrans-shaft; assembling-machine-2 → y-mftrans-shaft-ground; assembling-machine-2 → y-mftrans-shaft-ground-red; assembling-machine-2 → y-mftrans-shaft-red; y-mwater-pump → y-mfwater; assembling-machine-2 → y-mwater-pump; assembling-machine-2 → y-sfe; assembling-machine-2 → y-waste-condense; assembling-machine-2 → y_flowcheck_10; assembling-machine-2 → y_gauge_analog; chemical-plant → y_mixedfuel2rocketfuel; assembling-machine-2 → ye_tranport_tube_orange; assembling-machine-2 → ye_tranport_tube_orange_splitter; assembling-machine-2 → ye_tranport_tube_orange_underground; Operation: mf; Operation: tank / y_flowcheck_10 | `tutorial-demo / engines` |
| #30 | `excavation` | `quinityn-excavation` | y-underground-drill → y-digfdirt; assembling-machine-2 → y-mining-drill-e2; assembling-machine-2 → y-underground-drill | `tutorial-demo / excavation` |
| #34 | `expanded-storage` | `quinityn-expanded-storage` | assembling-machine-2 → y_c22; Operation: chest / y_c22 | `tutorial-demo / expanded-storage` |
| #29 | `field-repair` | `quinityn-field-repair` | assembling-machine-2 → y-repair-durotal | `tutorial-demo / field-repair` |
| #32 | `fluid-handling` | `quinityn-fluid-handling` | assembling-machine-2 → ye_can_co_empty; assembling-machine-2 → ye_can_eth_empty; assembling-machine-2 → ye_can_ho_empty; assembling-machine-2 → ye_can_lub_empty; assembling-machine-2 → ye_can_mf_empty; assembling-machine-2 → ye_can_petrol_empty; assembling-machine-2 → ye_can_sa_empty; assembling-machine-2 → ye_can_uc_empty; ye_canmachine → ye_canister; stone-furnace → ye_canister2plates_smelt; assembling-machine-2 → ye_canmachine; assembling-machine-2 → ye_ice_container_empty; ye_icemaker → ye_ice_container_filled; assembling-machine-2 → ye_icemaker; ye_canmachine → ye_sealing | `tutorial-demo / fluid-handling` |
| #33 | `fluid-storage-50k` | `quinityn-fluid-storage-50k` | assembling-machine-2 → y-tank-4500; Operation: tank / y-tank-4500 | `tutorial-demo / fluid-storage-50k` |
| #33 | `fluid-storage-80k` | `quinityn-fluid-storage-80k` | assembling-machine-2 → y-tank-8000; Operation: tank / y-tank-8000 | `tutorial-demo / fluid-storage-80k` |
| #29 | `flywheel-storage` | `quinityn-flywheel-storage` | assembling-machine-2 → y-ups-flywheel-b; Operation: storage / y-ups-flywheel-b | `tutorial-demo / flywheel-storage` |
| #35 | `forcefield-walls` | `quinityn-forcefield-walls` | assembling-machine-2 → y-wall-forcefield | `tutorial-demo / forcefield-walls` |
| #24 | `foundation` | `quinityn-foundation` | y-heat-form-press → quinityn-foundation; Operation: foundation | `tutorial-demo / foundation` |
| #31 | `foundry-melting` | `quinityn-foundry-melting` | foundry → yi-molten-copper; foundry → yi-molten-iron | `tutorial-demo / foundry-melting` |
| #29 | `fuel-processing` | `quinityn-fuel-processing` | assembling-machine-2 → y-fuel-reactor | `tutorial-demo / fuel-processing` |
| #39 | `genetic-trade` | `quinityn-genetic-trade` | ye_trade_node → ye_export01; ye_trade_node → ye_export02; ye_trade_node → ye_export05 | `biology-demo / genetic-trade` |
| #37, #38 | `genetics` | `quinityn-genetics` | y-atomic-quantum-composer → ye_dnasplicer; ye_dnasplicer → ye_dna_animal1; ye_dnasplicer → ye_dna_animal2; ye_meatfarm → ye_grow_animal2; ye_dnasplicer → ye_dna_plant0; ye_dnasplicer → ye_dna_plant3; ye_dnasplicer → ye_dna_plant1; ye_farm → ye_grow_plant1; ye_fassembly1 → ye_package_omtrinit; ye_fassembly1 → ye_package_substratin; ye_fassembly1 → ye_package_spliced_cells | `biology-demo / genetics` |
| #35 | `hardic-walls` | `quinityn-hardic-walls` | assembling-machine-2 → y_wall22_hardic | `tutorial-demo / hardic-walls` |
| #29 | `high-capacity-boiler` | `quinityn-high-capacity-boiler` | assembling-machine-2 → y-boiler-iv; Operation: boiler / y-boiler-iv | `tutorial-demo / high-capacity-boiler` |
| #29 | `high-flow-storage` | `quinityn-high-flow-storage` | assembling-machine-2 → y_compensator_25; Operation: storage / y_compensator_25 | `tutorial-demo / high-flow-storage` |
| #29 | `high-pressure-steam-turbine` | `quinityn-high-pressure-steam-turbine` | assembling-machine-2 → y-steam-turbine; Operation: power / y-steam-turbine | `tutorial-demo / high-pressure-steam-turbine` |
| #32 | `high-temperature-generation` | `quinityn-high-temperature-generation` | assembling-machine-2 → ye_tfmw_generator-s; assembling-machine-2 → ye_tfmw_turbine-s; Operation: power / ye_tfmw_generator-s; Operation: power / ye_tfmw_turbine-s | `tutorial-demo / high-temperature-generation` |
| #29 | `huge-generation` | `quinityn-huge-generation` | assembling-machine-2 → y-heg; Operation: power / y-heg | `tutorial-demo / huge-generation` |
| #37, #38 | `husbandry` | `quinityn-husbandry` | ye_fassembly1 → ye_dna_animal0; ye_meatfarm → ye_grow_animal_a; ye_pool → ye_grow_fish1; ye_canmachine → yie_bloodfrommeat; ye_canmachine → ye_can_blood_fill; assembling-machine-2 → ye_can_blood_empty; assembling-machine-2 → ye_can_slurry_empty; assembling-machine-2 → ye_can_veg_empty; ye_pool → ye_pool_slurry; ye_farm → ye-growcorn_ws; ye_farm → ye_cornb_ws; stone-furnace → ye_cooking_meat; ye_fassembly1 → ye_package_r_meat; ye_fassembly1 → ye_package_c_meat | `biology-demo / husbandry` |
| #37, #38 | `industrial-biology` | `quinityn-industrial-biology` | ye_dnasplicer → ye_dna_animal4; ye_meatfarm → ye_grow_animal4; stone-furnace → yie_pureiron; ye_fassembly1 → ye_package_organic | `biology-demo / industrial-biology` |
| #39 | `industrial-biology-trade` | `quinityn-industrial-biology-trade` | ye_trade_node → ye_export04 | `biology-demo / industrial-biology-trade` |
| #24 | `industrial-science` | `quinityn-industrial-science` | Operation: mining / ash rock | `tutorial-demo / industrial-science` |
| #36 | `infusion` | `quinityn-infusion` | assembling-machine-2 → y-alien-infuser; y-alien-infuser → y-infused-mud; y-alien-infuser → y-infused-uca2; y-alien-infuser → y_quantrinum_infusion | `tutorial-demo / infusion` |
| #34 | `large-storage` | `quinityn-large-storage` | assembling-machine-2 → y_cg33; Operation: chest / y_cg33 | `tutorial-demo / large-storage` |
| #35 | `laser-turret` | `quinityn-laser-turret` | assembling-machine-2 → y_turret_laser22f12; Operation: turret / y_turret_laser22f12 | `tutorial-demo / laser-turret` |
| #34 | `logistic-bunker` | `quinityn-logistic-bunker` | assembling-machine-2 → y-rare-m1bunker-log; Operation: robots / roboport | `tutorial-demo / logistic-bunker` |
| #34 | `logistic-provider-capacity` | `quinityn-logistic-provider-capacity` | assembling-machine-2 → y_pc22; Operation: robots / roboport | `tutorial-demo / logistic-provider-capacity` |
| #34 | `logistic-requests` | `quinityn-logistic-requests` | assembling-machine-2 → j-dl-buffer; assembling-machine-2 → j-dl-request; Operation: robots; Operation: robots | `tutorial-demo / logistic-requests` |
| #34 | `logistic-storage` | `quinityn-logistic-storage` | assembling-machine-2 → j-dl-provider; assembling-machine-2 → y-rare-chest-log; Operation: robots / roboport; Operation: robots / roboport | `tutorial-demo / logistic-storage` |
| #34 | `logistics` | `quinityn-logistics` | assembling-machine-2 → y-inserter-fast; assembling-machine-2 → y-inserter-s4; assembling-machine-2 → y_sc11; Operation: transport / y-inserter-fast; Operation: transport / y-inserter-s4 | `tutorial-demo / logistics` |
| #24 | `maintenance` | `quinityn-maintenance` | y_maintance_workshop → y_drillhead_repair; assembling-machine-2 → y_maintance_workshop; y_maintance_workshop → y_toolhead_repair | `tutorial-demo / maintenance` |
| #39 | `mastery` | `quinityn-mastery` | assembling-machine-2 → y_boiler4_mc; assembling-machine-2 → y_boiler4_tech; assembling-machine-2 → y_mc_dirtwasher; assembling-machine-2 → y_mc_e2_mining_drill; assembling-machine-2 → y_mc_underground_drill; assembling-machine-2 → y_obninsk_mc; assembling-machine-2 → y_steam_turbine_gr; assembling-machine-2 → y_steam_turbine_mc; assembling-machine-2 → ye_green_ultimate; ye_green_ultimate → y_greensign_ulti; ye_green_ultimate → y_unlimited_wood; assembling-machine-2 → ye_science_ultimate; ye_fassembly1 → y_trade_ultimate; y_trade_ultimate → ypfw_trader_sign | `biology-demo / mastery` |
| #26 | `materials` | `quinityn-materials` | y-crusher → quinityn-hand-sort (3 consecutive crafts); y-crusher → y-crush-unicomp-raw; y-crusher → y-crush-fuel-raw | `tutorial-demo / materials` |
| #32 | `medium-electric-motor` | `quinityn-medium-electric-motor` | assembling-machine-2 → ye_emotor_m; ye_emotor_m → ye_motorm_mf | `tutorial-demo / medium-electric-motor` |
| #29 | `medium-generation` | `quinityn-medium-generation` | assembling-machine-2 → y-meg-s; Operation: power / y-meg-s | `tutorial-demo / medium-generation` |
| #32 | `medium-mf-pump` | `quinityn-medium-mf-pump` | ye_wpump_m → y_mpump_mf; ye_wpump_m → y_mpump_water; assembling-machine-2 → ye_wpump_m | `tutorial-demo / medium-mf-pump` |
| #32 | `mf-heat-generator` | `quinityn-mf-heat-generator` | ye_mfheatmotor_m → ye_mf_mfheatmotor_m; assembling-machine-2 → ye_mfheatmotor_m | `tutorial-demo / mf-heat-generator` |
| #39 | `military-science` | `quinityn-military-science` | y-atomic-constructor → y_military_science | `biology-demo / military-science` |
| #29 | `mixed-fuel` | `quinityn-mixed-fuel` | y-heat-form-press → y-coaldust-mixing; y-heat-form-press → y-mixfuel-load | `tutorial-demo / mixed-fuel` |
| #24 | `modules` | `quinityn-modules` | assembling-machine-2 → y-speed-module-1 | `tutorial-demo / modules` |
| #24 | `oil-processing` | `quinityn-oil-processing AND oil-processing` | y-atomic-constructor → y-uc2crudeoil; oil-refinery → basic-oil-processing | `tutorial-demo / oil-processing` |
| #24 | `orbital` | `quinityn-orbital` | assembling-machine-2 → quinityn-low-density-structure; assembling-machine-2 → quinityn-processing-unit; assembling-machine-2 → y-waste-condense; chemical-plant → y_mixedfuel2rocketfuel | `tutorial-demo / orbital` |
| #32 | `p3-factory` | `quinityn-p3-factory` | assembling-machine-2 → ye_fassembly_sp; ye_fassembly_sp → quinityn-research-data | `tutorial-demo / p3-factory` |
| #38 | `packaging` | `quinityn-packaging` | ye_fassembly1 → ye_package_empty; y-heat-form-press → ye_buechse_empty; ye_canmachine → ye_buechse_gelb; ye_fassembly1 → ye_ice_container_empty; ye_icemaker → ye_ice_container_filled; ye_fassembly1 → ye_package_fish1 | `biology-demo / packaging` |
| #33 | `plant-infrastructure` | `quinityn-plant-infrastructure` | assembling-machine-2 → y-pipe-ec; assembling-machine-2 → y-pipe-h; assembling-machine-2 → y-pipe-hc; assembling-machine-2 → y-pipe-to-ground-ec; assembling-machine-2 → y-pipe-to-ground-hc; assembling-machine-2 → y-pipe-v; assembling-machine-2 → y-powerlamp; assembling-machine-2 → y-substation-m; assembling-machine-2 → y-tank-1000; assembling-machine-2 → y-tinylamp; assembling-machine-2 → y_lampe_44basement_a; assembling-machine-2 → y_lampe_44basement_b; assembling-machine-2 → y_lampe_66basement; assembling-machine-2 → y_lampe_corner; assembling-machine-2 → y_lampe_neotix; assembling-machine-2 → y_lampe_yuoki; assembling-machine-2 → y_signal_pole; assembling-machine-2 → yi_pipe_green; assembling-machine-2 → yi_pipe_underground_green; Operation: tank / y-tank-1000 | `tutorial-demo / plant-infrastructure` |
| #35 | `plasma-mines` | `quinityn-plasma-mines` | assembling-machine-2 → yi_mine_plasma | `tutorial-demo / plasma-mines` |
| #35 | `plasma-weapons` | `quinityn-plasma-weapons` | assembling-machine-2 → y_ammo_plasma; assembling-machine-2 → y_turret_plasma; Operation: turret / y_turret_plasma | `tutorial-demo / plasma-weapons` |
| #35 | `poison-mines` | `quinityn-poison-mines` | assembling-machine-2 → yi_mine_impact | `tutorial-demo / poison-mines` |
| #29 | `power` | `quinityn-power` | y-heat-form-press → y-coal-brikett; y-crusher → y-coal-dust; assembling-machine-2 → y-heat-pipe; assembling-machine-2 → y-notfall-generator-s2; assembling-machine-2 → y-wooden-brikett; assembling-machine-2 → y_bg-1; Operation: power / y-notfall-generator-s2; Operation: power / y_bg-1 | `tutorial-demo / power` |
| #35 | `powered-armor` | `quinityn-powered-armor` | assembling-machine-2 → yi_ammo_energie; assembling-machine-2 → yi_armor_gray; y-atomic-quantum-composer → yi_equip_battery_a; y-atomic-quantum-composer → yi_equip_legs_a; y-atomic-quantum-composer → yi_equip_roboport; y-atomic-quantum-composer → yi_equip_shield_a; y-atomic-quantum-composer → yi_lasergun; y-atomic-quantum-composer → yi_minigun; y-atomic-quantum-composer → yi_pld_equipment; Operation: equipment / yi_armor_gray | `tutorial-demo / powered-armor` |
| #24 | `pressing` | `quinityn-pressing` | assembling-machine-2 → y-heat-form-press; y-heat-form-press → y-smelt-crush-res1; y-heat-form-press → y-smelt-crush-res2 | `tutorial-demo / pressing` |
| #39 | `production-science` | `quinityn-production-science` | y-atomic-constructor → y_production_science | `biology-demo / production-science` |
| #24 | `productivity-module` | `quinityn-productivity-module` | assembling-machine-2 → y-pink-module-1 | `tutorial-demo / productivity-module` |
| #24 | `quality-module` | `quinityn-quality-module` | assembling-machine-2 → y-quality-module-1 | `tutorial-demo / quality-module` |
| #36 | `quantum` | `quinityn-quantum` | assembling-machine-2 → y-atomic-quantum-composer; y-atomic-quantum-composer → y-quantrinum; y-atomic-quantum-composer → y-crystal-cnd; y-atomic-quantum-composer → y_data_crystal; y-atomic-quantum-composer → yi_radar; assembling-machine-2 → yi-monument1; assembling-machine-2 → y_repair_quantrinum | `tutorial-demo / quantum` |
| #36 | `quantum-modules` | `quinityn-quantum-modules` | assembling-machine-2 → y-pink-module-3 | `tutorial-demo / quantum-modules` |
| #36 | `quantum-power` | `quinityn-quantum-power` | y-atomic-quantum-composer → y-accumulator-b-tx; y-atomic-quantum-composer → y-accumulator-crystal-m; y-quantrinum-reactor → y-mf1-q1; y-quantrinum-reactor → y-mf1-q2; y-quantrinum-reactor → y-mf1-q3; assembling-machine-2 → y-obninsk-turbine; assembling-machine-2 → y-quantrinum-charge; assembling-machine-2 → y-quantrinum-reactor; assembling-machine-2 → y-substation-h; assembling-machine-2 → y_alien_solar2; y-dirtwasher → y_mox2fuel; y-atomic-quantum-composer → y_mox2fuelsplited; y_moxmixer → y_mox2mixed; y-obninsk-reactor → y_reactor_mox2; ye_rheinsberg → ye_rheins_HT; ye_rheinsberg → ye_rheins_LT; ye_rheinsberg → ye_rheins_MT; assembling-machine-2 → ye_rheinsberg; Operation: storage / y-accumulator-b-tx; Operation: storage / y-accumulator-crystal-m; Operation: power / y-obninsk-turbine; Operation: power / y_alien_solar2 | `tutorial-demo / quantum-power` |
| #33, #36 | `quantum-utilities` | `quinityn-quantum-utilities` | assembling-machine-2 → ye_center; y-atomic-quantum-composer → yi_beacon | `tutorial-demo / quantum-utilities` |
| #29 | `reactors` | `quinityn-reactors` | y-heat-form-press → yi_graphite; assembling-machine-2 → y_moxmixer; y_moxmixer → y_mox1mixed; assembling-machine-2 → y-obninsk-reactor; y-obninsk-reactor → y_reactor_mox1; y-dirtwasher → y_mox1fuel; y-obninsk-reactor → y_reactor_mf1; assembling-machine-2 → y-rare-wall-adv | `tutorial-demo / reactors` |
| #31 | `refining` | `quinityn-refining` | y-dirtwasher → y-sulfuric-acid; assembling-machine-2 → y-water-gen; y-water-gen → y-water-gen-fluid; assembling-machine-2 → y_catalyst_bp; assembling-machine-2 → y_catalyst_ft; chemical-plant → y_coal2liquid; chemical-plant → y_ft; y-crusher → y_granulate_wood; chemical-plant → y_rawsyngas1; chemical-plant → y_rawsyngas2; chemical-plant → y_refinehydrogen; chemical-plant → y_regcatbp; chemical-plant → y_regcatft | `tutorial-demo / refining` |
| #39 | `reputation` | `quinityn-reputation` | ye_fassembly1 → y-fame-gen; y-fame-gen → y-fame; y-fame-gen → y_fame_tech | `biology-demo / reputation` |
| #32 | `research-center` | `quinityn-research-center` | yie_science_blue_gen → ye_science_blue; assembling-machine-2 → yie_science_blue_gen | `tutorial-demo / research-center` |
| #29 | `residue-fuel` | `quinityn-residue-fuel` | y-heat-form-press → y_mud2solidfuel | `tutorial-demo / residue-fuel` |
| #34 | `robot-network-expansion` | `quinityn-robot-network-expansion` | y-atomic-quantum-composer → j_yi_roboport1; Operation: robots / j_yi_roboport1 | `tutorial-demo / robot-network-expansion` |
| #34 | `robot-production` | `quinityn-robot-production` | assembling-machine-2 → yi_logistic-robot; Operation: robots | `tutorial-demo / robot-production` |
| #34 | `robotics` | `quinityn-robotics` | assembling-machine-2 → yi_construction-robot; assembling-machine-2 → yi_logistic-robot; y-atomic-quantum-composer → yi_roboport; Operation: robots | `tutorial-demo / robotics` |
| #24 | `science-module` | `quinityn-science-module` | assembling-machine-2 → y_modul_science | `tutorial-demo / science-module` |
| #30 | `slag-materials` | `quinityn-slag-materials` | y-crusher → y_slag_granulate; y-heat-form-press → y_slag_brick; stone-furnace → y_slag_brick_burn; y-crusher → y_steinmehl | `tutorial-demo / slag-materials` |
| #30 | `slag-paving` | `quinityn-slag-paving` | y-heat-form-press → y_tile_slagbricks; y-heat-form-press → y_tile_slagfilled; y-heat-form-press → y_tile_slagpattern | `tutorial-demo / slag-paving` |
| #31 | `slurry-syngas` | `quinityn-slurry-syngas` | chemical-plant → ye_slurry2ethanol | `tutorial-demo / slurry-syngas` |
| #29 | `solar-collector` | `quinityn-solar-collector` | assembling-machine-2 → y_alien_solar; Operation: power / y_alien_solar | `tutorial-demo / solar-collector` |
| #29 | `solar-dish` | `quinityn-solar-dish` | assembling-machine-2 → y-stirling-solar-dish; Operation: power / y-stirling-solar-dish | `tutorial-demo / solar-dish` |
| #39 | `space-science` | `quinityn-space-science` | y-atomic-constructor → y_space_science | `biology-demo / space-science` |
| #32 | `steam-overheating` | `quinityn-steam-overheating` | ye_overheater → ye_makesteam; assembling-machine-2 → ye_overheater | `tutorial-demo / steam-overheating` |
| #32 | `steam-turbine` | `quinityn-steam-turbine` | ye_sturbine → ye_steam2mf; ye_sturbine → ye_steam3mf; assembling-machine-2 → ye_sturbine | `tutorial-demo / steam-turbine` |
| #24 | `structures` | `quinityn-structures` | assembling-machine-2 → y-bluegear; assembling-machine-2 → y_structure_element; assembling-machine-2 → y_structure_vessel | `tutorial-demo / structures` |
| #32 | `substrat-neutralization` | `quinityn-substrat-neutralization` | chemical-plant → ye_neutralisatzion | `tutorial-demo / substrat-neutralization` |
| #25 | `surplus` | `quinityn-surplus` | quinityn-burner-separator → quinityn-stone-to-uc; quinityn-burner-separator → quinityn-wood-to-uc; quinityn-burner-separator → quinityn-uc-to-coal; quinityn-burner-separator → quinityn-uc-to-iron; quinityn-burner-separator → quinityn-uc-to-copper | `tutorial-demo / surplus` |
| #31 | `thermal-smelting` | `quinityn-thermal-smelting` | y-heat-form-press → y_block_cold; assembling-machine-2 → y_charger; assembling-machine-2 → y_smelter; y_charger → y_block_heat; y_smelter → y_hps_pureiron; y_smelter → y_hps_purecopper; y_smelter → y_hps_steel; Operation: thermal | `tutorial-demo / thermal-smelting` |
| #24 | `tooling` | `quinityn-tooling` | y-crusher → y-crush-blue_whead; y-crusher → y-crush-green_whead; y-underground-drill → y-digfdirt2; assembling-machine-2 → y_drillhead; y-dirtwasher → y_pure_copper_wtool; y-dirtwasher → y_pure_iron_wtool; assembling-machine-2 → y_toolhead | `tutorial-demo / tooling` |
| #39 | `trade` | `quinityn-trade` | ye_fassembly1 → y-stargate; ye_fassembly1 → ye_trade_node; ye_trade_node → ye_buechse_gelb_export; ye_trade_node → yie_import_sealing; ye_trade_node → yie_import_blech_blau; ye_trade_node → y_exchange_b1; ye_trade_node → y_exchange_b2; ye_trade_node → y_exchange_b3; ye_trade_node → y_exchange_b4; ye_trade_node → yi_slayerfame; ye_trade_node → y-fuel-cell-c | `biology-demo / trade` |
| #37, #38 | `trade-biology` | `quinityn-trade-biology` | ye_trade_node → ye_dna_fish2; ye_pool → ye_fish2; ye_trade_node → ye_futtermittel_a; ye_trade_node → ye_futtermittel_b; ye_fassembly1 → ye_futtermittel_d; ye_pool → ye_fish3; ye_pool → ye_fish4; ye_fassembly1 → ye_smoker; ye_smoker → ye_smoked_meat; ye_smoker → ye_smoked_fish; ye_fassembly1 → ye_package_fish2; ye_canmachine → ye_buechse_blau; ye_canmachine → ye_buechse_braun; ye_canmachine → ye_buechse_rosa; ye_canmachine → ye_buechse_white; ye_trade_node → ye_buechse_blau_export; ye_trade_node → ye_buechse_fleisch_export; ye_trade_node → ye_buechse_rosa_export; ye_trade_node → ye_buechse_weiss_export; ye_trade_node → ye_export_fish1; ye_trade_node → ye_export_fish2; ye_trade_node → ye_tradeblood; ye_trade_node → ye_trademeat1; ye_trade_node → ye_trademeat2 | `biology-demo / trade-biology` |
| #24 | `ultimate-efficiency-module` | `quinityn-ultimate-efficiency-module` | ye_green_ultimate → y_modul_green_op | `tutorial-demo / ultimate-efficiency-module` |
| #24 | `unicomp` | `quinityn-arrival` | Operation: water; Operation: disposal | `tutorial-demo / unicomp` |
| #30 | `unicomp-compression` | `quinityn-unicomp-compression` | y-heat-form-press → y-press-richdust | `tutorial-demo / unicomp-compression` |
| #39 | `utility-science` | `quinityn-utility-science` | y-atomic-constructor → y_high-tech_science; ye_fassembly1 → ye_createbluesigns | `biology-demo / utility-science` |
| #35 | `walker-1` | `quinityn-walker-1` | y-atomic-quantum-composer → yi_equip_generator_a; assembling-machine-2 → yi_walker_a; Operation: equipment / yi_walker_a | `tutorial-demo / walker-1` |
| #35 | `walker-2` | `quinityn-walker-2` | assembling-machine-2 → yi_walker_c; Operation: equipment / yi_walker_c | `tutorial-demo / walker-2` |
| #30 | `washing` | `quinityn-washing` | assembling-machine-2 → y-dirtwasher; y-dirtwasher → y-pure-iron; y-dirtwasher → y-pure-copper; stone-furnace → y-refined-iron; stone-furnace → y-refined-copper; y-heat-form-press → y-release-cwater; y-heat-form-press → y-filtering-dust; y-heat-form-press → y-pressed_dry_mud | `tutorial-demo / washing` |
| #34 | `wide-logistic-requests` | `quinityn-wide-logistic-requests` | assembling-machine-2 → y_bc22; assembling-machine-2 → y_rc22; Operation: robots; Operation: robots | `tutorial-demo / wide-logistic-requests` |
| #35 | `zero-time-weapon` | `quinityn-zero-time-weapon` | assembling-machine-2 → y-weapon-ztt; Operation: turret / y-weapon-ztt | `tutorial-demo / zero-time-weapon` |
| #24 | `science-production` | `quinityn-industrial-science AND quinityn-basic-factory` | ye_fassembly1 → quinityn-technic-sign; ye_fassembly1 → quinityn-research-data | `tutorial-demo / science-production` |

## Validation routes

`tools/test.py` exports the callbacks from the engine-loaded tip prototypes.
The existing biology fixture covers every step of its 18 stages and repeats
the first step; the tutorial fixture runs two complete cycles of the other
122 scenes in bounded batches. Both exercise a native save reload, with real
recipe completion, item/fluid transport and operation checks.
The player force must remain undiscovered and unchanged by these isolated
demonstration forces. The native loader and localization checks cover all IDs.

Graphical acceptance additionally requires inspecting every scene for readable
framing and meaningful action, opening the discovery briefing before visiting,
and checking native Tips visibility/reopening around research milestones.
Record actual engine/dependency revisions and graphical results in the PR;
prototype presence and headless completion do not establish visual quality.
Runtime resources live under `scripts/` and `prototypes/`, which are packaged;
this document and the regression fixtures are deliberately excluded from ZIPs.
