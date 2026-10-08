-- Native character mining and real machines; inject power/fluids to isolate
-- operation. The closure/budget and generation checks prove local inputs.
local function check(ok,message)
  assert(ok,"FLYASH TEST FAILED: "..message)
  log("QUINITYN FLYASH PASS: "..message)
end
script.on_init(function()
  local force=game.forces.player
  force.technologies["planet-discovery-quinityn"].researched=true
  force.script_trigger_research("quinityn-arrival")
  storage.tasks={}
  for _,planet in ipairs({"nauvis","vulcanus","gleba","fulgora","aquilo","quinityn"}) do
    local surface=game.planets[planet].create_surface()
    surface.request_to_generate_chunks({0,0},3)
    surface.force_generate_chunk_requests()
    for _,name in ipairs({"big-rock","huge-rock","big-sand-rock"}) do
      storage.tasks[#storage.tasks+1]={surface=surface.index,name=name}
    end
  end
  storage.index=1
end)
script.on_event(defines.events.on_tick,function()
  if storage.finished then return end
  local force=game.forces.player
  if storage.character and storage.rock.valid then
    storage.character.update_selected_entity(storage.rock.position)
    storage.character.mining_state={mining=true,position=storage.rock.position}
  end
  local tasks=storage.tasks
  if storage.index<=#tasks then
    local task=tasks[storage.index]
    local surface=game.surfaces[task.surface]
    if not storage.character then
      for _,e in pairs(surface.find_entities_filtered{area={{-5,-5},{5,5}}}) do e.destroy() end
      local tiles={}
      for x=-5,5 do for y=-5,5 do tiles[#tiles+1]={name="stone-path",position={x,y}} end end
      surface.set_tiles(tiles)
      storage.rock=surface.create_entity{name=task.name,position={2,0}}
      storage.character=surface.create_entity{name="character",position={0,0},force=force}
      storage.character.mining_state={mining=true,position={2,0}}
      storage.started=game.tick
    elseif not storage.rock.valid then
      check(storage.character.get_item_count("stone")>0,"native character mined "..task.name.." on "..surface.name)
      check(storage.character.get_item_count("y-pol-waste")==0,"ordinary rock has no flyash on "..surface.name)
      check(not force.technologies["quinityn-industrial-science"].researched,"ordinary rock does not reveal science on "..surface.name)
      storage.character.destroy();storage.character=nil
      storage.index=storage.index+1
    else assert(game.tick-storage.started<1000,"Ordinary rock mining timed out") end
    return
  end
  local surface=game.planets.quinityn.surface
  if not storage.discovered then
    if not storage.character then
      storage.rock=surface.find_entities_filtered{name="quinityn-big-rock",limit=1}[1]
      local p=storage.rock.position
      storage.character=surface.create_entity{name="character",position={p.x+2,p.y},force=force}
      storage.character.mining_state={mining=true,position=p}
      storage.started=game.tick
    elseif not storage.rock.valid then
      check(storage.character.get_item_count("y-pol-waste")==2,"native mining recovers first flyash")
      check(force.recipes["quinityn-research-data"].enabled,"first Quinityn rock reveals science")
      check(not force.technologies["quinityn-basic-factory"].researched,"early discovery works before factory research")
      check(not force.recipes["y-electric-air-heater"].enabled,"Fatmice has a separate unlock")
      storage.character.destroy();storage.character=nil;storage.discovered=true
      force.technologies["quinityn-power"].researched=true
      force.technologies["quinityn-air-scrubbing"].researched=true
      check(force.recipes["y-electric-air-heater"].enabled and force.recipes["y-rmvpol"].enabled,"Fatmice research unlocks unfiltered scrubbing")
      check(not force.recipes["j-airfilter"].enabled and not force.recipes["j-airfilter_cleaning"].enabled,"filters remain locked")
      storage.machine=surface.create_entity{name="y-electric-air-heater",position={0,0},force=force}
      check(storage.machine.set_recipe("y-rmvpol"),"Fatmice accepts the initial unfiltered recipe")
      storage.machine.insert_fluid{name="water",amount=60}
      storage.machine.insert_fluid{name="y-mechanical-force",amount=0.2}
      game.map_settings.pollution.enabled=true
      surface.clear_pollution();surface.pollute({0,0},10000)
      storage.pollution=surface.get_total_pollution()
      storage.started=game.tick
    else assert(game.tick-storage.started<1000,"Discovery mining timed out") end
    return
  end
  local machine=storage.machine
  machine.energy=100000000
  if storage.ash_remaining and storage.ash_remaining>0 then
    storage.ash_remaining=storage.ash_remaining-machine.insert{name="y-pol-waste",count=storage.ash_remaining}
  end
  if not storage.filtered and machine.products_finished>0 then
    check(machine.get_output_inventory().get_item_count("y-pol-waste")==1,"unfiltered Fatmice produces flyash")
    check(surface.get_total_pollution()<storage.pollution,"operating Fatmice reduces pollution")
    force.technologies["quinityn-engines"].researched=true
    force.technologies["quinityn-washing"].researched=true
    force.technologies["quinityn-air-filters"].researched=true
    check(force.recipes["j-airfilter"].enabled and force.recipes["j-airfilter_cleaning"].enabled,"later upgrade unlocks filters and washing")
    machine.destroy()
    storage.machine=surface.create_entity{name="y-electric-air-heater",position={0,0},force=force}
    machine=storage.machine
    check(machine.set_recipe("j-airfilter_dirty"),"Fatmice accepts upgraded filtration")
    machine.insert{name="j-airfilter",count=1}
    machine.insert_fluid{name="water",amount=60}
    machine.insert_fluid{name="y-mechanical-force",amount=0.2}
    storage.filtered=true;storage.started=game.tick
  elseif storage.filtered and not storage.washing and machine.products_finished>0 then
    check(machine.get_output_inventory().get_item_count("j-airfilter_dirty")==1,"filtered capture yields a dirty filter")
    machine.get_output_inventory().remove{name="j-airfilter_dirty",count=1};machine.destroy()
    storage.machine=surface.create_entity{name="y-dirtwasher",position={0,0},force=force}
    machine=storage.machine
    check(machine.set_recipe("j-airfilter_cleaning"),"washer accepts the dirty filter")
    machine.insert{name="j-airfilter_dirty",count=1};machine.insert{name="y-coal-dust",count=8}
    machine.insert_fluid{name="water",amount=110}
    storage.washing=true;storage.started=game.tick
  elseif storage.washing and not storage.condensing and machine.products_finished>0 then
    check(machine.get_output_inventory().get_item_count("y-pol-waste")==6,"washing recovers six flyash")
    check(machine.get_output_inventory().get_item_count("j-airfilter")==1,"washing returns reusable filter")
    check(machine.get_fluid_count("y-con_water")==0,"washing makes no wastewater")
    machine.destroy()
    storage.machine=surface.create_entity{name="assembling-machine-2",position={0,0},force=force}
    machine=storage.machine
    check(force.recipes["y-waste-condense"].enabled,"Engines exposes waste condensation")
    check(machine.set_recipe("y-waste-condense"),"assembler accepts flyash condensation")
    storage.ash_remaining=750-machine.insert{name="y-pol-waste",count=750}
    storage.condensing=true;storage.started=game.tick
  elseif storage.condensing and not storage.rocket and machine.products_finished>=5 then
    check(machine.get_output_inventory().get_item_count("y-mixed-fuel")==10,"750 flyash condenses into ten mixed fuel")
    local fuel=machine.get_output_inventory().remove{name="y-mixed-fuel",count=10}
    machine.destroy()
    storage.machine=surface.create_entity{name="chemical-plant",position={0,0},force=force}
    machine=storage.machine
    check(force.recipes["y_mixedfuel2rocketfuel"].enabled,"Engines exposes alternate rocket fuel")
    check(machine.set_recipe("y_mixedfuel2rocketfuel"),"chemical plant accepts mixed fuel")
    machine.insert{name="y-mixed-fuel",count=fuel}
    storage.rocket=true;storage.started=game.tick
  elseif storage.rocket and machine.products_finished>0 then
    check(machine.get_output_inventory().get_item_count("rocket-fuel")==1,"flyash chain produces real rocket fuel")
    machine.destroy();storage.finished=true
    log("QUINITYN FLYASH TESTS PASSED")
  end
  assert(game.tick-storage.started<3000,"Flyash machine stage timed out")
end)
