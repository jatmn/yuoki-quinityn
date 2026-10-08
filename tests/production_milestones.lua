-- Feed real machines to prove native craft triggers and staged recipe visibility.
-- Ingredients/power are injected; reachability and budget prove their local supply.
local steps={
  {"materials","assembling-machine-1","quinityn-burner-separator"},
  {"pressing","y-crusher","y-crush-unicomp-raw"},
  {"compacting","y-heat-form-press","y-smelt-crush-res1"},
  {"alloying","y-crusher","y-crush-fuel-raw"},
  {"structures","y-heat-form-press","y-unicomp-raw"},
  {"electronics","stone-furnace","y-orange-stuff"},
  {"fuel-processing","y-heat-form-press","y-raw-fuelnium"},
  {"basic-factory","assembling-machine-1","y-chip-1"},
  {"factory","assembling-machine-1","ye_fassembly1"}
}
local function check(ok,message)
  assert(ok,"MILESTONE TEST FAILED: "..message)
  log("QUINITYN MILESTONE PASS: "..message)
end
script.on_init(function()
  local force=game.forces.player
  for name,t in pairs(force.technologies) do
    if not name:match("^quinityn%-") then t.researched=true end
  end
  force.script_trigger_research("quinityn-arrival")
  storage.surface=game.planets.quinityn.create_surface().index
  game.surfaces[storage.surface].request_to_generate_chunks({0,0},2)
  game.surfaces[storage.surface].force_generate_chunk_requests()
  storage.step=1
end)
script.on_event(defines.events.on_tick,function()
  if storage.finished then return end
  local force=game.forces.player
  if storage.miner then
    storage.miner.update_selected_entity(storage.rock_position)
    storage.miner.mining_state={mining=true,position=storage.rock_position}
    if force.technologies["quinityn-industrial-science"].researched then
      check(force.recipes["quinityn-research-data"].enabled,"late rock discovery reveals science after factory construction")
      check(not force.technologies["quinityn-power"].researched,"later research still requires science")
      storage.miner.destroy();storage.finished=true
      log("QUINITYN PRODUCTION MILESTONE TESTS PASSED")
    else assert(game.tick-storage.started<1000,"Native rock discovery timed out: ash="..storage.miner.get_item_count("y-pol-waste").." mining="..tostring(storage.miner.mining_state.mining)) end
    return
  end
  local step=steps[storage.step]
  if not storage.machine then
    for i=storage.step,#steps do
      if steps[i][1]~="factory" then
        check(not force.technologies["quinityn-"..steps[i][1]].researched,steps[i][1].." remains locked before its production milestone")
      end
    end
    check(not force.recipes["quinityn-research-data"].enabled,"science recipe is still locked")
    check(force.recipes[step[3]].enabled,"milestone recipe is already available: "..step[3])
    local machine=game.surfaces[storage.surface].create_entity{name=step[2],position={0,0},force=force}
    if machine.type=="assembling-machine" then check(machine.set_recipe(step[3]),"machine accepts milestone recipe") end
    storage.machine=machine
    storage.started=game.tick
  end
  local machine=storage.machine
  machine.energy=100000000
  if machine.burner then machine.get_fuel_inventory().insert{name="coal",count=10} end
  for _,p in pairs(prototypes.recipe[step[3]].ingredients) do
    if p.type=="fluid" then machine.insert_fluid{name=p.name,amount=p.amount}
    else machine.insert{name=p.name,count=p.amount} end
  end
  if (step[1]=="factory" and machine.products_finished>0) or
      (step[1]~="factory" and force.technologies["quinityn-"..step[1]].researched) then
    check(machine.products_finished>0,"actual production completed "..step[1])
    machine.destroy();storage.machine=nil
    storage.step=storage.step+1
    if storage.step>#steps then
      check(not force.recipes["quinityn-research-data"].enabled,"factory manufacture alone cannot reveal science")
      local surface=game.surfaces[storage.surface]
      local rock=surface.find_entities_filtered{name="quinityn-big-rock",limit=1}[1]
      assert(rock,"No native discovery rock")
      storage.miner=surface.create_entity{name="character",position={rock.position.x+2,rock.position.y},force=force}
      storage.rock_position=rock.position
      storage.miner.update_selected_entity(rock.position)
      storage.miner.mining_state={mining=true,position=rock.position}
      storage.started=game.tick
    end
  else
    assert(game.tick-storage.started<10000,"Milestone timed out: "..step[1])
  end
end)
