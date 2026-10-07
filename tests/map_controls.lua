-- Paired real-engine surfaces differ in one map control, never in their seed.
local copy=require("util").table.deepcopy
local function check(ok,message)
  assert(ok,"MAP CONTROL TEST FAILED: "..message)
  log("QUINITYN CONTROL PASS: "..message)
end
script.on_init(function()
  local template=game.planets.quinityn.prototype.map_gen_settings
  local area={{-384,-384},{384,384}}
  local function sample(name,edit)
    local settings=copy(template)
    settings.seed=42
    edit(settings)
    local surface=game.create_surface("controls-"..name,settings)
    surface.request_to_generate_chunks({0,0},12)
    surface.force_generate_chunk_requests()
    local sea=surface.count_tiles_filtered{area=area,name="quinityn-unicomp-sea"}
    local cliffs=surface.count_entities_filtered{area=area,type="cliff"}
    local bases=surface.count_entities_filtered{area=area,type="unit-spawner"}
    check(surface.count_entities_filtered{area={{-80,-80},{80,80}},type="cliff"}==0,name.." protects starter core from cliffs")
    local signature={}
    for _,e in pairs(surface.find_entities_filtered{area=area,type="unit-spawner"}) do
      signature[#signature+1]=e.name..":"..e.position.x..":"..e.position.y
    end
    table.sort(signature)
    log("CONTROL SAMPLE "..name.." sea="..sea.." cliffs="..cliffs.." bases="..bases)
    game.delete_surface(surface)
    return {sea=sea,cliffs=cliffs,bases=bases,signature=table.concat(signature,";")}
  end
  local normal=sample("default",function(_) end)
  local dry=sample("less-liquid",function(s) s.autoplace_controls.quinityn_water.size=0.5 end)
  local wet=sample("more-liquid",function(s) s.autoplace_controls.quinityn_water.size=2 end)
  check(dry.sea<normal.sea and normal.sea<wet.sea,"unicomp coverage changes land/liquid ratio monotonically")
  local scaled=sample("smaller-districts",function(s) s.autoplace_controls.quinityn_water.frequency=4 end)
  check(scaled.sea~=normal.sea,"unicomp scale changes generated terrain")
  local no_cliffs=sample("no-cliffs",function(s) s.autoplace_controls.quinityn_cliff.frequency=0 end)
  check(normal.cliffs>0 and no_cliffs.cliffs==0,"cliffs generate by default and their slider disables them")
  local no_nauvis=sample("nauvis-enemies-off",function(s) s.autoplace_controls["enemy-base"]={frequency=0,size=0} end)
  check(normal.bases>0 and no_nauvis.signature==normal.signature,"Nauvis enemy settings do not change Quinityn nests")
  local more_bases=sample("more-enemies",function(s) s.autoplace_controls.quinityn_enemy_base={frequency=4,size=2} end)
  check(more_bases.bases>normal.bases,"Quinityn enemy slider increases native nests")
  local no_bases=sample("no-enemies",function(s) s.autoplace_controls.quinityn_enemy_base.frequency=0 end)
  check(no_bases.bases==0,"zero Quinityn enemy frequency suppresses nests")
  for name,planet in pairs(game.planets) do
    if name~="quinityn" then
      local s=planet.create_surface()
      s.request_to_generate_chunks({0,0},4)
      s.force_generate_chunk_requests()
      check(s.count_entities_filtered{name={"y-res1","y-res2"}}==0,name.." has no Yuoki ores")
    end
  end
  log("QUINITYN MAP CONTROL TESTS PASSED")
end)
