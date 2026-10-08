data:extend({{type="tips-and-tricks-item-category",name="quinityn",order="l[quinityn]"}})
local chapters={
  {"briefing","planet-discovery-quinityn","[planet=quinityn]"},
  {"bootstrap","quinityn-arrival","[item=quinityn-salvage]"},
  {"unicomp","quinityn-arrival","[fluid=y-liquid-uc2]"},
  {"materials","quinityn-materials","[item=y-crusher]"},
  {"power","quinityn-power","[item=y-boiler-iv]"},
  {"cimota","quinityn-cimota","[item=y-atomic-constructor]"},
  {"engines","quinityn-engines","[fluid=y-mechanical-force]"},
  {"refining","quinityn-refining","[item=y_smelter]"},
  {"foundation","quinityn-foundation","[item=quinityn-foundation]"},
  {"agriculture","quinityn-agriculture","[item=ye_farm]"},
  {"logistics","quinityn-logistics","[item=yi_roboport]"},
  {"defense","quinityn-defense","[item=y_turret_flame]"},
  {"quantum","quinityn-quantum","[item=y-quantrinum]"},
  {"trade","quinityn-trade","[item=y-stargate]"},
  {"mastery","quinityn-mastery","[item=y_rwtechsign]"},
  {"orbital","quinityn-orbital","[item=rocket-silo]"},
  {"endgame","quinityn-mastery","[item=quinityn-research-data]"}
}
for i, chapter in ipairs(chapters) do
  data:extend({{type="tips-and-tricks-item",name="quinityn-"..chapter[1],category="quinityn",
    tag=chapter[3],order=string.format("%02d",i),indent=i==1 and 0 or 1,is_title=i==1,
    trigger={type="research",technology=chapter[2]},
    localised_name={"tips-and-tricks-item-name.quinityn-"..chapter[1]},
    localised_description={"tips-and-tricks-item-description.quinityn-"..chapter[1]}}})
end

for i, tier in ipairs(require("prototypes.research-tiers")) do
  data:extend({{type="tips-and-tricks-item",name="quinityn-"..tier.name,category="quinityn",
    tag="[item="..tier.icon.."]",order="20-"..string.format("%02d",i),indent=1,
    trigger={type="research",technology="quinityn-"..tier.name},
    localised_name={"technology-name.quinityn-"..tier.name},
    localised_description={"technology-description.quinityn-"..tier.name}}})
end
