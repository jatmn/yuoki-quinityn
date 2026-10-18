# Biology demonstration coverage

This is the #37 portion of [#24](https://github.com/jatmn/yuoki-quinityn/issues/24),
covering seven affected tips. It does not complete the other tutorial families,
the discovery preview, or the separate Packaging/Trade work in #38/#39.

Each tip unlocks at the technology in its row. The chapter tips retain their
broader roadmap text; their animation teaches the currently available stage.
Later processes have their own research-triggered tips.

| Final technology / tip | Native process sequence | Machines and operating requirements |
| --- | --- | --- |
| `quinityn-agriculture` / Crops, animals and DNA | Initial corn seed → corn → replacement seeds; Vugar seed → Vugar; corn oil → lubricant; cellulose, synthetic wood, sugar and organic feed | C1 Factory, Framed Farm, Form Press, chemical plant and crusher. Water and Mechanical Force use separate ports; press/crusher need fuel. Reserve corn for new seeds. |
| `quinityn-husbandry` / Animal husbandry and aquaculture | Initial DNA from science packs; meat breeding; basic fish breeding; blood extraction, slurry dilution, slurry-fed crops and cooking | C1 Factory, Meat Farm, Pool, Can Machine, Framed Farm and furnace. Requires Agriculture, Advanced factories and Fluid handling. Bring starter raw fish; remove blood/slurry as well as items. Furnace needs fuel. |
| `quinityn-genetics` / First-generation industrial biology | Build the DNA Splicer; replicate initial DNA and make first animal cells; breed first-generation animals; make plant substrate/cells and grow Substratin | Quantum Composer, DNA Splicer, Meat Farm and Framed Farm. Requires Husbandry and Quantum, independently of Trade. Splicer construction uses Quantum materials. |
| `quinityn-advanced-genetics` / Second-generation industrial biology | Second animal cells → regular breeding; specialized feed → faster breeding; second plant cells → Omtrinit | DNA Splicer, Meat Farm, C1 Factory and Framed Farm. Follows Genetics and Quantum. Feed uses raw fish, cellulose and sugar; collect petroleum/blood outputs. |
| `quinityn-industrial-biology` / Third-generation industrial biology | Third animal cells → organic metal and its byproducts → pure iron | DNA Splicer, Meat Farm and furnace. Follows Advanced genetics. Account for acid, slurry and Scientific Reputation outputs; furnace needs fuel. |
| `quinityn-trade` / Laika, trade and reputation | Laika-Gate → Trade Node; export basic fish packages for Merchant Signs and returned containers; export meat packages for UC-A2 and DNA; import sealing | C2 Factory, C1 Factory and Trade Node. Trade follows Quantum and Packaging. Fish/meat feedstock additionally needs Husbandry; these supplied packages are not an early free resource. All trade outputs must be collected. No genetic export is shown as available from early farming. |
| `quinityn-trade-biology` / Imported aquaculture and smoking | Import Krutag starter → breed Krutag; import PT-ishys and Ji-Ribu-s starters; make white feed → breed both species; build smoker → smoke meat and Ji-Ribu-s | Trade Node, Pool, C1 Factory and smoker. Requires Trade, Husbandry and Slag paving. Imports consume Merchant Signs. Krutag needs vegetable oil; PT-ishys needs water; Ji-Ribu-s needs contaminated water. Smoking consumes recipe wood plus separate burner fuel. |

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
isolation. Prototype tests check all seven research triggers and simulation
attachments. Graphical inspection is still needed to establish readable framing,
visible transport, fluid connections and UI/reopen behavior; automated completion
alone does not establish teaching quality.
