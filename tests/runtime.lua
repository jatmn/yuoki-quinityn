local copy = require("util").table.deepcopy
local progression = require("__yuoki-quinityn__/scripts/progression")
local discovery_tests = require("__yuoki-quinityn__/tests/discovery")
local function check(condition, message)
  if not condition then
    error("QUINITYN TEST FAILED: " .. message)
  end
  log("QUINITYN PASS: " .. message)
end
local function offworld_tracked(unit_number)
  return remote.call("yuoki-quinityn", "offworld_crusher_tracked", unit_number) == true
end
script.on_init(function()
  local force = game.forces.player
  check(not settings.startup["yuoki-start-with-yi-suit"].value, "upstream starting suit cannot bypass visit gate")
  check(not force.technologies["quinityn-arrival"].researched, "arrival locked before landing")
  check(not force.recipes["y-crusher"].enabled, "Yuoki locked before landing")
  check(not force.recipes["ye_farm"].enabled, "Engines locked before landing")
  local surface = game.planets.quinityn.create_surface()
  surface.request_to_generate_chunks({ 0, 0 }, 12)
  surface.force_generate_chunk_requests()
  check(surface.get_tile(64, 0).name ~= "quinityn-unicomp-sea", "artificial starter pond removed")
  check(surface.get_tile(0, 0).name == "quinityn-basalt", "dry landing plateau")

  check(
    surface.count_entities_filtered({ name = "quinityn-wreck", area = { { -160, -160 }, { 160, 160 } } }) >= 15,
    "abundant clustered starter salvage"
  )
  check(
    #surface.find_decoratives_filtered({ area = { { -200, -200 }, { 200, 200 } } }) > 100,
    "cosmetic decoratives generate"
  )
  local natural_decoratives = {
    "quinityn-dead-shrub",
    "quinityn-dry-tuft",
    "quinityn-dead-grass",
    "quinityn-dead-groundcover",
    "quinityn-tiny-rock",
    "quinityn-small-rock",
  }
  for _, name in ipairs(natural_decoratives) do
    local placed = surface.find_decoratives_filtered({ area = { { -360, -360 }, { 360, 360 } }, name = name })
    check(#placed > 10, "natural ground detail generates: " .. name)
    for _, d in pairs(placed) do
      local tile = surface.get_tile(d.position).name
      assert(
        tile == "quinityn-weathered-soil" or tile == "quinityn-dead-turf" or tile == "quinityn-ash-soil",
        "Natural detail outside old soil: " .. name
      )
    end
    log("NATURAL DETAIL " .. name .. " placements=" .. #placed)
  end
  check(
    surface.count_entities_filtered({ name = { "big-rock", "huge-rock", "big-sand-rock" } }) == 0,
    "Quinityn generates only its ash-coated mineable rocks"
  )
  local rocks = surface.find_entities_filtered({
    name = { "quinityn-big-rock", "quinityn-huge-rock" },
    area = { { -160, -160 }, { 160, 160 } },
  })
  local ash = 0
  for _, rock in pairs(rocks) do
    ash = ash + (rock.name == "quinityn-big-rock" and 2 or 4)
  end
  check(ash >= 100, "starter rocks supply at least 100 finite flyash for Power and Fatmice research: " .. ash)
  for _, name in ipairs({ "quinityn-big-rock", "quinityn-huge-rock" }) do
    local rock = surface.find_entities_filtered({ name = name, limit = 1 })[1]
    check(rock ~= nil, "natural ash-coated rock generates: " .. name)
    local inventory = game.create_inventory(5)
    check(rock.mine({ inventory = inventory }), "natural ash-coated rock can be mined")
    check(inventory.get_item_count("stone") >= 20, "native rock stone yield retained")
    check(
      inventory.get_item_count("y-pol-waste") == (name == "quinityn-big-rock" and 2 or 4),
      "small flyash sample recovered"
    )
    if name == "quinityn-huge-rock" then
      check(inventory.get_item_count("coal") >= 24, "huge rock coal retained")
    end
    inventory.destroy()
  end
  local rows = {}
  local codes = {
    ["quinityn-unicomp-sea"] = "~",
    ["quinityn-basalt"] = ".",
    ["quinityn-slag"] = "s",
    ["quinityn-ruined-district"] = "m",
    ["quinityn-ash"] = "a",
    ["quinityn-rubble"] = "r",
    ["quinityn-weathered-soil"] = "d",
    ["quinityn-dead-turf"] = "g",
    ["quinityn-ash-soil"] = "e",
  }
  for y = -360, 358, 2 do
    local row = {}
    for x = -360, 358, 2 do
      row[#row + 1] = codes[surface.get_tile(x, y).name] or "?"
    end
    rows[#rows + 1] = table.concat(row)
  end
  local wrecks = {}
  for _, e in pairs(surface.find_entities_filtered({ name = "quinityn-wreck" })) do
    wrecks[#wrecks + 1] = e.position
  end
  helpers.write_file(
    "quinityn-map-" .. surface.map_gen_settings.seed .. ".json",
    helpers.table_to_json({ seed = surface.map_gen_settings.seed, rows = rows, wrecks = wrecks }),
    false
  )
  check(surface.count_entities_filtered({ type = "unit-spawner" }) > 0, "biter bases generate")
  check(
    surface.count_entities_filtered({ name = { "iron-ore", "copper-ore", "crude-oil" } }) == 0,
    "no imported vanilla deposits"
  )
  local water = surface.find_tiles_filtered({
    area = { { -300, -300 }, { 300, 300 } },
    name = { "water", "deepwater", "lava", "oil-ocean-deep" },
  })
  check(#water == 0, "all natural liquid tiles are unicomp")
  local character = surface.create_entity({ name = "character", position = { 0, 0 }, force = force })
  progression.arrive({ valid = true, character = character, force = force, physical_surface = surface })
  check(
    not force.technologies["quinityn-arrival"].researched,
    "physical presence without discovery cannot unlock survey"
  )
  force.technologies["planet-discovery-quinityn"].researched = true
  check(not force.technologies["quinityn-arrival"].researched, "discovery alone does not unlock Yuoki")
  -- Headless cannot create LuaPlayer instances. Exercise the landing handler with
  -- a narrow player facade backed by real force/surface/character objects.
  progression.arrive({
    valid = true,
    character = character,
    force = force,
    physical_surface = game.surfaces.nauvis,
    surface = surface,
  })
  check(not force.technologies["quinityn-arrival"].researched, "remote view does not count as physical landing")
  progression.arrive({ valid = true, character = character, force = force, physical_surface = surface })
  discovery_tests(surface)
  -- Mine a naturally generated stockpile into a real inventory, then verify its
  -- consumer is available after the actual arrival handler (no fabricated unlock).
  local wreck = surface.find_entities_filtered({ name = "quinityn-wreck", limit = 1 })[1]
  local mined = game.create_inventory(1)
  check(wreck.mine({ inventory = mined }), "natural stockpile can be mined")
  check(mined.get_item_count("quinityn-salvage") == 20, "stockpile yields the sorting ingredient")
  check(force.recipes["quinityn-hand-sort"].enabled, "arrival unlocks salvage sorting")
  check(not force.recipes["quinityn-hand-sort"].hidden, "salvage sorting is visible")
  mined.destroy()
  storage.test_surface = surface.index
  for _, name in ipairs({ "y-res1", "y-res2" }) do
    local amount = 0
    for _, ore in pairs(surface.find_entities_filtered({ name = name, area = { { -100, -100 }, { 100, 100 } } })) do
      amount = amount + ore.amount
    end
    check(amount >= 100000 and amount <= 150000, "rich starter deposit: " .. name .. "=" .. amount)
    local ores = surface.find_entities_filtered({ name = name, area = { { -100, -100 }, { 100, 100 } } })
    check(#ores >= 180, "larger organic starter patch: " .. name)
    local x, y = 0, 0
    for _, ore in pairs(ores) do
      x = x + ore.position.x
      y = y + ore.position.y
    end
    log("STARTER CENTROID " .. name .. " " .. x / #ores .. " " .. y / #ores)
  end
end)
script.on_event(defines.events.on_tick, function(event)
  local surface = game.surfaces[storage.test_surface]
  local force = game.forces.player
  if event.tick == 1 then
    check(force.technologies["quinityn-arrival"].researched, "physical landing opens survey")
    check(force.recipes["quinityn-water"].enabled, "landing unlocks water bootstrap")
    check(not force.recipes["y-crusher"].enabled, "landing does not grant advanced Yuoki recipes")
    check(not force.technologies["quinityn-materials"].researched, "materials still need research")
    local crusher_fixture = {
      { 66, 10 },
      { 67, 10 },
      { 68, 10 },
      { 69, 10 },
      { 70, 10 },
      { 66, 11 },
      { 67, 11 },
      { 68, 11 },
      { 69, 11 },
      { 70, 11 },
      { 66, 12 },
      { 67, 12 },
      { 68, 12 },
      { 69, 12 },
      { 70, 12 },
      { 66, 13 },
      { 67, 13 },
      { 68, 13 },
      { 69, 13 },
      { 70, 13 },
      { 66, 14 },
      { 67, 14 },
      { 68, 14 },
      { 69, 14 },
      { 70, 14 },
    }
    local crusher_tiles = {}
    for _, pos in ipairs(crusher_fixture) do
      crusher_tiles[#crusher_tiles + 1] = { name = "quinityn-basalt", position = pos }
    end
    surface.set_tiles(crusher_tiles)
    for _, entity in ipairs(surface.find_entities_filtered({ area = { { 65.9, 9.9 }, { 70.1, 14.1 } } })) do
      entity.destroy()
    end
    local crusher_spec = {
      name = "y-crusher",
      position = { 68, 12 },
      force = force,
      build_check_type = defines.build_check_type.manual,
    }
    check(surface.can_place_entity(crusher_spec), "yuoki crusher placement on quinityn")
    local crusher = surface.create_entity(crusher_spec)
    check(crusher and crusher.valid, "yuoki crusher created")
    check(crusher.set_recipe("quinityn-hand-sort"), "crusher selects salvage sorting before materials research")
    -- This engine's set_recipe returns a truthy value for an incompatible recipe and clears
    -- the selection. get_recipe() is the reject signal, not the call's return value.
    for _, recipe in ipairs({
      "quinityn-iron",
      "quinityn-copper",
      "quinityn-carbon",
      "quinityn-stone",
      "quinityn-timber",
    }) do
      check(crusher.set_recipe("quinityn-hand-sort"), "crusher keeps salvage sorting selected")
      crusher.set_recipe(recipe)
      local current = crusher.get_recipe()
      check(not current or current.name == "quinityn-hand-sort", "crusher rejects dressing recipe " .. recipe)
      if not current then
        check(crusher.set_recipe("quinityn-hand-sort"), "crusher restores salvage sorting after reject")
      end
    end
    for _, reject in ipairs({
      { "assembling-machine-1", { 66, 10 } },
      { "y-heat-form-press", { 67, 10 } },
      { "quinityn-burner-separator", { 69, 10 } },
    }) do
      local machine = surface.create_entity({ name = reject[1], position = reject[2], force = force })
      check(machine and machine.valid, reject[1] .. " placement")
      machine.set_recipe("quinityn-hand-sort")
      check(not machine.get_recipe(), reject[1] .. " rejects salvage sorting")
      machine.destroy()
    end
    storage.crusher = crusher
    -- Real burner inserters move the salvage. y_crusher2 collides 1.2 tiles from its
    -- center, so an inserter one tile away overlaps the machine and cannot reach a
    -- chest. Leave a two-tile gap. A north-facing burner inserter picks up one tile
    -- north and drops 1.2 tiles south, matching the unicomp disposal inserter above.
    -- This recipe has no fluid, so the crusher's fluid boxes stay off and no pipe is used.
    local crusher2_tiles = {}
    for x = 48, 52 do
      for y = 21, 29 do
        crusher2_tiles[#crusher2_tiles + 1] = { name = "quinityn-basalt", position = { x, y } }
      end
    end
    surface.set_tiles(crusher2_tiles)
    for _, entity in ipairs(surface.find_entities_filtered({ area = { { 47.5, 20.5 }, { 52.5, 29.5 } } })) do
      entity.destroy()
    end
    local crusher2_spec = {
      name = "y_crusher2",
      position = { 50, 25 },
      force = force,
      build_check_type = defines.build_check_type.manual,
    }
    check(surface.can_place_entity(crusher2_spec), "advanced crusher placement on quinityn")
    local crusher2 = surface.create_entity(crusher2_spec)
    check(
      crusher2 and crusher2.set_recipe("quinityn-hand-sort"),
      "advanced crusher selects salvage sorting before advanced machining"
    )
    storage.crusher2 = crusher2
    local nauvis = game.surfaces.nauvis
    nauvis.request_to_generate_chunks({ 0, 0 }, 1)
    nauvis.force_generate_chunk_requests()
    storage.nauvis_crusher = nauvis.create_entity({
      name = "y-crusher",
      position = { 0, 0 },
      force = force,
      raise_built = true,
    })
    check(offworld_tracked(storage.nauvis_crusher.unit_number), "nauvis crusher built after load is tracked")
    storage.nauvis_crusher.get_fuel_inventory().insert({ name = "coal", count = 5 })
    -- Select recipe before loading salvage; a cleared recipe would leave the machine empty.
    storage.nauvis_crusher.set_recipe("quinityn-hand-sort")
    local nauvis_recipe = storage.nauvis_crusher.get_recipe()
    check(nauvis_recipe and nauvis_recipe.name == "quinityn-hand-sort", "nauvis crusher active recipe is hand-sort")
    check(
      storage.nauvis_crusher.insert({ name = "quinityn-salvage", count = 1 }) == 1,
      "nauvis crusher accepts exactly one salvage"
    )
    check(
      storage.nauvis_crusher.get_inventory(defines.inventory.crafter_input).get_item_count("quinityn-salvage") == 1,
      "nauvis crusher input holds exactly one salvage"
    )
    storage.nauvis_crusher.get_inventory(defines.inventory.crafter_input).clear()
    storage.nauvis_crusher.get_fuel_inventory().clear()
    storage.nauvis_crusher.set_recipe(nil)
    local nauvis_crusher2_spec = {
      name = "y_crusher2",
      position = { 16, 8 },
      force = force,
      raise_built = true,
    }
    check(nauvis.can_place_entity(nauvis_crusher2_spec), "offworld y_crusher2 placement on nauvis")
    storage.nauvis_crusher2 = nauvis.create_entity(nauvis_crusher2_spec)
    check(offworld_tracked(storage.nauvis_crusher2.unit_number), "offworld y_crusher2 built after load is tracked")
    local quinityn_built_tiles = {}
    for x = 79, 81 do
      for y = 19, 21 do
        quinityn_built_tiles[#quinityn_built_tiles + 1] = { name = "quinityn-basalt", position = { x, y } }
      end
    end
    surface.set_tiles(quinityn_built_tiles)
    for _, entity in ipairs(surface.find_entities_filtered({ area = { { 78.9, 18.9 }, { 81.1, 21.1 } } })) do
      entity.destroy()
    end
    local quinityn_built_spec = {
      name = "y-crusher",
      position = { 80, 20 },
      force = force,
      raise_built = true,
    }
    check(surface.can_place_entity(quinityn_built_spec), "quinityn built-after-load crusher placement")
    local quinityn_built = surface.create_entity(quinityn_built_spec)
    check(quinityn_built and quinityn_built.valid, "quinityn built-after-load crusher created")
    check(not offworld_tracked(quinityn_built.unit_number), "quinityn crusher built after load is not tracked")
    quinityn_built.destroy({ raise_destroy = true })
    crusher.get_fuel_inventory().insert({ name = "coal", count = 10 })
    crusher.insert({ name = "quinityn-salvage", count = 1 })
    -- Isolated real machine fixture; ingredients and fuel are injected to test operation.
    local separator = surface.create_entity({ name = "quinityn-burner-separator", position = { 0, 12 }, force = force })
    check(separator and separator.valid, "burner separator placement")
    check(separator.set_recipe("quinityn-water"), "separator selects water recipe")
    separator.get_fuel_inventory().insert({ name = "y-res2", count = 10 })
    separator.insert_fluid({ name = "y-liquid-uc2", amount = 100 })
    storage.separator = separator
    local surplus_tech = force.technologies["quinityn-surplus"]
    local trigger = surplus_tech.prototype.research_trigger
    local trigger_item = trigger and trigger.item or nil
    if trigger_item and type(trigger_item) ~= "string" then
      trigger_item = trigger_item.name
    end
    -- LuaTechnology has no research_unit field; a craft trigger is the unit's absence.
    check(
      trigger and trigger.type == "craft-item" and trigger_item == "quinityn-burner-separator" and trigger.count == 1,
      "surplus is a one-craft trigger"
    )
    check(not surplus_tech.researched, "surplus stays locked until the separator is crafted")
    for _, name in ipairs({
      "quinityn-stone-to-uc",
      "quinityn-wood-to-uc",
      "quinityn-uc-to-coal",
      "quinityn-uc-to-iron",
      "quinityn-uc-to-copper",
    }) do
      check(not force.recipes[name].enabled, "surplus recipe locked before craft: " .. name)
    end
    local surplus_assembler =
      surface.create_entity({ name = "assembling-machine-1", position = { -8, 12 }, force = force })
    check(surplus_assembler and surplus_assembler.valid, "surplus craft assembler placement")
    check(surplus_assembler.set_recipe("quinityn-burner-separator"), "assembler selects primitive Cimota recipe")
    check(surplus_assembler.insert({ name = "iron-plate", count = 10 }) == 10, "assembler accepts iron plates")
    check(surplus_assembler.insert({ name = "copper-plate", count = 5 }) == 5, "assembler accepts copper plates")
    check(surplus_assembler.insert({ name = "stone", count = 10 }) == 10, "assembler accepts stone")
    storage.surplus_assembler = surplus_assembler
    local circuit_source = surface.create_entity({ name = "constant-combinator", position = { 4, 12 }, force = force })
    check(circuit_source and circuit_source.valid, "separator circuit source placement")
    for _, wire in ipairs({
      { "red", defines.wire_connector_id.circuit_red },
      { "green", defines.wire_connector_id.circuit_green },
    }) do
      local connector = separator.get_wire_connector(wire[2], true)
      local source = circuit_source.get_wire_connector(wire[2], true)
      check(connector.connect_to(source, true), "separator accepts nearby " .. wire[1] .. " circuit wire")
      check(connector.disconnect_from(source), "separator disconnects " .. wire[1] .. " circuit wire")
      check(connector.connect_to(source, true), "separator reconnects nearby " .. wire[1] .. " circuit wire")
    end
    -- Search actual generated coastline; no fixture pond or fixed shoreline coordinates.
    local sea = surface.find_tiles_filtered({ area = { { -250, -250 }, { 250, 250 } }, name = "quinityn-unicomp-sea" })
    for _, tile in ipairs(sea) do
      if storage.pump then
        break
      end
      for _, offset in ipairs({
        { 0, 1, defines.direction.north },
        { -1, 0, defines.direction.east },
        { 0, -1, defines.direction.south },
        { 1, 0, defines.direction.west },
      }) do
        local spec = {
          name = "offshore-pump",
          position = { tile.position.x + offset[1] + 0.5, tile.position.y + offset[2] + 0.5 },
          direction = offset[3],
          force = force,
          build_check_type = defines.build_check_type.manual,
        }
        if not storage.pump and surface.can_place_entity(spec) then
          storage.pump = surface.create_entity(spec)
        end
      end
    end
    check(storage.pump and storage.pump.valid, "offshore pump can be placed at unicomp inlet")
    local delta = ({
      [defines.direction.north] = { 0, 1 },
      [defines.direction.east] = { -1, 0 },
      [defines.direction.south] = { 0, -1 },
      [defines.direction.west] = { 1, 0 },
    })[storage.pump.direction]
    storage.pump_pipe = surface.create_entity({
      name = "pipe",
      position = { storage.pump.position.x + delta[1], storage.pump.position.y + delta[2] },
      force = force,
    })
    -- Native disposal by an inserter over the shore.
    for x = 8, 14 do
      for y = 28, 32 do
        surface.set_tiles({ { name = "quinityn-unicomp-sea", position = { x, y } } })
      end
    end
    local chest = surface.create_entity({ name = "steel-chest", position = { 10, 26 }, force = force })
    chest.insert({ name = "iron-plate", count = 10 })
    chest.insert({ name = "iron-plate", quality = "rare", count = 5 })
    local inserter = surface.create_entity({
      name = "burner-inserter",
      position = { 10, 27 },
      direction = defines.direction.north,
      force = force,
    })
    inserter.get_fuel_inventory().insert({ name = "coal", count = 10 })
    storage.chest = chest
    local other = game.create_force("unvisited")
    check(
      not other.technologies["quinityn-arrival"].researched and not other.recipes["y-crusher"].enabled,
      "new force remains locked"
    )
    force.technologies["quinityn-materials"].researched = true
    local salvage_source = surface.create_entity({ name = "steel-chest", position = { 50, 22 }, force = force })
    check(salvage_source and salvage_source.valid, "salvage source chest placement")
    salvage_source.insert({ name = "quinityn-salvage", count = 5 })
    local load_spec = {
      name = "burner-inserter",
      position = { 50, 23 },
      direction = defines.direction.north,
      force = force,
      build_check_type = defines.build_check_type.manual,
    }
    check(surface.can_place_entity(load_spec), "salvage load inserter placement")
    local load_inserter = surface.create_entity(load_spec)
    check(load_inserter and load_inserter.valid, "salvage load inserter created")
    load_inserter.get_fuel_inventory().clear()
    check(
      load_inserter.get_fuel_inventory().insert({ name = "coal", count = 10 }) == 10,
      "salvage load inserter takes coal"
    )
    local unload_spec = {
      name = "burner-inserter",
      position = { 50, 27 },
      direction = defines.direction.north,
      force = force,
      build_check_type = defines.build_check_type.manual,
    }
    check(surface.can_place_entity(unload_spec), "salvage unload inserter placement")
    local unload_inserter = surface.create_entity(unload_spec)
    check(unload_inserter and unload_inserter.valid, "salvage unload inserter created")
    unload_inserter.get_fuel_inventory().clear()
    check(
      unload_inserter.get_fuel_inventory().insert({ name = "coal", count = 10 }) == 10,
      "salvage unload inserter takes coal"
    )
    local salvage_sink = surface.create_entity({ name = "steel-chest", position = { 50, 28 }, force = force })
    check(salvage_sink and salvage_sink.valid, "salvage sink chest placement")
    -- Productivity is allowed on the machine, but this recipe sets allow_productivity
    -- false. The engine rejects the module while the recipe is selected and ejects
    -- one inserted beforehand, so the bonus cannot change the inserter-line yields.
    local modules = storage.crusher2.get_module_inventory()
    storage.crusher2.set_recipe(nil)
    check(
      modules.insert({ name = "productivity-module", count = 1 }) == 1,
      "advanced crusher module slot accepts a productivity module"
    )
    check(
      storage.crusher2.set_recipe("quinityn-hand-sort") and storage.crusher2.get_recipe().name == "quinityn-hand-sort",
      "salvage sorting stays selected after a productivity module is inserted"
    )
    check(modules.get_item_count("productivity-module") == 0, "salvage sorting ejects a productivity module")
    storage.salvage_source = salvage_source
    storage.salvage_sink = salvage_sink
    storage.salvage_load_inserter = load_inserter
    storage.salvage_unload_inserter = unload_inserter
    check(force.recipes["y-crusher"].enabled, "materials research unlocks crusher")
    check(
      force.recipes["y-crush-unicomp-raw"].enabled and not force.recipes["y-crush-blue_whead"].enabled,
      "Materials enables plain crushing but not tool-assisted crushing"
    )
    check(not force.recipes["y_crusher2"].enabled, "Materials does not unlock the second crusher")
    check(
      not force.recipes["y-heat-form-press"].enabled and not force.recipes["quinityn-research-data"].enabled,
      "Crushing does not unlock pressing or science"
    )
    force.technologies["quinityn-excavation"].researched = true
    check(
      force.recipes["y-digfdirt"].enabled and not force.recipes["y-digfdirt2"].enabled,
      "Excavation enables plain digging but not drill-head digging"
    )
    force.technologies["quinityn-tooling"].researched = true
    check(
      force.recipes["y-crush-blue_whead"].enabled and force.recipes["y-digfdirt2"].enabled,
      "Tooling unlocks head-assisted production only at its separate tier"
    )
    force.technologies["quinityn-advanced-machining"].researched = true
    check(force.recipes["y_crusher2"].enabled, "Advanced machining unlocks the second crusher")
    force.technologies["quinityn-oil-processing"].researched = true
    progression.research({ research = force.technologies["quinityn-oil-processing"] })
    check(force.technologies["oil-processing"].researched, "local crude-oil milestone grants oil processing")
    -- Fixture verifies actual native rocket construction/launch on this surface.
    force.technologies["rocket-silo"].researched = true
    storage.silo = surface.create_entity({ name = "rocket-silo", position = { -5, 40 }, force = force })
    check(storage.silo and storage.silo.valid, "rocket silo can be placed on Quinityn")
    for _, n in ipairs({ "rocket-fuel", "low-density-structure", "processing-unit" }) do
      storage.silo.insert({ name = n, count = 1000 })
    end
    storage.platform = force.create_space_platform({
      name = "Quinityn test receiver",
      planet = "quinityn",
      starter_pack = "space-platform-starter-pack",
    })
    check(storage.platform and storage.platform.apply_starter_pack(true), "receiving platform created")
    -- Engine collision and pathfinding must reject a unicomp crossing.
    local tiles = {}
    for x = 280, 320 do
      for y = 280, 320 do
        tiles[#tiles + 1] = { name = "quinityn-unicomp-sea", position = { x, y } }
      end
    end
    surface.set_tiles(tiles)
    for _, name in ipairs({ "small-biter", "medium-biter", "big-biter", "behemoth-biter", "small-spitter" }) do
      check(not surface.can_place_entity({
        name = name,
        position = { 300, 300 },
        build_check_type = defines.build_check_type.manual,
      }), name .. " cannot occupy unicomp")
    end
    local island = {}
    for x = 295, 305 do
      for y = 295, 305 do
        island[#island + 1] = { name = "quinityn-basalt", position = { x, y } }
      end
    end
    surface.set_tiles(island)
    surface.set_tiles({ { name = "quinityn-basalt", position = { 275, 300 } } })
    storage.biter_path = surface.request_path({
      bounding_box = { { -0.2, -0.2 }, { 0.2, 0.2 } },
      collision_mask = prototypes.entity["small-biter"].collision_mask,
      start = { 300.5, 300.5 },
      goal = { 275.5, 300.5 },
      force = game.forces.enemy,
      radius = 0.5,
      pathfind_flags = { allow_destroy_friendly_entities = false },
    })
    storage.biter_path_land = surface.request_path({
      bounding_box = { { -0.2, -0.2 }, { 0.2, 0.2 } },
      collision_mask = prototypes.entity["small-biter"].collision_mask,
      start = { 300.5, 300.5 },
      goal = { 303.5, 300.5 },
      force = game.forces.enemy,
      radius = 0.5,
      pathfind_flags = { allow_destroy_friendly_entities = false },
    })
    -- All three real factories operate both requested recipes. Vanilla assembler cannot select them.
    force.technologies["quinityn-industrial-science"].researched = true
    storage.factories = {}
    for i, name in ipairs({ "ye_fassembly1", "ye_fassembly2", "ye_fassembly_sp" }) do
      local machine = surface.create_entity({ name = name, position = { -25 + i * 8, 60 }, force = force })
      check(machine.set_recipe("quinityn-technic-sign"), name .. " selects dedicated signs recipe")
      for _, ingredient in pairs(prototypes.recipe["quinityn-technic-sign"].ingredients) do
        machine.insert({ name = ingredient.name, count = ingredient.amount })
      end
      storage.factories[#storage.factories + 1] = machine
    end
    local assembler = surface.create_entity({ name = "assembling-machine-3", position = { 30, 60 }, force = force })
    assembler.set_recipe("quinityn-research-data")
    check(assembler.get_recipe() == nil, "vanilla assembler rejects planet science")
    -- Programmatic research setters do not necessarily emit finished events; checked separately below.
  elseif event.tick == 2 then
    local platform_surface = storage.platform.surface
    check(
      platform_surface.count_entities_filtered({ name = { "y-crusher", "y_crusher2" } }) == 0,
      "test platform has no yuoki crusher after setup"
    )
    local platform_tiles = {}
    for x = 8, 13 do
      for y = -1, 1 do
        platform_tiles[#platform_tiles + 1] = { name = "space-platform-foundation", position = { x, y } }
      end
    end
    platform_surface.set_tiles(platform_tiles)
    local platform_spec = {
      name = "y-crusher",
      position = { 9, 0 },
      force = force,
      build_check_type = defines.build_check_type.manual,
      raise_built = true,
    }
    check(platform_surface.can_place_entity(platform_spec), "yuoki crusher placement on the test platform")
    local platform_crusher = platform_surface.create_entity(platform_spec)
    check(platform_crusher and platform_crusher.valid, "yuoki crusher created on the test platform")
    check(
      platform_surface.count_entities_filtered({ name = "y-crusher" }) == 1,
      "test platform has exactly one y-crusher"
    )
    check(offworld_tracked(platform_crusher.unit_number), "space platform crusher is tracked")
    check(not platform_crusher.get_recipe(), "space platform build does not select salvage sorting")
    storage.platform_crusher = platform_crusher
    storage.platform_crusher_unit = platform_crusher.unit_number
    local platform_inventory = game.create_inventory(1)
    platform_inventory[1].set_stack("blueprint")
    platform_inventory[1].set_blueprint_entities({
      {
        entity_number = 1,
        name = "y-crusher",
        position = { 0, 0 },
        recipe = "quinityn-hand-sort",
      },
    })
    local platform_ghosts = platform_inventory[1].build_blueprint({
      surface = platform_surface,
      force = force,
      position = { 12, 0 },
      skip_fog_of_war = true,
      build_mode = defines.build_mode.forced,
    })
    platform_inventory.destroy()
    local _, platform_revived
    if #platform_ghosts == 1 then
      check(not platform_ghosts[1].get_recipe(), "platform blueprint ghost does not keep salvage sorting")
      _, platform_revived = platform_ghosts[1].revive({ raise_revive = true })
    else
      check(#platform_ghosts == 0, "platform blueprint places no crusher ghost")
      local platform_ghost = platform_surface.create_entity({
        name = "entity-ghost",
        inner_name = "y-crusher",
        position = { 12, 0 },
        force = force,
      })
      check(platform_ghost and platform_ghost.valid, "platform crusher ghost created")
      platform_ghost.set_recipe("quinityn-hand-sort")
      _, platform_revived = platform_ghost.revive({ raise_revive = true })
    end
    check(platform_revived and platform_revived.valid, "platform crusher ghost revived")
    check(not platform_revived.get_recipe(), "platform revive does not select salvage sorting")
    check(platform_revived.products_finished == 0, "platform revive finishes no salvage sorts")
    check(offworld_tracked(platform_revived.unit_number), "revived platform crusher is tracked")
  elseif event.tick == 3 then
    local home = surface.find_entities_filtered({ name = "character", limit = 1 })[1]
    check(home and home.valid, "quinityn character can attempt salvage sorting")
    check(home.insert({ name = "quinityn-salvage", count = 1 }) == 1, "quinityn character receives salvage")
    local queued = home.begin_crafting({ recipe = "quinityn-hand-sort", count = 1 })
    local crafting_queue = home.crafting_queue
    check(queued == 1 and crafting_queue and #crafting_queue == 1, "hand crafting queues salvage sorting on quinityn")
    home.cancel_crafting({ index = 1, count = 1 })
    local queue_after = home.crafting_queue
    check(not queue_after or #queue_after == 0, "quinityn hand craft can be cancelled")
    local nauvis = game.surfaces.nauvis
    nauvis.request_to_generate_chunks({ 36, -12 }, 1)
    nauvis.force_generate_chunk_requests()
    local character_tiles = {}
    for x = 34, 38 do
      for y = -14, -10 do
        character_tiles[#character_tiles + 1] = { name = "grass-1", position = { x, y } }
      end
    end
    nauvis.set_tiles(character_tiles)
    for _, entity in ipairs(nauvis.find_entities_filtered({ area = { { 34, -14 }, { 39, -9 } } })) do
      entity.destroy()
    end
    local nauvis_character = nauvis.create_entity({ name = "character", position = { 36, -12 }, force = force })
    check(nauvis_character and nauvis_character.valid, "nauvis character created")
    check(nauvis_character.insert({ name = "quinityn-salvage", count = 1 }) == 1, "nauvis character receives salvage")
    local offworld_queued = nauvis_character.begin_crafting({ recipe = "quinityn-hand-sort", count = 1 })
    check(
      offworld_queued == 0 and nauvis_character.crafting_queue == nil,
      "hand crafting cannot queue salvage sorting off quinityn"
    )
  elseif event.tick == 300 then
    check(force.recipes["quinityn-hand-sort"].enabled, "hand-sort stays enabled for native selection")
    local native_tiles = {}
    for x = 22, 26 do
      for y = -2, 2 do
        native_tiles[#native_tiles + 1] = { name = "grass-1", position = { x, y } }
      end
    end
    game.surfaces.nauvis.set_tiles(native_tiles)
    for _, entity in ipairs(game.surfaces.nauvis.find_entities_filtered({ area = { { 21.5, -2.5 }, { 26.5, 2.5 } } })) do
      entity.destroy()
    end
    local inventory = game.create_inventory(1)
    inventory[1].set_stack("blueprint")
    inventory[1].set_blueprint_entities({
      {
        entity_number = 1,
        name = "y-crusher",
        position = { 0, 0 },
        recipe = "quinityn-hand-sort",
      },
    })
    local ghosts = inventory[1].build_blueprint({
      surface = game.surfaces.nauvis,
      force = force,
      position = { 24, 0 },
      skip_fog_of_war = true,
    })
    check(#ghosts == 1, "native offworld blueprint places one crusher ghost")
    local _, native = ghosts[1].revive({ raise_revive = true })
    check(native and native.valid, "native offworld crusher revived")
    check(not native.get_recipe(), "native blueprint does not select salvage sorting off quinityn")
    check(native.products_finished == 0, "native offworld crusher finishes no salvage sorts")
    check(offworld_tracked(native.unit_number), "revived offworld crusher is tracked")
    storage.native_crusher = native
    inventory.destroy()
  elseif event.tick == 301 then
    check(
      storage.crusher.get_recipe().name == "quinityn-hand-sort",
      "quinityn crusher keeps salvage sorting before copy"
    )
    storage.native_crusher.copy_settings(storage.crusher)
    check(not storage.native_crusher.get_recipe(), "copy settings does not select salvage sorting off quinityn")
    storage.platform_crusher.copy_settings(storage.crusher)
    check(
      not storage.platform_crusher.get_recipe(),
      "copy settings does not select salvage sorting on a space platform"
    )
    check(
      storage.crusher.get_recipe().name == "quinityn-hand-sort",
      "quinityn crusher keeps salvage sorting after copy"
    )
  elseif event.tick == 320 then
    local switched_spec = {
      name = "y-crusher",
      position = { 8, 8 },
      force = force,
      raise_built = true,
    }
    check(game.surfaces.nauvis.can_place_entity(switched_spec), "switched offworld crusher placement")
    storage.switched_crusher = game.surfaces.nauvis.create_entity(switched_spec)
    check(
      offworld_tracked(storage.switched_crusher.unit_number),
      "offworld crusher is tracked before hand-sort is selected"
    )
    check(not storage.switched_crusher.get_recipe(), "switched offworld crusher has no recipe yet")
    storage.switched_crusher_unit = storage.switched_crusher.unit_number
  elseif event.tick == 325 then
    local clone = storage.nauvis_crusher.clone({ position = { 8, 0 }, surface = game.surfaces.nauvis })
    check(clone and clone.valid, "nauvis crusher clone created")
    storage.clone_unit = clone.unit_number
    check(offworld_tracked(storage.clone_unit), "cloned offworld crusher is tracked")
    clone.destroy({ raise_destroy = true })
    check(not offworld_tracked(storage.clone_unit), "destroyed clone is not tracked")
  elseif event.tick == 330 then
    storage.switched_crusher.set_recipe("quinityn-hand-sort")
    local switched_recipe = storage.switched_crusher.get_recipe()
    check(
      switched_recipe and switched_recipe.name == "quinityn-hand-sort",
      "switched crusher active recipe is hand-sort"
    )
    storage.switched_crusher.get_fuel_inventory().insert({ name = "coal", count = 5 })
    check(
      storage.switched_crusher.insert({ name = "quinityn-salvage", count = 1 }) == 1,
      "switched crusher accepts exactly one salvage"
    )
    storage.switched_crusher.get_inventory(defines.inventory.crafter_input).clear()
    storage.switched_crusher.get_fuel_inventory().clear()
    storage.switched_crusher.set_recipe(nil)
  elseif event.tick == 640 then
    local mined_inventory = game.create_inventory(10)
    check(storage.switched_crusher.mine({ inventory = mined_inventory }), "switched offworld crusher mined")
    mined_inventory.destroy()
    check(not offworld_tracked(storage.switched_crusher_unit), "mined offworld crusher is not tracked")
  elseif event.tick == 650 then
    storage.nauvis_crusher2_unit = storage.nauvis_crusher2.unit_number
    check(storage.nauvis_crusher2.die(), "offworld y_crusher2 dies")
    check(not offworld_tracked(storage.nauvis_crusher2_unit), "destroyed offworld crusher is not tracked")
  elseif event.tick == 660 then
    local legacy_spec = {
      name = "y-crusher",
      position = { 8, 16 },
      force = force,
    }
    check(game.surfaces.nauvis.can_place_entity(legacy_spec), "legacy offworld crusher placement")
    storage.legacy_crusher = game.surfaces.nauvis.create_entity(legacy_spec)
    check(
      not offworld_tracked(storage.legacy_crusher.unit_number),
      "crusher created without a build event is not tracked yet"
    )
    remote.call("yuoki-quinityn", "clear_offworld_crusher_list")
  elseif event.tick == 662 then
    check(offworld_tracked(storage.legacy_crusher.unit_number), "migration rebuilds the offworld crusher list")
    check(offworld_tracked(storage.nauvis_crusher.unit_number), "migration keeps the loaded nauvis crusher")
    check(not offworld_tracked(storage.crusher.unit_number), "migration does not track quinityn crushers")
    check(not offworld_tracked(storage.switched_crusher_unit), "migration keeps mined crusher untracked")
    check(not offworld_tracked(storage.nauvis_crusher2_unit), "migration keeps died crusher untracked")
  elseif event.tick == 670 then
    local guard_settings = copy(game.surfaces.nauvis.map_gen_settings)
    guard_settings.seed = 8675309
    storage.salvage_guard_surface = game.create_surface("salvage-guard-surface", guard_settings)
    storage.salvage_guard_surface.request_to_generate_chunks({ 0, 0 }, 2)
    storage.salvage_guard_surface.force_generate_chunk_requests()
    for _, entity in ipairs(storage.salvage_guard_surface.find_entities_filtered({ area = { { -2, -2 }, { 2, 2 } } })) do
      entity.destroy()
    end
    local guard_spec = {
      name = "y-crusher",
      position = { 16, 16 },
      force = force,
      build_check_type = defines.build_check_type.manual,
      raise_built = true,
    }
    check(storage.salvage_guard_surface.can_place_entity(guard_spec), "salvage guard surface crusher placement")
    local guard_crusher = storage.salvage_guard_surface.create_entity(guard_spec)
    check(guard_crusher and guard_crusher.valid, "salvage guard surface crusher created")
    storage.salvage_guard_unit = guard_crusher.unit_number
    check(offworld_tracked(storage.salvage_guard_unit), "salvage guard surface crusher is tracked")
    game.delete_surface(storage.salvage_guard_surface)
  elseif event.tick == 672 then
    check(not offworld_tracked(storage.salvage_guard_unit), "crusher on a deleted surface is not tracked")
  elseif event.tick == 680 then
    local nauvis = game.surfaces.nauvis
    nauvis.request_to_generate_chunks({ 120, 120 }, 2)
    nauvis.force_generate_chunk_requests()
    local robot_tiles = {}
    for x = 112, 136 do
      for y = 112, 128 do
        robot_tiles[#robot_tiles + 1] = { name = "refined-concrete", position = { x, y } }
      end
    end
    nauvis.set_tiles(robot_tiles)
    for _, entity in ipairs(nauvis.find_entities_filtered({ area = { { 111, 111 }, { 137, 129 } } })) do
      entity.destroy()
    end
    local roboport = nauvis.create_entity({ name = "roboport", position = { 116, 120 }, force = force })
    check(roboport and roboport.valid, "offworld roboport created")
    roboport.energy = 100000000
    check(
      roboport.get_inventory(defines.inventory.roboport_robot).insert({ name = "construction-robot", count = 1 }) == 1,
      "offworld roboport receives a construction robot"
    )
    local provider = nauvis.create_entity({ name = "passive-provider-chest", position = { 122, 120 }, force = force })
    check(provider.insert({ name = "y-crusher", count = 1 }) == 1, "provider holds one yuoki crusher")
    local robot_inventory = game.create_inventory(1)
    robot_inventory[1].set_stack("blueprint")
    robot_inventory[1].set_blueprint_entities({
      {
        entity_number = 1,
        name = "y-crusher",
        position = { 0, 0 },
        recipe = "quinityn-hand-sort",
      },
    })
    local robot_ghosts = robot_inventory[1].build_blueprint({
      surface = nauvis,
      force = force,
      position = { 130, 120 },
      skip_fog_of_war = true,
    })
    robot_inventory.destroy()
    check(#robot_ghosts == 1, "robot blueprint places one crusher ghost")
    check(not robot_ghosts[1].get_recipe(), "robot blueprint ghost does not keep salvage sorting")
  elseif event.tick == 1100 then
    local built =
      game.surfaces.nauvis.find_entities_filtered({ name = "y-crusher", position = { 130, 120 }, radius = 1 })
    check(#built == 1, "construction robot builds one offworld crusher")
    check(not built[1].get_recipe(), "robot build does not select salvage sorting off quinityn")
    check(built[1].products_finished == 0, "robot-built crusher finishes no salvage sorts")
    check(offworld_tracked(built[1].unit_number), "robot-built offworld crusher is tracked")
    check(
      #game.surfaces.nauvis.find_entities_filtered({ name = "entity-ghost", position = { 130, 120 }, radius = 1 }) == 0,
      "construction robot revives the offworld crusher ghost"
    )
  elseif event.tick == 400 then
    local out = storage.crusher.get_output_inventory()
    check(storage.crusher.products_finished == 1, "quinityn crusher finishes one salvage sort")
    check(out.get_item_count("y-res1") == 2, "salvage sort yields two N4")
    check(out.get_item_count("y-res2") == 2, "salvage sort yields two F7")
    check(out.get_item_count("stone") == 2, "salvage sort yields two stone")
    check(out.get_item_count("wood") == 1, "salvage sort yields one wood")
    check(storage.crusher.get_item_count("quinityn-salvage") == 0, "salvage ingredient is consumed")
    for _, item in ipairs({ "y-res1", "y-res2", "stone", "wood" }) do
      while out.insert({ name = item, count = 100 }) == 100 do
      end
    end
    storage.crusher.get_fuel_inventory().insert({ name = "coal", count = 5 })
    check(
      storage.crusher.insert({ name = "quinityn-salvage", count = 1 }) == 1,
      "blocked crusher still accepts salvage"
    )
  elseif event.tick == 800 then
    -- A full output does not leave the ingredient waiting. The crusher consumes it and
    -- holds the finished craft at progress 1, so products_finished stays 1 until space exists.
    check(storage.crusher.products_finished == 1, "blocked crusher keeps one finished sort")
    check(storage.crusher.crafting_progress == 1, "blocked crusher holds the finished craft")
    check(
      storage.crusher.get_item_count("quinityn-salvage") == 0,
      "blocked crusher consumes salvage into the held craft"
    )
    if defines.entity_status.full_output ~= nil then
      check(storage.crusher.status == defines.entity_status.full_output, "blocked crusher reports full output")
    end
  elseif event.tick == 802 then
    storage.crusher.get_output_inventory().clear()
    check(
      storage.crusher.get_recipe().name == "quinityn-hand-sort",
      "crusher keeps salvage sorting selected while blocked"
    )
    storage.crusher.get_fuel_inventory().insert({ name = "coal", count = 10 })
  elseif event.tick == 480 then
    check(
      storage.separator.get_fluid_count("water") > 0,
      "primitive Cimota produces water burning raw F7 without grid power"
    )
    check(storage.pump_pipe.get_fluid_count("y-liquid-uc2") > 0, "offshore pump actually extracts Yuoki liquid unicomp")
  elseif event.tick == 1000 then
    local out = storage.crusher.get_output_inventory()
    check(storage.crusher.products_finished == 2, "quinityn crusher resumes after blocked output")
    check(out.get_item_count("y-res1") == 2, "resumed salvage sort yields two N4")
    check(out.get_item_count("y-res2") == 2, "resumed salvage sort yields two F7")
    check(out.get_item_count("stone") == 2, "resumed salvage sort yields two stone")
    check(out.get_item_count("wood") == 1, "resumed salvage sort yields one wood")
  elseif event.tick == 1200 then
    for _, machine in ipairs(storage.factories) do
      check(
        machine.get_output_inventory().get_item_count("y_rwtechsign") == 1,
        machine.name .. " produces exactly one sign"
      )
      machine.get_output_inventory().clear()
      check(machine.set_recipe("quinityn-research-data"), machine.name .. " selects planet science")
      for _, ingredient in pairs(prototypes.recipe["quinityn-research-data"].ingredients) do
        machine.insert({ name = ingredient.name, count = ingredient.name == "y-pol-waste" and 4 or ingredient.amount })
      end
    end
  elseif event.tick == 1500 then
    for _, machine in ipairs(storage.factories) do
      check(
        machine.get_output_inventory().is_empty() and machine.crafting_progress == 0,
        machine.name .. " cannot make science with only four flyash"
      )
      check(machine.insert({ name = "y-pol-waste", count = 1 }) == 1, machine.name .. " accepts the fifth flyash")
    end
    local assembler = storage.surplus_assembler
    check(assembler and assembler.valid and assembler.products_finished >= 1, "assembler crafted one primitive Cimota")
    check(force.technologies["quinityn-surplus"].researched, "crafting the primitive Cimota researches surplus")
    for _, name in ipairs({
      "quinityn-stone-to-uc",
      "quinityn-wood-to-uc",
      "quinityn-uc-to-coal",
      "quinityn-uc-to-iron",
      "quinityn-uc-to-copper",
    }) do
      check(force.recipes[name].enabled, "craft trigger unlocks " .. name)
    end
    local conversion =
      surface.create_entity({ name = "quinityn-burner-separator", position = { 0, 18 }, force = force })
    check(conversion and conversion.valid, "conversion separator placement")
    -- set_recipe returns removed items, not success, so the selected recipe is the proof.
    force.recipes["y-ac-stone2uc"].enabled = true
    conversion.set_recipe("y-ac-stone2uc")
    check(conversion.get_recipe() == nil, "primitive separator rejects full Cimota stone recipe")
    check(not force.technologies["quinityn-cimota"].researched, "category rejection does not research full Cimota")
    force.recipes["y-ac-stone2uc"].enabled = false
    conversion.set_recipe("quinityn-stone-to-uc")
    local selected = conversion.get_recipe()
    check(selected and selected.name == "quinityn-stone-to-uc", "primitive separator selects stone to UC")
    check(conversion.insert({ name = "stone", count = 40 }) == 40, "conversion separator accepts stone")
    conversion.get_fuel_inventory().insert({ name = "y-res2", count = 10 })
    storage.conversion_separator = conversion
    local surplus_recipe_names = {
      "quinityn-stone-to-uc",
      "quinityn-wood-to-uc",
      "quinityn-uc-to-coal",
      "quinityn-uc-to-iron",
      "quinityn-uc-to-copper",
    }
    local function check_surplus_recipes_disabled(target)
      for _, name in ipairs(surplus_recipe_names) do
        check(not target.recipes[name].enabled, "surplus recipe locked: " .. name)
      end
    end
    local function check_surplus_recipes_enabled(target)
      for _, name in ipairs(surplus_recipe_names) do
        check(target.recipes[name].enabled, "surplus recipe enabled: " .. name)
      end
    end
    local surveyed_uncrafted = game.create_force("surveyed-uncrafted")
    surveyed_uncrafted.technologies["quinityn-arrival"].researched = true
    check_surplus_recipes_disabled(surveyed_uncrafted)
    local migration_crafted = game.create_force("migration-crafted")
    migration_crafted.technologies["quinityn-arrival"].researched = true
    migration_crafted.technologies["quinityn-materials"].researched = true
    migration_crafted.recipes["quinityn-uc-to-coal"].enabled = false
    local done = game.create_force("surplus-done")
    done.technologies["quinityn-arrival"].researched = true
    done.technologies["quinityn-surplus"].researched = true
    done.recipes["quinityn-uc-to-iron"].enabled = false
    progression.reconcile()
    check(
      not surveyed_uncrafted.technologies["quinityn-surplus"].researched,
      "arrival-only force stays without surplus after reconcile"
    )
    check_surplus_recipes_disabled(surveyed_uncrafted)
    check(migration_crafted.technologies["quinityn-surplus"].researched, "migration force receives surplus")
    check_surplus_recipes_enabled(migration_crafted)
    check(
      done.technologies["quinityn-surplus"].researched and done.recipes["quinityn-uc-to-iron"].enabled,
      "reconcile keeps recipes enabled when surplus is already researched"
    )
    check(
      not game.forces.unvisited.technologies["quinityn-surplus"].researched
        and not game.forces.unvisited.recipes["quinityn-stone-to-uc"].enabled,
      "reconcile leaves an unsurveyed force locked"
    )
    progression.reconcile()
    check(
      not surveyed_uncrafted.technologies["quinityn-surplus"].researched,
      "arrival-only force stays without surplus after a second reconcile"
    )
    check_surplus_recipes_disabled(surveyed_uncrafted)
    check(
      migration_crafted.technologies["quinityn-surplus"].researched
        and migration_crafted.recipes["quinityn-wood-to-uc"].enabled,
      "a second reconcile keeps migration surplus unlocked"
    )
    check(
      not game.forces.unvisited.recipes["quinityn-uc-to-copper"].enabled,
      "a second reconcile still leaves an unsurveyed force locked"
    )
    local merge_uncrafted = game.create_force("merge-uncrafted")
    merge_uncrafted.technologies["quinityn-arrival"].researched = true
    game.create_force("merge-uncrafted-src").technologies["quinityn-arrival"].researched = true
    game.merge_forces("merge-uncrafted-src", "merge-uncrafted")
    local merge_crafted = game.create_force("merge-crafted")
    merge_crafted.technologies["quinityn-arrival"].researched = true
    merge_crafted.technologies["quinityn-materials"].researched = true
    merge_crafted.recipes["quinityn-uc-to-iron"].enabled = false
    game.create_force("merge-crafted-src")
    game.merge_forces("merge-crafted-src", "merge-crafted")
  elseif event.tick == 3600 then
    local output = storage.conversion_separator.get_output_inventory()
    check(output.get_item_count("y-unicomp-a2") >= 1, "primitive stone conversion yields UC-A2")
    check(
      output.get_item_count("coal") == 0
        and output.get_item_count("iron-ore") == 0
        and output.get_item_count("copper-ore") == 0,
      "stone-only primitive conversion does not yield coal or ore"
    )
  elseif event.tick == 2400 then
    for _, machine in ipairs(storage.factories) do
      check(
        machine.get_output_inventory().get_item_count("quinityn-research-data") == 5,
        machine.name .. " produces science"
      )
      check(machine.get_item_count("y-pol-waste") == 0, machine.name .. " consumes five flyash for five science packs")
    end
    check(storage.surplus_merge_checked, "force merge reconcile ran")
    check(storage.biter_path_land_passed, "biter path succeeds on dry land control")
    check(storage.biter_path_blocked, "biter path cannot cross unicomp moat")
    check(storage.chest.get_item_count("iron-plate") == 0, "inserter discards into unicomp")
    check(storage.chest.get_item_count({ name = "iron-plate", quality = "rare" }) == 0, "quality items also dissolve")
    check(
      surface.count_entities_filtered({ type = "item-entity", area = { { 8, 28 }, { 14, 32 } } }) == 0,
      "discarded items are destroyed"
    )
    check(prototypes.technology["quinityn-mining-productivity"].max_level == 4294967295, "mining research is infinite")
    check(prototypes.technology["quinityn-plasma-damage"].max_level == 4294967295, "plasma research is infinite")
    force.recipes["iron-gear-wheel"].enabled = false
    progression.reconcile()
    check(not force.recipes["iron-gear-wheel"].enabled, "configuration reconciliation preserves unrelated recipe state")
    check(force.recipes["y-crusher"].enabled, "configuration reconciliation preserves researched Yuoki recipes")
    local function prerequisites(name)
      for _, t in pairs(force.technologies[name].prerequisites) do
        prerequisites(t.name)
        t.researched = true
      end
    end
    prerequisites("quinityn-mining-productivity")
    storage.lab = surface.create_entity({ name = "lab", position = { 20, 12 }, force = force })
    storage.mining_bonus = force.mining_drill_productivity_bonus
    storage.plasma_bonus = force.get_ammo_damage_modifier("plasma")
    force.laboratory_speed_modifier = 999
    check(force.add_research("quinityn-mining-productivity"), "infinite mining research can be selected")
    storage.productivity_pairs = {}
    for i, name in ipairs({ "ye_fassembly1", "ye_fassembly2", "ye_fassembly_sp" }) do
      local x = -25 + i * 8
      local moduled = surface.create_entity({ name = name, position = { x, 88 }, force = force })
      local control = surface.create_entity({ name = name, position = { x, 96 }, force = force })
      check(moduled and moduled.valid and control and control.valid, name .. " productivity fixture placement")
      check(moduled.set_recipe("quinityn-research-data"), name .. " moduled fixture selects planet science")
      check(control.set_recipe("quinityn-research-data"), name .. " control fixture selects planet science")
      local mod_inv = moduled.get_module_inventory()
      local slots = #mod_inv
      local inserted = 0
      while inserted < slots do
        local count = mod_inv.insert({ name = "productivity-module-3", count = 1 })
        if count == 0 then
          break
        end
        inserted = inserted + count
      end
      check(inserted == slots, name .. " moduled fixture fills every module slot")
      storage.productivity_pairs[#storage.productivity_pairs + 1] =
        { moduled = moduled, control = control, name = name }
    end
  elseif event.tick == 2401 then
    local recipe = prototypes.recipe["quinityn-research-data"]
    local check_tick = 0
    for _, pair in ipairs(storage.productivity_pairs or {}) do
      local moduled, control = pair.moduled, pair.control
      check(moduled.valid and control.valid, pair.name .. " productivity fixtures remain valid")
      local mod_bonus = moduled.productivity_bonus
      local ctrl_bonus = control.productivity_bonus
      check(mod_bonus > 0, pair.name .. " moduled fixture has productivity bonus")
      check(ctrl_bonus == 0, pair.name .. " control fixture has no productivity bonus")
      local speed = moduled.crafting_speed
      local crafts = math.ceil(1 / mod_bonus)
      local extra_cycles = math.floor(crafts * mod_bonus + 1e-6)
      pair.crafts = crafts
      pair.extra_cycles = extra_cycles
      pair.mod_bonus = mod_bonus
      for _, machine in ipairs({ moduled, control }) do
        for _, ingredient in pairs(recipe.ingredients) do
          machine.insert({ name = ingredient.name, count = ingredient.amount * crafts })
        end
      end
      local deadline = math.ceil(recipe.energy * crafts / speed * 60) + 180
      if deadline > check_tick then
        check_tick = deadline
      end
    end
    local absolute = 2401 + check_tick
    if absolute == 3600 or absolute == 4000 or absolute == 8500 or absolute == 15000 then
      absolute = absolute + 1
    end
    check(absolute < 15000, "productivity fixture finishes before benchmark end")
    storage.productivity_check_tick = absolute
  elseif event.tick == storage.productivity_check_tick then
    for _, pair in ipairs(storage.productivity_pairs or {}) do
      local moduled, control = pair.moduled, pair.control
      local crafts, extra_cycles, bonus = pair.crafts, pair.extra_cycles, pair.mod_bonus
      local mod_out = moduled.get_output_inventory().get_item_count("quinityn-research-data")
      local ctrl_out = control.get_output_inventory().get_item_count("quinityn-research-data")
      local expected_mod = (crafts + extra_cycles) * 5
      local expected_ctrl = crafts * 5
      check(ctrl_out == expected_ctrl, pair.name .. " control produces baseline science packs")
      check(mod_out == expected_mod, pair.name .. " moduled produces bonus science packs")
      check(mod_out > ctrl_out, pair.name .. " moduled output exceeds control")
      check(
        moduled.is_crafting() == false and control.is_crafting() == false,
        pair.name .. " productivity crafts finished"
      )
      for _, machine in ipairs({ moduled, control }) do
        check(machine.get_item_count("y-pol-waste") == 0, pair.name .. " consumes all flyash")
        for _, ingredient in pairs(prototypes.recipe["quinityn-research-data"].ingredients) do
          if ingredient.name ~= "y-pol-waste" then
            check(machine.get_item_count(ingredient.name) == 0, pair.name .. " consumes " .. ingredient.name)
          end
        end
      end
      local progress = moduled.bonus_progress
      check(
        math.abs(progress - (crafts * bonus - extra_cycles)) < 1e-3,
        pair.name .. " bonus progress matches cycle math"
      )
      check(
        moduled.get_item_count({ name = "quinityn-research-data", quality = "uncommon" }) == 0
          and moduled.get_item_count({ name = "quinityn-research-data", quality = "rare" }) == 0,
        pair.name .. " bonus packs stay normal quality"
      )
      check(
        moduled.productivity_bonus > 0 and control.productivity_bonus == 0,
        pair.name .. " productivity bonus only on moduled machine"
      )
    end
    log("QUINITYN PASS: productivity modules add bonus industrial research data without extra ingredients")
  elseif event.tick == 4000 then
    check(storage.crusher2.get_recipe().name == "quinityn-hand-sort", "advanced crusher keeps salvage sorting recipe")
    check(storage.salvage_sink.get_item_count("y-res1") == 10, "advanced crusher inserter line yields ten N4")
    check(storage.salvage_sink.get_item_count("y-res2") == 10, "advanced crusher inserter line yields ten F7")
    check(storage.salvage_sink.get_item_count("stone") == 10, "advanced crusher inserter line yields ten stone")
    check(storage.salvage_sink.get_item_count("wood") == 5, "advanced crusher inserter line yields five wood")
    check(
      storage.salvage_source.get_item_count("quinityn-salvage") == 0,
      "advanced crusher inserter line consumes all salvage"
    )
    check(
      storage.crusher2.get_output_inventory().is_empty(),
      "advanced crusher inserter line leaves machine output empty"
    )
  elseif event.tick == 8500 then
    check(
      force.mining_drill_productivity_bonus > storage.mining_bonus,
      "Quinityn science grants native infinite mining bonus"
    )
    force.cancel_current_research()
    check(force.add_research("quinityn-plasma-damage"), "infinite plasma research can be selected")
  end
  for _, machine in ipairs(storage.factories or {}) do
    machine.energy = 10000000
  end
  if storage.surplus_assembler and storage.surplus_assembler.valid then
    storage.surplus_assembler.energy = 100000000
  end
  for _, pair in ipairs(storage.productivity_pairs or {}) do
    if pair.moduled and pair.moduled.valid then
      pair.moduled.energy = 10000000
    end
    if pair.control and pair.control.valid then
      pair.control.energy = 10000000
    end
  end
  if storage.crusher2 and storage.crusher2.valid then
    storage.crusher2.energy = 10000000
  end
  for _, inserter in ipairs({ storage.salvage_load_inserter, storage.salvage_unload_inserter }) do
    local fuel = inserter and inserter.valid and inserter.get_fuel_inventory()
    if fuel and fuel.get_item_count("coal") < 5 then
      fuel.insert({ name = "coal", count = 10 })
    end
  end
  if storage.lab and storage.lab.valid then
    storage.lab.energy = 10000000
    for _, name in ipairs({
      "automation-science-pack",
      "logistic-science-pack",
      "chemical-science-pack",
      "production-science-pack",
      "utility-science-pack",
      "space-science-pack",
      "quinityn-research-data",
    }) do
      storage.lab.insert({ name = name, count = 2 })
    end
  end
  if storage.silo and storage.silo.valid then
    storage.silo.energy = 100000000
    for _, name in ipairs({ "rocket-fuel", "low-density-structure", "processing-unit" }) do
      storage.silo.insert({ name = name, count = 10 })
    end
    if not storage.launched and storage.silo.rocket_silo_status == defines.rocket_silo_status.rocket_ready then
      storage.launched =
        storage.silo.launch_rocket({ type = defines.cargo_destination.station, station = storage.platform.hub })
      if storage.launched then
        log("QUINITYN PASS: real rocket launched from Quinityn")
      end
    end
  end
  if event.tick == 15000 then
    log(
      "Rocket final state: parts="
        .. storage.silo.rocket_parts
        .. " status="
        .. storage.silo.rocket_silo_status
        .. " active="
        .. tostring(storage.silo.active)
    )
    check(storage.launched, "native rocket construction and launch")
    check(
      force.get_ammo_damage_modifier("plasma") > storage.plasma_bonus,
      "Quinityn science grants native infinite plasma bonus"
    )
    storage.runtime_tests_passed = true
    log("QUINITYN RUNTIME TESTS PASSED")
  end
end)

script.on_event(defines.events.on_forces_merged, function()
  storage.surplus_merge_checked = true
  local surplus_recipe_names = {
    "quinityn-stone-to-uc",
    "quinityn-wood-to-uc",
    "quinityn-uc-to-coal",
    "quinityn-uc-to-iron",
    "quinityn-uc-to-copper",
  }
  local merge_uncrafted = game.forces["merge-uncrafted"]
  check(
    not merge_uncrafted.technologies["quinityn-surplus"].researched
      and not merge_uncrafted.technologies["quinityn-materials"].researched,
    "merged uncrafted destination stays without materials or surplus"
  )
  for _, name in ipairs(surplus_recipe_names) do
    check(not merge_uncrafted.recipes[name].enabled, "merged uncrafted destination keeps " .. name .. " disabled")
  end
  local merge_crafted = game.forces["merge-crafted"]
  check(merge_crafted.technologies["quinityn-surplus"].researched, "merged crafted destination receives surplus")
  for _, name in ipairs(surplus_recipe_names) do
    check(merge_crafted.recipes[name].enabled, "merged crafted destination enables " .. name)
  end
  check(game.forces.player.technologies["quinityn-surplus"].researched, "player surplus survives force merge reconcile")
end)

script.on_event(defines.events.on_script_path_request_finished, function(e)
  if e.id == storage.biter_path then
    check(not e.try_again_later, "biter path request completed")
    storage.biter_path_blocked = e.path == nil
  elseif e.id == storage.biter_path_land then
    storage.biter_path_land_passed = not e.try_again_later and e.path ~= nil
  end
end)
