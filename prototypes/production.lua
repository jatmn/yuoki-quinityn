local copy = table.deepcopy
local function item(name, count) return {type="item", name=name, amount=count} end
local function fluid(name, count) return {type="fluid", name=name, amount=count} end
local function recipe(name, ingredients, results, categories, seconds)
  local product = results[1]
  local source = data.raw[product.type][product.name] or data.raw.tool[product.name]
  data:extend({{type="recipe", name=name, enabled=false,
    ingredients=ingredients, results=results, categories=categories or {"crafting"},
    energy_required=seconds or 2, subgroup="quinityn-fieldwork", order=name,
    icons=source.icons and copy(source.icons) or {{icon=source.icon,icon_size=source.icon_size or 64}},
    localised_name={"recipe-name."..name},
    surface_conditions={{property="quinityn-industry",min=1,max=1}},
    auto_recycle=false, allow_productivity=false, allow_quality=false}})
end
data:extend({
  {type="item-subgroup",name="quinityn-fieldwork",group="yuoki",order="00"},
  {type="recipe-category",name="quinityn-separation"}
})
local separator = copy(data.raw["assembling-machine"]["chemical-plant"])
separator.name = "quinityn-burner-separator"
separator.minable = {mining_time=0.2,result=separator.name}
separator.crafting_categories = {"quinityn-separation"}
separator.crafting_speed = 1
separator.energy_usage = "180kW"
separator.energy_source = {type="burner", fuel_categories={"chemical"}, fuel_inventory_size=1,
  effectivity=1, emissions_per_minute={pollution=6}}
separator.module_slots = 0
separator.allowed_effects = {}
separator.next_upgrade = nil
separator.fast_replaceable_group = nil
separator.localised_name = {"entity-name.quinityn-burner-separator"}
local separator_item = copy(data.raw.item["chemical-plant"])
separator_item.name = separator.name
separator_item.place_result = separator.name
separator_item.subgroup = "quinityn-fieldwork"
separator_item.localised_name = {"entity-name.quinityn-burner-separator"}
separator_item.icons = {{icon="__base__/graphics/icons/chemical-plant.png",icon_size=64,tint={0.8,0.45,1}}}
separator_item.icon = nil
data:extend({separator,separator_item,
  {type="item",name="quinityn-salvage",icon="__space-age__/graphics/icons/scrap.png",icon_size=64,
    subgroup="quinityn-fieldwork",stack_size=100,weight=1000},
  {type="tool",name="quinityn-research-data",icon="__Yuoki__/graphics/icons/sign_tech_icon.png",icon_size=64,
    subgroup="science-pack",order="z[quinityn]",stack_size=200,durability=1,
    durability_description_key="description.science-pack-remaining-amount-key",
    durability_description_value="description.science-pack-remaining-amount-value"}
})
-- Emergency manual processes have poor yield; established Yuoki machinery is the scaling route.
recipe("quinityn-hand-sort",{item("quinityn-salvage",1)},
  {item("y-res1",2),item("y-res2",2),item("stone",2),item("wood",1)},nil,3)
recipe("quinityn-iron",{item("y-res1",3)},{item("iron-ore",2)},nil,3)
recipe("quinityn-copper",{item("y-res2",3)},{item("copper-ore",2)},nil,3)
recipe("quinityn-carbon",{item("y-res2",2)},{item("coal",1)},nil,2)
recipe("quinityn-stone",{item("y-res1",2)},{item("stone",1)},nil,2)
recipe("quinityn-timber",{item("y-res1",2),item("y-res2",2)},{item("wood",1)},nil,4)
recipe(separator.name,{item("iron-plate",10),item("copper-plate",5),item("stone",10)},
  {item(separator.name,1)},nil,5)
recipe("quinityn-water",{fluid("y-liquid-uc2",1)},{fluid("water",100)}, {"quinityn-separation"},2)
recipe("quinityn-research-data",{item("y-unicomp-raw",1),item("y-refined-yres2",1),item("y_rwtechsign",1)},
  {item("quinityn-research-data",5)},nil,5)
-- Keep oil bootstrap in the Cimota chain; its existing UC -> crude-oil recipe supplies refineries.
-- A local copper/iron/coal/stone economy can therefore manufacture every standard rocket ingredient.
for _, lab in pairs(data.raw.lab) do
  if lab.name == "lab" or lab.name == "biolab" then table.insert(lab.inputs,"quinityn-research-data") end
end
local wreck = copy(data.raw["simple-entity"]["huge-rock"])
wreck.name = "quinityn-wreck"
wreck.localised_name = {"entity-name.quinityn-wreck"}
wreck.minable = {mining_time=1,results={item("quinityn-salvage",20)}}
wreck.autoplace = {probability_expression="0.025 * (quinityn_elevation > 0)"}
wreck.map_color = {0.58,0.41,0.68}
data:extend({wreck})
data.raw.planet.quinityn.map_gen_settings.autoplace_settings.entity.settings[wreck.name] = {}
recipe("quinityn-low-density-structure",{item("y_structure_element",2),item("y-unicomp-raw",5),item("plastic-bar",5)},
  {item("low-density-structure",1)},{"crafting"},15)
recipe("quinityn-processing-unit",{item("y-chip-2",2),item("y-conductive-wire-1",4),fluid("sulfuric-acid",5)},
  {item("processing-unit",1)},{"crafting-with-fluid"},10)
