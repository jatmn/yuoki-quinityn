-- luacheck: read globals yi
local copy = table.deepcopy
local primitive_tint = { 0.8, 0.45, 1 }
local function item(name, count)
  return { type = "item", name = name, amount = count }
end
local function fluid(name, count)
  return { type = "fluid", name = name, amount = count }
end
local function recipe(name, ingredients, results, categories, seconds)
  local product = results[1]
  local source = data.raw[product.type][product.name] or data.raw.tool[product.name]
  data:extend({
    {
      type = "recipe",
      name = name,
      enabled = false,
      ingredients = ingredients,
      results = results,
      categories = categories or { "crafting" },
      energy_required = seconds or 2,
      subgroup = "quinityn-fieldwork",
      order = name,
      icons = source.icons and copy(source.icons) or { { icon = source.icon, icon_size = source.icon_size or 64 } },
      localised_name = { "recipe-name." .. name },
      surface_conditions = { { property = "quinityn-industry", min = 1, max = 1 } },
      auto_recycle = false,
      allow_productivity = false,
      allow_quality = false,
    },
  })
end
local function with_product_group(name)
  local recipe_proto = data.raw.recipe[name]
  local product = recipe_proto.results[1]
  local source = data.raw[product.type][product.name] or data.raw.tool[product.name]
  recipe_proto.subgroup = source.subgroup
  recipe_proto.order = source.order
end
data:extend({
  { type = "item-subgroup", name = "quinityn-fieldwork", group = "yuoki", order = "00" },
  -- Primitive Cimota picker rows, like the full Cimota: material -> unicomp, then unicomp -> material.
  { type = "item-subgroup", name = "quinityn-conversion-down", group = "yuoki", order = "00-a" },
  { type = "item-subgroup", name = "quinityn-conversion-up", group = "yuoki", order = "00-b" },
  { type = "recipe-category", name = "quinityn-separation" },
  { type = "recipe-category", name = "quinityn-science" },
})
local function tint_visible_sprites(value)
  if type(value) ~= "table" then
    return
  end
  -- filename / filenames / stripes, same signal as sprites() in stomp-a-trons.lua.
  -- Width and size are not required. Stripe records are not sprites.
  local is_sprite = value.filename or value.filenames or value.stripes
  if is_sprite then
    if value.draw_as_shadow or value.draw_as_light or value.draw_as_glow then
      return
    end
    value.tint = { primitive_tint[1], primitive_tint[2], primitive_tint[3] }
  end
  for key, child in pairs(value) do
    if key ~= "tint" and key ~= "stripes" then
      tint_visible_sprites(child)
    end
  end
end
local separator = copy(data.raw["assembling-machine"]["y-atomic-constructor"])
-- Keep the existing entity/item ID so placed separators and blueprints survive.
local old_separator = data.raw["assembling-machine"]["chemical-plant"]
separator.max_health = old_separator.max_health
separator.resistances = copy(old_separator.resistances)
-- Retain ordinary circuit wiring with the primitive Cimota appearance.
separator.circuit_connector = copy(old_separator.circuit_connector)
separator.circuit_wire_max_distance = old_separator.circuit_wire_max_distance
separator.name = "quinityn-burner-separator"
separator.minable = { mining_time = 0.2, result = separator.name }
separator.crafting_categories = { "quinityn-separation", "quinityn-primitive-conversion" }
separator.crafting_speed = 0.5
separator.energy_usage = "180kW"
separator.energy_source = {
  type = "burner",
  fuel_categories = { "chemical" },
  fuel_inventory_size = 1,
  effectivity = 1,
  emissions_per_minute = { pollution = 6 },
}
separator.module_slots = 0
separator.quality_affects_module_slots = false
separator.quality_affects_energy_usage = false
separator.energy_usage_quality_multiplier = nil
separator.allowed_effects = {}
-- Keep the copied fast-replace group so planners, blueprints and hand replacement reach the full Cimota.
separator.next_upgrade = "y-atomic-constructor"
separator.localised_name = { "entity-name.quinityn-burner-separator" }
tint_visible_sprites(separator.graphics_set)
local separator_item = copy(data.raw.item["y-atomic-constructor"])
separator_item.name = separator.name
separator_item.place_result = separator.name
separator_item.order = "a0[primitive-cimota]"
separator_item.localised_name = { "entity-name.quinityn-burner-separator" }
separator_item.icons = { { icon = "__Yuoki__/graphics/icons/cimota_64.png", icon_size = 64, tint = primitive_tint } }
separator_item.icon = nil
data:extend({
  separator,
  separator_item,
  {
    type = "item",
    name = "quinityn-salvage",
    icon = "__yuoki-quinityn__/graphics/icons/quinityn-salvage.png",
    icon_size = 256,
    subgroup = "y-raw-material",
    order = "z[quinityn-salvage]",
    stack_size = 100,
    weight = 1000,
  },
  {
    type = "tool",
    name = "quinityn-research-data",
    icon = "__yuoki-quinityn__/graphics/icons/quinityn-science.png",
    icon_size = 256,
    subgroup = "science-pack",
    order = "z[quinityn]",
    stack_size = 200,
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount-key",
    durability_description_value = "description.science-pack-remaining-amount-value",
  },
})
-- Emergency manual processes have poor yield; established Yuoki machinery is the scaling route.
recipe(
  "quinityn-hand-sort",
  { item("quinityn-salvage", 1) },
  { item("y-res1", 2), item("y-res2", 2), item("stone", 2), item("wood", 1) },
  nil,
  3
)
-- Sorting represents the input salvage, not just the first of four outputs.
local sort = data.raw.recipe["quinityn-hand-sort"]
sort.subgroup = data.raw.item["quinityn-salvage"].subgroup
sort.order = data.raw.item["quinityn-salvage"].order
sort.icons = { { icon = data.raw.item["quinityn-salvage"].icon, icon_size = 256 } }
sort.main_product = ""
sort.localised_description = { "recipe-description.quinityn-hand-sort" }
data.raw.item["quinityn-salvage"].default_import_location = "quinityn"
recipe("quinityn-iron", { item("y-res1", 3) }, { item("iron-ore", 2) }, nil, 3)
recipe("quinityn-copper", { item("y-res2", 3) }, { item("copper-ore", 2) }, nil, 3)
recipe("quinityn-carbon", { item("y-res2", 2) }, { item("coal", 1) }, nil, 2)
recipe("quinityn-stone", { item("y-res1", 2) }, { item("stone", 1) }, nil, 2)
recipe("quinityn-timber", { item("y-res1", 2), item("y-res2", 2) }, { item("wood", 1) }, nil, 4)
recipe(
  separator.name,
  { item("iron-plate", 10), item("copper-plate", 5), item("stone", 10) },
  { item(separator.name, 1) },
  nil,
  5
)
with_product_group(separator.name)
-- Separator conversions use Yuoki's atomics builder for its material-and-arrow icons.
-- Each registers one direction only: "down" is material -> unicomp, "up" is unicomp -> material.
local function conversion(name, material, direction, category, seconds, options)
  options.fields = {
    name = name,
    categories = { category },
    energy_required = seconds,
    enabled = false,
    subgroup = "quinityn-conversion-" .. direction,
    order = name,
    localised_name = { "recipe-name." .. name },
    surface_conditions = { { property = "quinityn-industry", min = 1, max = 1 } },
    allow_productivity = false,
  }
  return yi.lib.recipe.atomics.make_recipe(material, direction, options)
end
conversion("quinityn-water", "water", "up", "quinityn-separation", 2, {
  material_type = "fluid",
  amount = 100,
  unicomp = "y-liquid-uc2",
  unicomp_type = "fluid",
})
data:extend({
  { type = "recipe-category", name = "quinityn-primitive-conversion" },
})
for _, spec in ipairs({
  { "quinityn-stone-to-uc", "stone", "down", 40 },
  { "quinityn-wood-to-uc", "wood", "down", 40 },
  { "quinityn-uc-to-coal", "coal", "up", 10 },
  { "quinityn-uc-to-iron", "iron-ore", "up", 10 },
  { "quinityn-uc-to-copper", "copper-ore", "up", 10 },
}) do
  local name = spec[1]
  local primitive = conversion(name, spec[2], spec[3], "quinityn-primitive-conversion", 8, { amount = spec[4] })
  primitive.localised_description = { "recipe-description." .. name }
end
recipe(
  "quinityn-research-data",
  { item("y-unicomp-raw", 1), item("y-refined-yres2", 1), item("y_rwtechsign", 1), item("y-pol-waste", 5) },
  { item("quinityn-research-data", 5) },
  { "quinityn-science" },
  5
)
with_product_group("quinityn-research-data")
data.raw.item["y-pol-waste"].localised_description = { "item-description.quinityn-flyash" }
for _, name in ipairs({ "y-waste-condense", "y_mixedfuel2rocketfuel" }) do
  data.raw.recipe[name].localised_description = { "recipe-description.quinityn-" .. name }
end
-- Science packs accept productivity the way other pack recipes do. Leave the helper default off.
data.raw.recipe["quinityn-research-data"].allow_productivity = true
-- Dedicated technical qualification: material-intensive, with no fuel/byproduct output.
recipe(
  "quinityn-technic-sign",
  { item("y-bluegear", 12), item("y_structure_element", 8), item("y-conductive-wire-1", 20), item("y-chip-1", 4) },
  { item("y_rwtechsign", 1) },
  { "quinityn-science" },
  30
)
with_product_group("quinityn-technic-sign")
for _, name in ipairs({ "ye_fassembly1", "ye_fassembly2", "ye_fassembly_sp" }) do
  table.insert(data.raw["assembling-machine"][name].crafting_categories, "quinityn-science")
end
-- Raw F7 is an emergency chemical fuel, below wood (2 MJ). Refine it for efficiency.
data.raw.item["y-res2"].fuel_categories = { "chemical" }
data.raw.item["y-res2"].fuel_value = "1MJ"
-- Keep oil bootstrap in the Cimota chain; its existing UC -> crude-oil recipe supplies refineries.
-- A local copper/iron/coal/stone economy can therefore manufacture every standard rocket ingredient.
for _, lab in pairs(data.raw.lab) do
  if lab.name == "lab" or lab.name == "biolab" then
    table.insert(lab.inputs, "quinityn-research-data")
  end
end
local wreck = copy(data.raw["simple-entity"]["fulgoran-ruin-small"])
wreck.name = "quinityn-wreck"
wreck.localised_name = { "entity-name.quinityn-wreck" }
wreck.minable = { mining_time = 1, results = { item("quinityn-salvage", 20) } }
wreck.autoplace = { probability_expression = "quinityn_stockpile_probability" }
wreck.map_color = { 0.58, 0.41, 0.68 }
data:extend({ wreck })
data.raw.planet.quinityn.map_gen_settings.autoplace_settings.entity.settings[wreck.name] = {}
recipe(
  "quinityn-low-density-structure",
  { item("y_structure_element", 2), item("y-unicomp-raw", 5), item("plastic-bar", 5) },
  { item("low-density-structure", 1) },
  { "crafting" },
  15
)
with_product_group("quinityn-low-density-structure")
recipe(
  "quinityn-processing-unit",
  { item("y-chip-2", 2), item("y-conductive-wire-1", 4), fluid("sulfuric-acid", 5) },
  { item("processing-unit", 1) },
  { "crafting-with-fluid" },
  10
)
with_product_group("quinityn-processing-unit")

-- Emergency ore dressing cannot become a competing automated ore industry.
-- Salvage sorting stays hand-craftable and also runs in Yuoki crushers.
for index, name in ipairs({ "carbon", "copper", "iron", "stone", "timber" }) do
  local manual = data.raw.recipe["quinityn-" .. name]
  manual.categories = { "hand-crafting" }
  manual.order = tostring(index)
end
data.raw.recipe["quinityn-hand-sort"].categories = { "hand-crafting", "y-crushing" }

local foundation_item = copy(data.raw.item.foundation)
foundation_item.name = "quinityn-foundation"
foundation_item.default_import_location = "quinityn"
foundation_item.place_as_tile.result = "quinityn-foundation"
foundation_item.order = "c[landfill]-h[quinityn]"
foundation_item.icons = { { icon = foundation_item.icon, icon_size = 64, tint = { 0.65, 0.40, 1 } } }
foundation_item.icon = nil
local foundation_tile = copy(data.raw.tile.foundation)
foundation_tile.name = "quinityn-foundation"
foundation_tile.minable.result = "quinityn-foundation"
foundation_tile.frozen_variant = "quinityn-frozen-foundation"
foundation_tile.tint = { 0.65, 0.5, 0.85 }
foundation_tile.map_color = { 0.35, 0.25, 0.42 }
local frozen = copy(data.raw.tile["frozen-foundation"])
frozen.name = "quinityn-frozen-foundation"
frozen.thawed_variant = "quinityn-foundation"
if frozen.minable then
  frozen.minable.result = "quinityn-foundation"
end
data:extend({ foundation_item, foundation_tile, frozen })
recipe(
  "quinityn-foundation",
  { item("y_structure_element", 2), item("y_structure_vessel", 1), item("y-orange-stuff", 5), item("stone-brick", 10) },
  { item("quinityn-foundation", 4) },
  { "yuoki-formpress" },
  8
)
with_product_group("quinityn-foundation")
