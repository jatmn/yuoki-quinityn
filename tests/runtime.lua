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
  local surface=game.planets.quinityn.create_surface()
  surface.request_to_generate_chunks({0,0},12)
  surface.force_generate_chunk_requests()
  check(surface.get_tile(64,0).name~="quinityn-unicomp-sea","artificial starter pond removed")
  check(surface.get_tile(0,0).name=="quinityn-basalt","dry landing plateau")

  check(surface.count_entities_filtered{name="quinityn-wreck",area={{-160,-160},{160,160}}}>=15,"abundant clustered starter salvage")
  check(#surface.find_decoratives_filtered{area={{-200,-200},{200,200}}}>100,"cosmetic decoratives generate")
  local natural_decoratives={"quinityn-dead-shrub","quinityn-dry-tuft","quinityn-dead-grass",
    "quinityn-dead-groundcover","quinityn-tiny-rock","quinityn-small-rock"}
  for _,name in ipairs(natural_decoratives) do
    local placed=surface.find_decoratives_filtered{area={{-360,-360},{360,360}},name=name}
    check(#placed>10,"natural ground detail generates: "..name)
    for _,d in pairs(placed) do
      local tile=surface.get_tile(d.position).name
      assert(tile=="quinityn-weathered-soil" or tile=="quinityn-dead-turf" or tile=="quinityn-ash-soil",
        "Natural detail outside old soil: "..name)
    end
    log("NATURAL DETAIL "..name.." placements="..#placed)
  end
  local rows={}
  local codes={["quinityn-unicomp-sea"]="~",["quinityn-basalt"]=".",["quinityn-slag"]="s",
    ["quinityn-ruined-district"]="m",["quinityn-ash"]="a",["quinityn-rubble"]="r",
    ["quinityn-weathered-soil"]="d",["quinityn-dead-turf"]="g",["quinityn-ash-soil"]="e"}
  for y=-360,358,2 do
    local row={}
    for x=-360,358,2 do row[#row+1]=codes[surface.get_tile(x,y).name] or "?" end
    rows[#rows+1]=table.concat(row)
  end
  local wrecks={}
  for _,e in pairs(surface.find_entities_filtered{name="quinityn-wreck"}) do wrecks[#wrecks+1]=e.position end
  helpers.write_file("quinityn-map-"..surface.map_gen_settings.seed..".json",
    helpers.table_to_json{seed=surface.map_gen_settings.seed,rows=rows,wrecks=wrecks},false)
  check(surface.count_entities_filtered{type="unit-spawner"}>0,"biter bases generate")
  check(surface.count_entities_filtered{name={"iron-ore","copper-ore","crude-oil"}}==0,"no imported vanilla deposits")
  local water=surface.find_tiles_filtered{area={{-300,-300},{300,300}},name={"water","deepwater","lava","oil-ocean-deep"}}
  check(#water==0,"all natural liquid tiles are unicomp")
  local character=surface.create_entity{name="character",position={0,0},force=force}
  progression.arrive{valid=true,character=character,force=force,physical_surface=surface}
  check(not force.technologies["quinityn-arrival"].researched,"physical presence without discovery cannot unlock survey")
  force.technologies["planet-discovery-quinityn"].researched=true
  check(not force.technologies["quinityn-arrival"].researched,"discovery alone does not unlock Yuoki")
  -- Headless cannot create LuaPlayer instances. Exercise the landing handler with
  -- a narrow player facade backed by real force/surface/character objects.
  progression.arrive{valid=true,character=character,force=force,
    physical_surface=game.surfaces.nauvis,surface=surface}
  check(not force.technologies["quinityn-arrival"].researched,"remote view does not count as physical landing")
  progression.arrive{valid=true,character=character,force=force,physical_surface=surface}
  -- Mine a naturally generated stockpile into a real inventory, then verify its
  -- consumer is available after the actual arrival handler (no fabricated unlock).
  local wreck=surface.find_entities_filtered{name="quinityn-wreck",limit=1}[1]
  local mined=game.create_inventory(1)
  check(wreck.mine{inventory=mined},"natural stockpile can be mined")
  check(mined.get_item_count("quinityn-salvage")==20,"stockpile yields the sorting ingredient")
  check(force.recipes["quinityn-hand-sort"].enabled,"arrival unlocks salvage sorting")
  check(not force.recipes["quinityn-hand-sort"].hidden,"salvage sorting is visible")
  mined.destroy()
  storage.test_surface=surface.index
  for _, name in ipairs({"y-res1","y-res2"}) do
    local amount=0
    for _, ore in pairs(surface.find_entities_filtered{name=name,area={{-100,-100},{100,100}}}) do amount=amount+ore.amount end
    check(amount>=100000 and amount<=150000,"rich starter deposit: "..name.."="..amount)
    local ores=surface.find_entities_filtered{name=name,area={{-100,-100},{100,100}}}
    check(#ores>=180,"larger organic starter patch: "..name)
    local x,y=0,0
    for _,ore in pairs(ores) do x=x+ore.position.x; y=y+ore.position.y end
    log("STARTER CENTROID "..name.." "..x/#ores.." "..y/#ores)
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
    separator.get_fuel_inventory().insert{name="y-res2",count=10}
    separator.insert_fluid{name="y-liquid-uc2",amount=100}
    storage.separator=separator
    local circuit_source=surface.create_entity{name="constant-combinator",position={4,12},force=force}
    check(circuit_source and circuit_source.valid,"separator circuit source placement")
    for _, wire in ipairs({{"red",defines.wire_connector_id.circuit_red},
        {"green",defines.wire_connector_id.circuit_green}}) do
      local connector=separator.get_wire_connector(wire[2],true)
      local source=circuit_source.get_wire_connector(wire[2],true)
      check(connector.connect_to(source,true),"separator accepts nearby "..wire[1].." circuit wire")
      check(connector.disconnect_from(source),"separator disconnects "..wire[1].." circuit wire")
      check(connector.connect_to(source,true),"separator reconnects nearby "..wire[1].." circuit wire")
    end
    -- Search actual generated coastline; no fixture pond or fixed shoreline coordinates.
    local sea=surface.find_tiles_filtered{area={{-250,-250},{250,250}},name="quinityn-unicomp-sea"}
    for _, tile in ipairs(sea) do
      if storage.pump then break end
      for _, offset in ipairs({{0,1,defines.direction.north},{-1,0,defines.direction.east},
        {0,-1,defines.direction.south},{1,0,defines.direction.west}}) do
        local spec={name="offshore-pump",position={tile.position.x+offset[1]+0.5,tile.position.y+offset[2]+0.5},
          direction=offset[3],force=force,build_check_type=defines.build_check_type.manual}
        if not storage.pump and surface.can_place_entity(spec) then storage.pump=surface.create_entity(spec) end
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
    check(force.recipes["y-crush-unicomp-raw"].enabled and not force.recipes["y-crush-blue_whead"].enabled,
      "Materials enables plain crushing but not tool-assisted crushing")
    check(not force.recipes["y_crusher2"].enabled,"Materials does not unlock the second crusher")
    check(not force.recipes["y-heat-form-press"].enabled and not force.recipes["quinityn-research-data"].enabled,
      "Crushing does not unlock pressing or science")
    force.technologies["quinityn-excavation"].researched=true
    check(force.recipes["y-digfdirt"].enabled and not force.recipes["y-digfdirt2"].enabled,
      "Excavation enables plain digging but not drill-head digging")
    force.technologies["quinityn-tooling"].researched=true
    check(force.recipes["y-crush-blue_whead"].enabled and force.recipes["y-digfdirt2"].enabled,
      "Tooling unlocks head-assisted production only at its separate tier")
    force.technologies["quinityn-advanced-machining"].researched=true
    check(force.recipes["y_crusher2"].enabled,"Advanced machining unlocks the second crusher")
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
    -- Engine collision and pathfinding must reject a unicomp crossing.
    local tiles={}
    for x=280,320 do for y=280,320 do tiles[#tiles+1]={name="quinityn-unicomp-sea",position={x,y}} end end
    surface.set_tiles(tiles)
    for _,name in ipairs({"small-biter","medium-biter","big-biter","behemoth-biter","small-spitter"}) do
      check(not surface.can_place_entity{name=name,position={300,300},build_check_type=defines.build_check_type.manual},name.." cannot occupy unicomp")
    end
    local island={}
    for x=295,305 do for y=295,305 do island[#island+1]={name="quinityn-basalt",position={x,y}} end end
    surface.set_tiles(island)
    surface.set_tiles{{name="quinityn-basalt",position={275,300}}}
    storage.biter_path=surface.request_path{bounding_box={{-0.2,-0.2},{0.2,0.2}},
      collision_mask=prototypes.entity["small-biter"].collision_mask,start={300.5,300.5},goal={275.5,300.5},
      force=game.forces.enemy,radius=0.5,pathfind_flags={allow_destroy_friendly_entities=false}}
    storage.biter_path_land=surface.request_path{bounding_box={{-0.2,-0.2},{0.2,0.2}},
      collision_mask=prototypes.entity["small-biter"].collision_mask,start={300.5,300.5},goal={303.5,300.5},
      force=game.forces.enemy,radius=0.5,pathfind_flags={allow_destroy_friendly_entities=false}}
    -- All three real factories operate both requested recipes. Vanilla assembler cannot select them.
    force.technologies["quinityn-industrial-science"].researched=true
    storage.factories={}
    for i,name in ipairs({"ye_fassembly1","ye_fassembly2","ye_fassembly_sp"}) do
      local machine=surface.create_entity{name=name,position={-25+i*8,60},force=force}
      check(machine.set_recipe("quinityn-technic-sign"),name.." selects dedicated signs recipe")
      for _,ingredient in pairs(prototypes.recipe["quinityn-technic-sign"].ingredients) do machine.insert{name=ingredient.name,count=ingredient.amount} end
      storage.factories[#storage.factories+1]=machine
    end
    local assembler=surface.create_entity{name="assembling-machine-3",position={30,60},force=force}
    assembler.set_recipe("quinityn-research-data")
    check(assembler.get_recipe()==nil,"vanilla assembler rejects planet science")
    -- Programmatic research setters do not necessarily emit finished events; checked separately below.
  elseif event.tick==480 then
    check(storage.separator.get_fluid_count("water")>0,"primitive Cimota produces water burning raw F7 without grid power")
    check(storage.pump_pipe.get_fluid_count("y-liquid-uc2")>0,"offshore pump actually extracts Yuoki liquid unicomp")
  elseif event.tick==1200 then
    for _,machine in ipairs(storage.factories) do
      check(machine.get_output_inventory().get_item_count("y_rwtechsign")==1,machine.name.." produces exactly one sign")
      machine.get_output_inventory().clear()
      check(machine.set_recipe("quinityn-research-data"),machine.name.." selects planet science")
      for _,ingredient in pairs(prototypes.recipe["quinityn-research-data"].ingredients) do machine.insert{name=ingredient.name,count=ingredient.amount} end
    end
  elseif event.tick==2400 then
    for _,machine in ipairs(storage.factories) do
      check(machine.get_output_inventory().get_item_count("quinityn-research-data")==5,machine.name.." produces science")
    end
    check(storage.biter_path_land_passed,"biter path succeeds on dry land control")
    check(storage.biter_path_blocked,"biter path cannot cross unicomp moat")
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
  for _,machine in ipairs(storage.factories or {}) do machine.energy=10000000 end
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

script.on_event(defines.events.on_script_path_request_finished,function(e)
  if e.id==storage.biter_path then
    check(not e.try_again_later,"biter path request completed")
    storage.biter_path_blocked=e.path==nil
  elseif e.id==storage.biter_path_land then
    storage.biter_path_land_passed=not e.try_again_later and e.path~=nil
  end
end)
