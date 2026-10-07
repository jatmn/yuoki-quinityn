local progression=require("__yuoki-quinityn__/scripts/progression")
local function check(condition,message)
  if not condition then error("QUINITYN TEST FAILED: "..message) end
  log("QUINITYN PASS: "..message)
end
script.on_init(function()
  local force=game.forces.player
  check(not settings.startup["yuoki-start-with-yi-suit"].value,"upstream starting suit cannot bypass visit gate")
  check(not force.technologies["quinityn-arrival"].researched,"arrival locked before landing")
  check(not force.recipes["y-crusher"].enabled,"Yuoki locked before landing")
  check(not force.recipes["ye_farm"].enabled,"Engines locked before landing")
  force.technologies["planet-discovery-quinityn"].researched=true
  check(not force.technologies["quinityn-arrival"].researched,"discovery alone does not unlock Yuoki")
  local surface=game.planets.quinityn.create_surface()
  surface.request_to_generate_chunks({0,0},12)
  surface.force_generate_chunk_requests()
  check(surface.get_tile(64,0).name=="quinityn-unicomp-sea","guaranteed unicomp inlet")
  check(surface.get_tile(0,0).name=="quinityn-basalt","dry landing plateau")
  check(surface.count_entities_filtered{name="y-res1",area={{-40,-30},{-16,-6}}}>0,"starter N4 patch")
  check(surface.count_entities_filtered{name="y-res2",area={{16,-30},{40,-6}}}>0,"starter F7 patch")
  check(surface.count_entities_filtered{name="quinityn-wreck"}>0,"salvage generates")
  check(surface.count_entities_filtered{type="unit-spawner"}>0,"biter bases generate")
  check(surface.count_entities_filtered{name={"iron-ore","copper-ore","crude-oil"}}==0,"no imported vanilla deposits")
  local water=surface.find_tiles_filtered{area={{-300,-300},{300,300}},name={"water","deepwater","lava","oil-ocean-deep"}}
  check(#water==0,"all natural liquid tiles are unicomp")
  local character=surface.create_entity{name="character",position={0,0},force=force}
  -- Headless cannot create LuaPlayer instances. Exercise the landing handler with
  -- a narrow player facade backed by real force/surface/character objects.
  progression.arrive{valid=true,character=character,force=force,
    physical_surface=game.surfaces.nauvis,surface=surface}
  check(not force.technologies["quinityn-arrival"].researched,"remote view does not count as physical landing")
  progression.arrive{valid=true,character=character,force=force,physical_surface=surface}
  storage.test_surface=surface.index
  for _, name in ipairs({"y-res1","y-res2"}) do
    local amount=0
    for _, ore in pairs(surface.find_entities_filtered{name=name,area={{-100,-100},{100,100}}}) do amount=amount+ore.amount end
    check(amount>0 and amount<=9800,"small starter deposit: "..name.."="..amount)
  end

end)
script.on_event(defines.events.on_tick,function(event)
  local surface=game.surfaces[storage.test_surface]
  local force=game.forces.player
  if event.tick==1 then
    check(force.technologies["quinityn-arrival"].researched,"physical landing opens survey")
    check(force.recipes["quinityn-water"].enabled,"landing unlocks water bootstrap")
    check(not force.recipes["y-crusher"].enabled,"landing does not grant advanced Yuoki recipes")
    check(not force.technologies["quinityn-materials"].researched,"materials still need research")
    -- Isolated real machine fixture; ingredients and fuel are injected to test operation.
    local separator=surface.create_entity{name="quinityn-burner-separator",position={0,12},force=force}
    check(separator and separator.valid,"burner separator placement")
    check(separator.set_recipe("quinityn-water"),"separator selects water recipe")
    separator.get_fuel_inventory().insert{name="coal",count=10}
    separator.insert_fluid{name="y-liquid-uc2",amount=100}
    storage.separator=separator
    for x=48,54 do
      for y=-2,2 do
        for _, direction in ipairs({defines.direction.north,defines.direction.east,defines.direction.south,defines.direction.west}) do
          local spec={name="offshore-pump",position={x+0.5,y+0.5},direction=direction,force=force,build_check_type=defines.build_check_type.manual}
          if not storage.pump and surface.can_place_entity(spec) then storage.pump=surface.create_entity(spec) end
        end
      end
    end
    check(storage.pump and storage.pump.valid,"offshore pump can be placed at unicomp inlet")
    local delta=({[defines.direction.north]={0,1},[defines.direction.east]={-1,0},
      [defines.direction.south]={0,-1},[defines.direction.west]={1,0}})[storage.pump.direction]
    storage.pump_pipe=surface.create_entity{name="pipe",position={storage.pump.position.x+delta[1],storage.pump.position.y+delta[2]},force=force}
    -- Native disposal by an inserter over the shore.
    for x=8,14 do for y=28,32 do surface.set_tiles{{name="quinityn-unicomp-sea",position={x,y}}} end end
    local chest=surface.create_entity{name="steel-chest",position={10,26},force=force}
    chest.insert{name="iron-plate",count=10}
    chest.insert{name="iron-plate",quality="rare",count=5}
    local inserter=surface.create_entity{name="burner-inserter",position={10,27},direction=defines.direction.north,force=force}
    inserter.get_fuel_inventory().insert{name="coal",count=10}
    storage.chest=chest
    local other=game.create_force("unvisited")
    check(not other.technologies["quinityn-arrival"].researched and not other.recipes["y-crusher"].enabled,"new force remains locked")
    force.technologies["quinityn-materials"].researched=true
    check(force.recipes["y-crusher"].enabled,"materials research unlocks crusher")
    force.technologies["quinityn-oil-processing"].researched=true
    progression.research{research=force.technologies["quinityn-oil-processing"]}
    check(force.technologies["oil-processing"].researched,"local crude-oil milestone grants oil processing")
    -- Fixture verifies actual native rocket construction/launch on this surface.
    force.technologies["rocket-silo"].researched=true
    storage.silo=surface.create_entity{name="rocket-silo",position={-5,40},force=force}
    check(storage.silo and storage.silo.valid,"rocket silo can be placed on Quinityn")
    for _, n in ipairs({"rocket-fuel","low-density-structure","processing-unit"}) do
      storage.silo.insert{name=n,count=1000}
    end
    storage.platform=force.create_space_platform{name="Quinityn test receiver",planet="quinityn",starter_pack="space-platform-starter-pack"}
    check(storage.platform and storage.platform.apply_starter_pack(true),"receiving platform created")
    -- Programmatic research setters do not necessarily emit finished events; checked separately below.
  elseif event.tick==240 then
    check(storage.separator.get_fluid_count("water")>0,"burner separator actually produces water without grid power")
    check(storage.pump_pipe.get_fluid_count("y-liquid-uc2")>0,"offshore pump actually extracts Yuoki liquid unicomp")
  elseif event.tick==2400 then
    check(storage.chest.get_item_count("iron-plate")==0,"inserter discards into unicomp")
    check(storage.chest.get_item_count{name="iron-plate",quality="rare"}==0,"quality items also dissolve")
    check(surface.count_entities_filtered{type="item-entity",area={{8,28},{14,32}}}==0,"discarded items are destroyed")
    check(prototypes.technology["quinityn-mining-productivity"].max_level==4294967295,"mining research is infinite")
    check(prototypes.technology["quinityn-plasma-damage"].max_level==4294967295,"plasma research is infinite")
    force.recipes["iron-gear-wheel"].enabled=false
    progression.reconcile()
    check(not force.recipes["iron-gear-wheel"].enabled,"configuration reconciliation preserves unrelated recipe state")
    check(force.recipes["y-crusher"].enabled,"configuration reconciliation preserves researched Yuoki recipes")
    local function prerequisites(name)
      for _, t in pairs(force.technologies[name].prerequisites) do
        prerequisites(t.name)
        t.researched=true
      end
    end
    prerequisites("quinityn-mining-productivity")
    storage.lab=surface.create_entity{name="lab",position={20,12},force=force}
    storage.mining_bonus=force.mining_drill_productivity_bonus
    storage.plasma_bonus=force.get_ammo_damage_modifier("plasma")
    force.laboratory_speed_modifier=999
    check(force.add_research("quinityn-mining-productivity"),"infinite mining research can be selected")
  elseif event.tick==8500 then
    check(force.mining_drill_productivity_bonus>storage.mining_bonus,"Quinityn science grants native infinite mining bonus")
    force.cancel_current_research()
    check(force.add_research("quinityn-plasma-damage"),"infinite plasma research can be selected")
  end
  if storage.lab and storage.lab.valid then
    storage.lab.energy=10000000
    for _, name in ipairs({"automation-science-pack","logistic-science-pack","chemical-science-pack",
      "production-science-pack","utility-science-pack","space-science-pack","quinityn-research-data"}) do
      storage.lab.insert{name=name,count=2}
    end
  end
  if storage.silo and storage.silo.valid then
    storage.silo.energy=100000000
    for _, name in ipairs({"rocket-fuel","low-density-structure","processing-unit"}) do
      storage.silo.insert{name=name,count=10}
    end
    if not storage.launched and storage.silo.rocket_silo_status==defines.rocket_silo_status.rocket_ready then
      storage.launched=storage.silo.launch_rocket({type=defines.cargo_destination.station,station=storage.platform.hub})
      if storage.launched then log("QUINITYN PASS: real rocket launched from Quinityn") end
    end
  end
  if event.tick==15000 then
    log("Rocket final state: parts="..storage.silo.rocket_parts.." status="..storage.silo.rocket_silo_status.." active="..tostring(storage.silo.active))
    check(storage.launched,"native rocket construction and launch")
    check(force.get_ammo_damage_modifier("plasma")>storage.plasma_bonus,"Quinityn science grants native infinite plasma bonus")
    storage.runtime_tests_passed=true
    log("QUINITYN RUNTIME TESTS PASSED")
  end
end)
