local function icons(name)
  local item=data.raw.item[name] or data.raw.tool[name] or data.raw.armor[name] or data.raw.ammo[name] or data.raw.module[name]
  assert(item,"Missing research icon item: "..name)
  return item.icons and table.deepcopy(item.icons) or {{icon=item.icon,icon_size=item.icon_size or 64}}
end
local function unlock(name) return {type="unlock-recipe",recipe=name} end
local discovery = table.deepcopy(data.raw.technology["planet-discovery-vulcanus"])
discovery.name = "planet-discovery-quinityn"
discovery.icon = nil
discovery.icon_size = nil
discovery.icons = table.deepcopy(data.raw.planet.quinityn.icons)
discovery.effects = {{type="unlock-space-location",space_location="quinityn",use_icon_overlay_constant=true}}
discovery.localised_name = {"technology-name.planet-discovery-quinityn"}
discovery.localised_description = {"technology-description.planet-discovery-quinityn"}
local landing = {type="technology",name="quinityn-arrival",icons=icons("quinityn-salvage"),
  prerequisites={"planet-discovery-quinityn"},
  effects={}, research_trigger={type="scripted",trigger_description={"quinityn.land-to-unlock"}},
  order="y-a", essential=true}
for _, name in ipairs({"hand-sort","iron","copper","carbon","stone","timber","burner-separator","water"}) do
  table.insert(landing.effects,unlock("quinityn-"..name))
end
data:extend({discovery,landing})
-- A single shared foundation followed by focused industrial disciplines.
local stages = {
  {"materials", {"arrival"}, nil, "y-crusher", {type="craft-item",item="quinityn-burner-separator",count=1}},
  {"power", {"industrial-science","basic-factory","fuel-processing"}, 60, "y-steam-turbine"},
  {"cimota", {"power"}, 100, "y-atomic-constructor"},
  {"engines", {"cimota"}, 120, "y-sfe"},
  {"refining", {"engines","advanced-components"}, 150, "y_smelter"},
  {"agriculture", {"refining"}, 180, "ye_farm"},
  {"logistics", {"advanced-components"}, 100, "y-inserter-fast"},
  {"defense", {"power","washing"}, 100, "y_turret_gun1f12"},
  {"quantum", {"crystal-processing","energy-storage"}, 250, "y-atomic-quantum-composer"},
  {"trade", {"quantum","packaging"}, 300, "y-stargate"},
  {"mastery", {"trade","maintenance","reactors"}, 500, "y_trade_ultimate"},
  {"orbital", {"quantum"}, 200, "rocket-silo"}
}
for _, tier in ipairs(require("prototypes.research-tiers")) do
  stages[#stages+1]={tier.name,tier.prerequisites,tier.count,tier.icon,tier.trigger}
end
for i, s in ipairs(stages) do
  local science = {{"automation-science-pack",1},{"logistic-science-pack",1},{"quinityn-research-data",1}}
  local prerequisites={}
  for _, parent in ipairs(s[2]) do prerequisites[#prerequisites+1]="quinityn-"..parent end
  data:extend({{type="technology",name="quinityn-"..s[1],icons=icons(s[4]),
    effects={},prerequisites=prerequisites,
    research_trigger=s[5],
    unit=not s[5] and {count=s[3],time=20,ingredients=science} or nil,order="y-"..string.format("%02d",i)}})
end
table.insert(data.raw.technology["quinityn-industrial-science"].effects,unlock("quinityn-research-data"))
table.insert(data.raw.technology["quinityn-industrial-science"].effects,unlock("quinityn-technic-sign"))
data:extend({{type="technology",name="quinityn-oil-processing",
  icon="__base__/graphics/technology/oil-processing.png",icon_size=256,
  prerequisites={"quinityn-cimota","oil-gathering"},
  research_trigger={type="craft-fluid",fluid="crude-oil",amount=80},
  effects={{type="nothing",effect_description={"quinityn.oil-processing-effect"}}}}})
local orbital=data.raw.technology["quinityn-orbital"]
table.insert(orbital.prerequisites,"rocket-silo")
table.insert(orbital.effects,unlock("quinityn-low-density-structure"))
table.insert(orbital.effects,unlock("quinityn-processing-unit"))
for _, definition in ipairs({
  {name="quinityn-mining-productivity",icon="y-mining-drill-e2",effect={type="mining-drill-productivity-bonus",modifier=0.1}},
  {name="quinityn-plasma-damage",icon="y_ammo_plasma",effect={type="ammo-damage",ammo_category="plasma",modifier=0.1}}
}) do
  data:extend({{type="technology",name=definition.name,icons=icons(definition.icon),
    max_level="infinite",upgrade=true,
    prerequisites={"quinityn-mastery","quinityn-orbital","production-science-pack","utility-science-pack","space-science-pack"},
    effects={definition.effect},
    unit={count_formula="1000*1.5^(L-1)",time=60,ingredients={
      {"automation-science-pack",1},{"logistic-science-pack",1},{"chemical-science-pack",1},
      {"production-science-pack",1},{"utility-science-pack",1},{"space-science-pack",1},
      {"quinityn-research-data",2}}},order="y-z-"..definition.name}})
end
data:extend({{type="technology",name="quinityn-foundation",
  icon="__space-age__/graphics/technology/foundation.png",icon_size=256,
  prerequisites={"quinityn-refining"},effects={unlock("quinityn-foundation")},
  unit={count=200,time=30,ingredients={{"automation-science-pack",1},{"logistic-science-pack",1},{"quinityn-research-data",1}}},
  order="y-06a"}})
