-- Grouping follows the upstream crafting tabs; specific machines override their tab.
local groups = {
  materials={"y_line1","y_line2","y_line3","y_line4","y-parts","y_parts_e","y-raw-material","yuoki-formpress","yuoki-archaeology","y_tiles","yie-parts"},
  power={"y-boiler","y-electric","y-energy-2","y-fuel","y-lamps","y-pipe","y-fluid-storage","y-tools"},
  engines={"yie-engines","yie-fluids","yie_machinery","yie_machinery2","yie_tubes","yie-processed","yie_fluid_handle","y_refine_parts"},
  refining={"y-fluid","y_refine_machinery","y_refine_material","y_refine_raws"},
  agriculture={"yie_agromachinery","yie_agroproducts","yie_agroproducts_crafted","yie_agroproducts_packages","yie_farming","yie_fish","yie_animals","yie_dnaline"},
  logistics={"j-y-logi-1","j-y-logi-2","j-y-logi-5","j-y-logi-6","j-y-logi-7","j-y-logi-8","j-y-logi-9"},
  defense={"y-defense","y-ammo","y_defense_walls","y_personal","y_personal_equip"},
  quantum={"y-tech","y-module"},
  trade={"y-stargate-4","y-stargate-f","y-stargate-r","yie_engines_import_a","yie_trades_import_line1","yie_trades_line1","yie_trades_line2","yie_agro_package","yie_agro_package_l2"},
  mastery={"y_mastercrafted","y_ultimate_products"}
}
local mapping = {}
for stage, list in pairs(groups) do for _, group in ipairs(list) do mapping[group]=stage end end
local overrides = {
  ["y-atomic-constructor"]="cimota", ["y-atomic-quantum-composer"]="quantum",
  ["y-alien-infuser"]="quantum", ["y_crystalizer"]="refining",
  ["y_moxmixer"]="refining", ["y_smelter"]="refining", ["y_charger"]="quantum",
  ["yi_radar"]="power", ["yi_beacon"]="quantum",
  ["y-fuel-reactor"]="materials", ["y-iron-case"]="materials",
  ["y-infused-uca2"]="quantum", ["y-infused-mud"]="quantum",
  ["y-quantrinum-reactor"]="quantum", ["y-quantrinum-charge"]="quantum",
  ["y-stargate"]="trade", ["ye_trade_node"]="agriculture",
  ["ye_fame"]="trade", ["ye_science_blue"]="quantum"
}
-- Explicit upgrades override broad upstream crafting-tab groups.
for _, tier in ipairs(require("prototypes.research-tiers")) do
  for _, name in ipairs(tier.recipes) do overrides[name]=tier.name end
end
overrides["y-heat-pipe"]="power"
overrides["yi_graphite"]="power"
overrides["ye_canister2plates_smelt"]="fluid-handling"
overrides["y_turret_gun1f12"]="defense"
overrides["y-weapon-ztt"]="quantum-power"
overrides["ye_center"]="quantum"
overrides["y-quantrinum-reactor"]="quantum-power"
overrides["y-mf1-q1"]="quantum-power"
overrides["y-mf1-q2"]="quantum-power"
overrides["y-mf1-q3"]="quantum-power"
overrides["ye_rheinsberg"]="quantum-power"
overrides["ye_rheins_LT"]="quantum-power"
overrides["ye_rheins_MT"]="quantum-power"
overrides["ye_rheins_HT"]="quantum-power"
overrides["y_hps_purecopper"]="refining"
overrides["y_hps_pureiron"]="refining"
overrides["y_hps_steel"]="refining"
overrides["y-waste-condense"]="engines"
overrides["y_mixedfuel2rocketfuel"]="engines"
overrides["y-1stirling-engine"]="engines"
overrides["y-repair-krakon"]="cimota"
overrides["y_repair_quantrinum"]="quantum"
overrides["y-fuel-cell-c"]="trade"
overrides["yi_radar"]="plant-infrastructure"
local M = {}
function M.owned(r)
  local name=r.name
  if name:match("^quinityn%-") then return false end
  if name:match("^y[-_]") or name:match("^yi[-_]") or name:match("^ye[-_]") or name:match("^yie[-_]") or name:match("^ypfw[-_]") then return true end
  local subgroup=data.raw["item-subgroup"][r.subgroup or ""]
  local group=subgroup and subgroup.group or ""
  if group:match("^yuoki") or group:match("^yi[_e]") or group=="j_yuoki_logistics" then return true end
  -- Includes upstream j_* integration recipes and generated fluid barreling recipes.
  for _, p in pairs(r.results or {}) do
    if p.name:match("^y[-_]") or p.name:match("^yi[-_]") or p.name:match("^ye[-_]") or p.name:match("^yie[-_]") then return true end
  end
  return false
end
function M.stage(r)
  local name=r.name:gsub("%-recycling$","")
  if overrides[name] then return overrides[name] end
  if r.subgroup and r.subgroup:match("^j%-y%-atomics") then return "cimota" end
  local original=data.raw.recipe[name]
  if original and original ~= r then return M.stage(original) end
  return mapping[r.subgroup] or "refining"
end
return M
