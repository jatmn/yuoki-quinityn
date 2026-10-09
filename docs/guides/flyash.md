# Flyash, science and clean air

[Documentation index](../README.md) · [Progression guide](progression.md)

## Discover industrial science

Only Quinityn generates **ash-coated unicomp rocks**: grey-purple versions of Nauvis big and huge rocks, retaining all 20 big and 16 huge sprite shapes. Normal mineable rock types are suppressed on Quinityn. Big rocks retain 20 stone and add 2 flyash. Huge rocks retain 24–50 stone and 24–50 coal and add 4 flyash. Ordinary rock prototypes are unchanged, including on other planets; their mining cannot trigger Quinityn science. Mining either Quinityn rock after arrival reveals science immediately, even if the factory is still far away in the production chain.

These deposits are the settled residue of the planet's former industry, an addition to this addon's interpretation of Quinityn. Keep the samples instead of throwing them into unicomp. The science recipe consumes **5 flyash per 5 packs** (one per pack). Rocks provide finite startup stock; a Fatmice supplies sustained industry while removing pollution.

## Automate collection

**Fatmice air scrubbing** is a separate 40-pack research after Power. It unlocks the Fatmice, the small electric motor and its basic components, plus the motor's MF conversion. Supply electricity, water and Mechanical Force to the unfiltered Fatmice: 60 water + 0.2 MF produces 1 flyash every 2 seconds. The motor provides MF without oil. Keep the ash output moving so the machine continues operating.

## Close the filter loop

**Reusable air filters** comes later, after Fatmice, Washing and Engines. Make filters from iron sticks, stone dust and coal dust. A filtered capture consumes a filter, 60 water and 0.2 MF in 10 seconds, removes twice the pollution while operating, and returns a dirty filter. Wash it in a dirt washer with 110 water and 8 coal dust: **1 clean filter + 6 flyash**, with no wastewater. Return the clean filter to the Fatmice. The filtered capture provides six ash per ten seconds versus five unfiltered; budget a separate washer and coal-dust supply. Keep at least two filters circulating per Fatmice, plus transport buffers, so washing does not leave capture waiting for its only filter. The unfiltered recipe remains available.

## Size the science supply

At normal quality without modules, science consumes one flyash per pack. One unfiltered Fatmice supports **30 packs/minute**; one filtered Fatmice with a dedicated washer supports **36 packs/minute**. These are nominal rates with uninterrupted power, inputs and output handling. Factory capacity and the ash supply required to keep it running are:

| Factory | Packs/minute | Unfiltered Fatmice | Filtered Fatmice + washers |
| --- | --- | --- | --- |
| C1-Factory (`ye_fassembly1`) | 120 | 4 | 4 + 4 |
| Y2-Factory (`ye_fassembly2`) | 180 | 6 | 5 + 5 |
| P3-Factory (`ye_fassembly_sp`) | 300 | 10 | 9 + 9 |

## Budget water and power

Start with one scrubber and let the first factory work intermittently. An unfiltered scrubber uses **30 water/s and 0.1 MF/s**; a filtered capture/washer pair uses **17 water/s, 0.02 MF/s and 48 coal dust/minute** (32 coal/minute through dust production). A small electric motor produces 0.4 MF/s, enough for four unfiltered scrubbers or twenty filtered ones. The Fatmice uses **1.25 MW while working**, the washer 350 kW and the motor up to 350 kW; these are machine loads before supporting processing and electricity generation.

A primitive burner Cimota provides only 25 water/s, so even one unfiltered Fatmice needs more than one separator at full speed. Boilers need water too. A single 900 kW steam engine cannot run the Fatmice at full speed: expand the power plant and water supply before scaling. The bootstrap budget proves finite materials, not full-speed simultaneous operation of every machine.

## Plan research and surplus

Power plus Fatmice needs **100 rock ash**. Reaching filters costs **460 Quinityn packs total** across Power, Fatmice, Cimota, Engines, Washing and Filters: the additional 360 ash takes 12 minutes of unfiltered capture with one fully supplied Fatmice, excluding research/construction time. All finite Quinityn research totals 31,930 Quinityn packs; the first level of either infinite technology consumes another 2,000. Scale scrubbing with labs; the capture and cleaning recipes remain unchanged.

Surplus flyash can feed the [mixed-fuel route to rocket fuel](progression.md#local-oil-and-rockets),
but every rocket fuel costs 750 ash. Reserve science feed before diverting it.

Quinityn replaces Engines' Fatmice startup toggle with these research tiers; both modes use the overhaul's 1x crafting speed and base -250 pollution/minute while active. Filter capture uses a 2x recipe emission multiplier. It does not require actual pollution as a consumed recipe input: it produces ash while running and removes pollution where present, following the upstream mechanic.
