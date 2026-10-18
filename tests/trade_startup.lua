-- Native connected Fame -> gate -> corn export -> import slice.
-- Machines, power, Technic Signs and other construction inputs are staged.
-- Fame, gates, corn export proceeds and import inputs are never injected.
local function research(force, name)
  local t = force.technologies[name]
  if t.researched then
    return
  end
  for _, parent in pairs(t.prerequisites) do
    research(force, parent.name)
  end
  t.researched = true
end
local function machine(name, position, recipe)
  local m = assert(storage.surface.create_entity({ name = name, position = position, force = storage.force }))
  assert(storage.force.recipes[recipe].enabled, recipe)
  assert(m.set_recipe(recipe), recipe)
  return m
end
local function supply(m, recipe, excluded)
  for _, part in pairs(prototypes.recipe[recipe].ingredients) do
    if part.name ~= excluded then
      assert(part.type == "item")
      assert(m.insert({ name = part.name, count = part.amount }) == part.amount, part.name)
    end
  end
end
local function expect_ingredient(recipe, name, amount)
  for _, part in pairs(prototypes.recipe[recipe].ingredients) do
    if part.name == name then
      assert(
        part.type == "item" and part.amount == amount,
        recipe .. ": expected startup ingredient " .. amount .. " " .. name
      )
      return
    end
  end
  error(recipe .. ": expected startup ingredient " .. amount .. " " .. name)
end
script.on_init(function()
  -- Keep these costs independent of supply(), which follows the loaded recipe.
  expect_ingredient("y_fame_tech", "y_rwtechsign", 25)
  expect_ingredient("y-stargate", "y-accumulator-crystal-m", 1)
  local force = game.create_force("trade-startup")
  storage.force = force
  storage.surface = game.create_surface("trade-startup", { width = 64, height = 64 })
  storage.surface.request_to_generate_chunks({ 0, 0 }, 1)
  storage.surface.force_generate_chunk_requests()
  for _, e in pairs(storage.surface.find_entities()) do
    e.destroy()
  end
  local tiles = {}
  for x = -32, 31 do
    for y = -32, 31 do
      tiles[#tiles + 1] = { name = "quinityn-basalt", position = { x, y } }
    end
  end
  storage.surface.set_tiles(tiles)
  research(force, "quinityn-reputation")
  assert(not force.technologies["quinityn-trade"].researched)
  assert(not force.add_research("quinityn-trade"), "Trade ignored quantum accumulator prerequisite")
  local power =
    storage.surface.create_entity({ name = "electric-energy-interface", position = { -20, -20 }, force = force })
  power.power_production = 100000000
  power.electric_buffer_size = 100000000
  for x = -24, 24, 16 do
    for y = -24, 24, 16 do
      storage.surface.create_entity({ name = "substation", position = { x, y }, force = force })
    end
  end
  storage.generators = {}
  for i = 1, 10 do
    local m = machine("y-fame-gen", { -18 + (i - 1) % 5 * 8, -12 + math.floor((i - 1) / 5) * 10 }, "y_fame_tech")
    supply(m, "y_fame_tech")
    storage.generators[#storage.generators + 1] = m
  end
  storage.step = 1
end)
script.on_event(defines.events.on_tick, function()
  if storage.done then
    return
  end
  local force = storage.force
  assert(not force.technologies["quinityn-mastery"].researched)
  assert(not force.technologies["quinityn-husbandry"].researched)
  assert(not force.technologies["quinityn-genetics"].researched)
  if storage.step == 1 then
    for _, m in ipairs(storage.generators) do
      if m.products_finished == 0 then
        return
      end
    end
    research(force, "quinityn-trade")
    local m = machine("ye_fassembly1", { 0, 12 }, "y-stargate")
    supply(m, "y-stargate", "y-fame")
    for _, g in ipairs(storage.generators) do
      assert(g.get_output_inventory().remove({ name = "y-fame", count = 1 }) == 1)
      assert(m.insert({ name = "y-fame", count = 1 }) == 1)
    end
    storage.crafter = m
    storage.step = 2
  elseif storage.step == 2 and storage.crafter.products_finished > 0 then
    local m = storage.crafter
    assert(m.get_output_inventory().remove({ name = "y-stargate", count = 1 }) == 1)
    assert(m.set_recipe("ye_trade_node"))
    supply(m, "ye_trade_node", "y-stargate")
    assert(m.insert({ name = "y-stargate", count = 1 }) == 1)
    storage.step = 3
  elseif storage.step == 3 and storage.crafter.get_output_inventory().get_item_count("ye_trade_node") > 0 then
    assert(storage.crafter.get_output_inventory().remove({ name = "ye_trade_node", count = 1 }) == 1)
    storage.node = machine("ye_trade_node", { 12, 12 }, "ye_buechse_gelb_export")
    -- Four local corn cans: their connected manufacture is covered by the
    -- packaging fixture; here their real export funds the following import.
    supply(storage.node, "ye_buechse_gelb_export")
    storage.step = 4
  elseif storage.step == 4 and storage.node.products_finished > 0 then
    local m = storage.node
    assert(m.get_output_inventory().remove({ name = "ypfw_trader_sign", count = 400 }) == 400)
    assert(m.get_output_inventory().remove({ name = "military-science-pack", count = 16 }) == 16)
    assert(m.set_recipe("yie_import_sealing"))
    assert(m.insert({ name = "ypfw_trader_sign", count = 1 }) == 1)
    storage.step = 5
  elseif storage.step == 5 and storage.node.get_output_inventory().get_item_count("ye_sealing") == 4 then
    storage.done = true
    log("QUINITYN TRADE STARTUP PASSED: native Fame, gate, node, corn export and funded import without Mastery")
  end
end)
