# Biology, trade and science demonstration coverage

This covers the #37, #38 and #39 portions of
[#24](https://github.com/jatmn/yuoki-quinityn/issues/24), covering 18 affected
tips. Other tutorial families and the discovery preview remain. The Mastery
addition demonstrates its affected Merchant Sign manufacture; demonstrations
for its other, unchanged machine upgrades remain in #24.

Each tip unlocks at the technology in its row. The chapter tips retain their
broader roadmap text; their animation teaches the currently available stage.
Later processes have their own research-triggered tips.

| Final technology / tip | Native process sequence | Machines and operating requirements |
| --- | --- | --- |
| `quinityn-agriculture` / Crops, animals and DNA | Initial corn seed → corn → replacement seeds; Vugar seed → Vugar; corn oil → lubricant; cellulose, synthetic wood, sugar and organic feed | C1 Factory, Framed Farm, Form Press, chemical plant and crusher. Water and Mechanical Force use separate ports; press/crusher need fuel. Reserve corn for new seeds. |
| `quinityn-packaging` / Industrial packaging | Empty package; empty cans → canned corn; empty coolant containers → filled coolant containers → basic fish package | C1 Factory, Form Press, Can Machine and Ice Maker. Requires Agriculture and Fluid handling. Canned corn is a local early export; basic fish needs a brought specimen. The press needs fuel; canning and cooling need Mechanical Force. |
| `quinityn-husbandry` / Animal husbandry and aquaculture | Initial DNA from science packs; meat breeding; basic fish breeding; blood extraction, slurry dilution, slurry-fed crops and cooking | C1 Factory, Meat Farm, Pool, Can Machine, Framed Farm and furnace. Requires Agriculture, Advanced factories and Fluid handling. Bring starter raw fish; remove blood/slurry as well as items. Furnace needs fuel. |
| `quinityn-genetics` / First-generation industrial biology | Build the DNA Splicer; replicate initial DNA and make first animal cells; breed first-generation animals; make plant substrate/cells and grow Substratin; package Omtrinit, Substratin and cells | Quantum Composer, DNA Splicer, Meat Farm and Framed Farm. Requires Husbandry and Quantum, independently of Trade. Splicer construction uses Quantum materials. |
| `quinityn-advanced-genetics` / Second-generation industrial biology | Second animal cells → regular breeding; specialized feed → faster breeding; second plant cells → Karnis/chitrotin | DNA Splicer, Meat Farm, C1 Factory and Framed Farm. Follows Genetics and Quantum. Feed uses raw fish, cellulose and sugar; collect petroleum/blood outputs. |
| `quinityn-industrial-biology` / Third-generation industrial biology | Third animal cells → organic metal and its byproducts → pure iron | DNA Splicer, Meat Farm and furnace. Follows Advanced genetics. Account for acid, slurry and Scientific Reputation outputs; furnace needs fuel. |
| `quinityn-trade` / Laika, trade and reputation | Laika-Gate → Trade Node; canned-corn export; sealing/canning-metal imports; all five sign/Fame exchanges and fuel-cell purchase | C1 Factory and Trade Node. Trade follows Reputation, Quantum power and Packaging. The gate consumes ten Fame and a quantum accumulator; the first corn contract needs no animal/genetic research. |
| `quinityn-trade-biology` / Imported aquaculture and smoking | Import Krutag starter → breed Krutag; import PT-ishys and Ji-Ribu-s starters; make white feed → breed both species; build smoker → smoke meat and Ji-Ribu-s | Trade Node, Pool, C1 Factory and smoker. Requires Trade, Husbandry and Slag paving. Imports consume Merchant Signs. Krutag needs vegetable oil; PT-ishys needs water; Ji-Ribu-s needs contaminated water. Smoking consumes recipe wood plus separate burner fuel. |

The imported-aquaculture sequence also exports all four later canned foods,
basic fish and Krutag packages, blood, and raw/cooked meat. These exchanges now
appear with their usable products rather than initial Trade.

The #39 additions use the same research → tip → process mapping:

| Final technology / tip | Native process sequence | Machines and requirements |
| --- | --- | --- |
| `quinityn-reputation` | Construct Ancient Monument; passive Fame; Technic Signs → Fame | C1 Factory and Ancient Monument, 2 MW. Infusion and Flywheel storage; no Trade/Mastery. |
| `quinityn-chemical-science` | Reactor fuel/chips/engine units → chemical packs | Powered Cimota; chemical science and Advanced components. |
| `quinityn-military-science` | Hardic walls/ammunition → military packs | Powered Cimota; military science, Hardic walls and Advanced defense. |
| `quinityn-production-science` | Toolheads/modules/inserters/signs → production packs | Powered Cimota; production science and its material branches. |
| `quinityn-utility-science` | Batteries/chips/MF components/signs → utility packs; six ground science types → Scientific Reputation | Powered Cimota then C1 Factory; utility, production and military science. |
| `quinityn-space-science` | 6,000 Merchant Signs → 6 space packs | Powered Cimota; Trade, Orbital manufacturing and vanilla space science. |
| `quinityn-genetic-trade` | Substratin, Omtrinit and spliced-cell exports | Trade Node; Trade and Genetics. Collect all signs, Fame and biological byproducts. |
| `quinityn-advanced-genetic-trade` | Verotin and Karnis exports | Trade Node; Genetic product exports and Advanced genetics; Verotin also consumes Fame. |
| `quinityn-industrial-biology-trade` | Organic-metal export | Trade Node; Advanced genetic exports and Industrial biology. |
| `quinityn-mastery` | Build ultimate trader → direct Merchant Sign generation | C1 Factory and ultimate trader; 50 MW for one sign per 30 seconds. |

The exact ordered machine/recipe pairs live in
[`scripts/biology-processes.lua`](../../scripts/biology-processes.lua).
[`prototypes/biology-simulations.lua`](../../prototypes/biology-simulations.lua)
attaches each sequence through the existing tip generators.
[`scripts/biology-demo.lua`](../../scripts/biology-demo.lua) supplies quantities,
localized names, products, durations and fluid connections from the loaded
engine prototypes, rather than maintaining a second recipe/balance table.
These three files are included in playable packages; the scene does not load
anything from excluded documentation or tests.

## What the preview demonstrates

Every step runs the actual recipe in its actual machine. A supplied input
chest feeds the machine through an inserter; another inserter removes item
products. Separate pipes connect to the engine-reported fluid ports. Input
reservoirs contain only the labelled recipe quantity. A visible editor power
source powers the poles; burners receive coal. The scene names all recipe
inputs and outputs, including byproducts, and reports normal machine time.

These are **editor-supplied demonstrations**, not self-sustaining factories or
a playthrough. Research, machines, ingredients, fuel and electricity are
staged. Preview inserters have an increased hand capacity. Long crafts skip
to their final eight seconds after native input consumption; this is explicitly
labelled and must not be used to infer throughput. Outputs are produced by the
engine, never inserted by the script. Each process resets before the next one;
materials are not carried between steps. The sequence repeats and starts fresh
when reopened. The simulation has its own world and does not register handlers
in the real save's `control.lua`.

The native `biology_demonstrations` fixture runs all sequences without skipping
machine craft time, checks completion and first-step repeat, and checks research
isolation. It executes the init/update callbacks exported from the engine's
actual tip declarations, with isolated test worlds and full-duration crafting.
Prototype tests also check all 18 research triggers and simulation attachments.

The Husbandry demonstration now ends with raw/cooked meat packaging; Genetics
with Omtrinit, Substratin and cell packaging; Advanced genetics with Verotin and
Karnis packaging; Industrial biology with organic-metal packaging. Imported
aquaculture adds Krutag packages and all four imported/smoked-food cans.
Trade shows canned-corn export before its material-import and reputation exchanges.
Husbandry keeps its existing prerequisites; Packaging separately supplies the
containers used by its products. These scenes reuse the same supplied recipe
inputs and native transport rules described above.

For the packaging additions, graphical checks on the same engine and dependency
versions inspected the Packaging, Husbandry and Industrial biology effect lists,
and the Packaging and Industrial biology scenes completed their native crafts.
A separate connected check grew corn, pressed empty cans, canned the harvested
corn and exported four cans for 400 Merchant Signs and 16 military science packs
without Husbandry, Genetics or imported-species research. It supplied machines,
power, seed, metal and operating fluids, conserved products during manual
transfers, and ran at 10x simulation speed. This checks the production slice,
not construction of the Trade Node or a full survival playthrough. The separate
#39 startup fixture now produces ten Fame natively from supplied Technic Signs,
uses that stock to craft a gate and node, exports supplied corn cans and spends
one earned Merchant Sign on sealing. Power, machines and other construction
inputs are supplied; this is a connected startup slice, not survival pacing.

For #39, graphical checks on 2026-10-18 used Factorio/Space Age 2.1.22 and the
pinned dependencies. They inspected the Trade technology UI, ran the connected
startup fixture in the client, and sampled the 12 affected scene sequences
through the shipped renderer in isolated preview worlds. A generated ruin in
the initial preview fixture obscured the machines; disabling entity generation
in that fixture removed it. The corrected samples showed readable machines and
input/output labels. Native Tips-menu navigation and reopening were not checked
in this pass because automated mouse input did not reach those controls;
full-duration sequence completion and repetition were checked by the engine
fixture. These samples do not establish full-playthrough pacing or usability
at every UI scale.

Before the packaging additions, on 2026-10-18 graphical inspection in
Factorio/Space Age 2.1.22 with the pinned
Yuoki/Engines sources covered all seven sequences, repeat/reopen behavior,
readable framing, item transport, fluid ports and research/effect UI. A separate
connected fixture reused harvested crops, meat/blood, DNA and imported starters;
its supplementary inputs and infrastructure were staged. These checks do not
establish survival progression pacing or balance. Future scene changes still
need graphical inspection; automated completion alone does not establish
teaching quality.
