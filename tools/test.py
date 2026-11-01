#!/usr/bin/env python3
"""Run official engine loading, prototype/dependency checks and native runtime fixtures."""
import argparse,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--factorio',type=Path,required=True);p.add_argument('--dependencies',type=Path,required=True);p.add_argument('--output',type=Path,default=ROOT/'build/test');p.add_argument('--transport-drones',type=Path);a=p.parse_args()
a.factorio=a.factorio.resolve();a.dependencies=a.dependencies.resolve();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=True)
mods=a.output/'mods';mods.mkdir(exist_ok=True)
for name,path in [('Yuoki',a.dependencies/'Yuoki'),('yi_engines',a.dependencies/'yi_engines'),('yuoki-quinityn',ROOT)]:
 link=mods/name
 if link.is_symlink():
  if link.resolve()!=path:raise SystemExit('Unexpected existing link: '+str(link))
 elif link.exists():raise SystemExit('Unexpected existing directory: '+str(link))
 else:link.symlink_to(path,target_is_directory=True)
harness=mods/'quinityn-tests';harness.mkdir(exist_ok=True)
(harness/'info.json').write_text(json.dumps({'name':'quinityn-tests','version':'0.1.0','factorio_version':'2.1','title':'Quinityn tests','author':'jatmn','dependencies':['yuoki-quinityn']}))
(harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/runtime")\n')
(mods/'mod-list.json').write_text(json.dumps({'mods':[{'name':n,'enabled':True} for n in ['base','space-age','elevated-rails','quality','Yuoki','yi_engines','yuoki-quinityn','quinityn-tests']]}))
engine_data=a.factorio.parents[2]/'data'
config=a.output/'config.ini';config.write_text('[path]\nread-data='+str(engine_data)+'\nwrite-data='+str(a.output/'runtime')+'\n')
base=[str(a.factorio),'--config',str(config),'--mod-directory',str(mods)]
def run(name,args,marker=None,timeout=180):
 result=subprocess.run(args,capture_output=True,text=True,timeout=timeout)
 text=result.stdout+result.stderr;(a.output/(name+'.log')).write_text(text)
 if result.returncode or 'Error Util.cpp' in text or (marker and marker not in text):
  print(text[-6000:]);raise SystemExit(name+' failed; see '+str(a.output/(name+'.log')))
 print('PASS',name)
# Each run starts from defaults; the option-off fixture persists mod-settings.dat.
(mods/'mod-settings.dat').unlink(missing_ok=True)
run('load',base+['--dump-data','--check-unused-prototype-data'],'Factorio initialised')
# Factorio silently ignores unknown or superseded prototype fields; reject them in prototypes named quinityn*.
unused=[line for line in (a.output/'load.log').read_text().splitlines() if 'was not used' in line
        and line.split('Value ROOT.',1)[-1].split('.')[1].startswith('quinityn')]
if unused:print('\n'.join(unused));raise SystemExit('unused Quinityn prototype data; see '+str(a.output/'load.log'))
print('PASS no unused data in quinityn* prototypes')
dump=a.output/'runtime/script-output/data-raw-dump.json'
# Exercise the callbacks actually attached to the loaded tips, not a parallel
# list of helper calls. Keep the exported data in the existing test-only mod.
tips=json.loads(dump.read_text())['tips-and-tricks-item']
biology_stages=['agriculture','packaging','husbandry','genetics','advanced-genetics',
                'industrial-biology','trade','trade-biology','reputation','mastery',
                'chemical-science','military-science','production-science','utility-science',
                'space-science','genetic-trade','advanced-genetic-trade','industrial-biology-trade']
callbacks=json.dumps({stage:tips['quinityn-'+stage]['simulation'] for stage in biology_stages})
delimiter='='
while ']'+delimiter+']' in callbacks:delimiter+='='
(harness/'biology_callbacks.lua').write_text(
 'return helpers.json_to_table(['+delimiter+'['+callbacks+']'+delimiter+'])\n')
tutorials={name.removeprefix('quinityn-'):tip['simulation'] for name,tip in tips.items()
           if name.startswith('quinityn-') and 'tutorial-demo' in tip.get('simulation',{}).get('init','')}
for name in ['trade','prototypes','stomp_a_trons','reachability','bootstrap_budget']:
 run(name,[sys.executable,str(ROOT/'tests'/f'{name}.py'),str(dump)],'PASS')
run('localization',[sys.executable,str(ROOT/'tests/localization.py'),str(dump),
  str(a.dependencies/'Yuoki'),str(a.dependencies/'yi_engines'),
  *[str(p) for p in engine_data.iterdir() if p.is_dir()]],'PASS')
for seed in [1,42,8675309]:
 save=a.output/f'seed-{seed}.zip'
 run(f'generate-{seed}',base+['--create',str(save),'--map-gen-seed',str(seed)],'rich starter deposit: y-res2=')
run('worldgen',[sys.executable,str(ROOT/'tests/worldgen.py'),str(a.output)],'PASS')
run('runtime',base+['--benchmark',str(a.output/'seed-42.zip'),'--benchmark-ticks','15001','--benchmark-runs','1'],'QUINITYN RUNTIME TESTS PASSED')
try:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/cimota")\n')
 run('cimota-create',base+['--create',str(a.output/'cimota.zip')],'QUINITYN CIMOTA SETUP PASSED')
 run('cimota-reload',base+['--benchmark',str(a.output/'cimota.zip'),'--benchmark-ticks','1','--benchmark-runs','1'],'QUINITYN CIMOTA RELOAD PASSED')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/cimota_migration")\n')
 legacy=harness/'data-final-fixes.lua'
 legacy.write_text('for name,t in pairs(data.raw.technology) do\n'
  ' if name:match("^quinityn%-cimota%-") or name=="quinityn-maintenance" then\n'
  '  for i=#(t.effects or {}),1,-1 do local e=t.effects[i];\n'
  '   if e.type=="unlock-recipe" and (name~="quinityn-maintenance" or e.recipe=="y-repair-krakon") then\n'
  '    table.insert(data.raw.technology["quinityn-cimota"].effects,table.remove(t.effects,i))\n'
  '   end\n  end\n end\nend\n')
 run('cimota-migration-create',base+['--create',str(a.output/'cimota-migration.zip')],'QUINITYN CIMOTA MIGRATION SETUP')
 legacy.unlink()
 run('cimota-migration-reload',base+['--benchmark',str(a.output/'cimota-migration.zip'),'--benchmark-ticks','601','--benchmark-runs','1'],'QUINITYN CIMOTA MIGRATION PASSED')
finally:
 (harness/'data-final-fixes.lua').unlink(missing_ok=True)
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/runtime")\n')
# Planner, blueprint, robot and hand replacement of the primitive Cimota.
try:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/cimota_upgrade")\n')
 run('cimota-upgrade-create',base+['--create',str(a.output/'cimota-upgrade.zip')],'QUINITYN CIMOTA UPGRADE SETUP PASSED')
 run('cimota-upgrade',base+['--benchmark',str(a.output/'cimota-upgrade.zip'),'--benchmark-ticks','3000','--benchmark-runs','1'],'QUINITYN CIMOTA UPGRADE PASSED')
finally:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/runtime")\n')
try:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/surplus_migration")\n')
 setting_override=harness/'settings-updates.lua'
 run('surplus-migration-create',base+['--create',str(a.output/'surplus-migration.zip')],'QUINITYN SURPLUS MIGRATION SETUP')
 # Inserter cleanup exists only beside an adjustable-inserter mod. This startup
 # setting is always defined, so the reload is a real configuration change.
 setting_override.write_text('local setting=assert(data.raw["bool-setting"]["yuoki-uc-heavyoil"]); setting.forced_value=false; setting.hidden=true\n')
 run('surplus-migration-reload',base+['--benchmark',str(a.output/'surplus-migration.zip'),'--benchmark-ticks','60','--benchmark-runs','1'],'QUINITYN SURPLUS MIGRATION PASSED')
finally:
 setting_override.unlink(missing_ok=True)
 (mods/'mod-settings.dat').unlink(missing_ok=True)
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/runtime")\n')
try:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/salvage_sort_migration")\n')
 run('salvage-sort-migration-create',base+['--create',str(a.output/'salvage-sort-migration.zip')],'QUINITYN SALVAGE SORT MIGRATION SETUP')
 run('salvage-sort-migration-reload',base+['--benchmark',str(a.output/'salvage-sort-migration.zip'),'--benchmark-ticks','300','--benchmark-runs','1'],'QUINITYN SALVAGE SORT MIGRATION PASSED')
finally:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/runtime")\n')
try:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/research_migration")\n')
 legacy=harness/'data-final-fixes.lua'
 legacy.write_text('for name, gate in pairs({["quinityn-quantum"]="quinityn-high-flow-storage", ["quinityn-advanced-storage"]="quinityn-accumulator-capacity"}) do\n'
  ' local t=data.raw.technology[name]; for i=#t.prerequisites,1,-1 do if t.prerequisites[i]==gate then table.remove(t.prerequisites,i) end end\nend\n')
 run('research-migration-create',base+['--create',str(a.output/'research-migration.zip')],'QUINITYN RESEARCH MIGRATION SETUP')
 legacy.unlink()
 run('research-migration-reload',base+['--benchmark',str(a.output/'research-migration.zip'),'--benchmark-ticks','1','--benchmark-runs','1'],'QUINITYN RESEARCH MIGRATION PASSED')
finally:
 legacy.unlink(missing_ok=True)
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/runtime")\n')
try:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/packaging_migration")\n')
 # Reconstruct bulk Packaging separately from historical prerequisite changes.
 legacy=harness/'data-final-fixes.lua'
 legacy.write_text('for name,t in pairs(data.raw.technology) do\n'
  ' if name:match("^quinityn%-") and not name:match("^quinityn%-packaging$") and not name:match("^quinityn%-bridge%-packaging%-") then\n'
  '  for i=#(t.effects or {}),1,-1 do local e=t.effects[i]; local r=e.recipe or "";\n'
  '   if (r:match("^ye_package_") or r:match("^ye_buechse_")) and not r:match("_export") then\n'
  '    local owner=r:match("%-recycling$") and "quinityn-bridge-packaging-recycling" or "quinityn-packaging";\n'
  '    table.insert(data.raw.technology[owner].effects,table.remove(t.effects,i))\n'
  '   end\n  end\n end\nend\n')
 run('packaging-migration-create',base+['--create',str(a.output/'packaging-migration.zip')],'QUINITYN PACKAGING MIGRATION SETUP')
 legacy.unlink()
 run('packaging-migration-reload',base+['--benchmark',str(a.output/'packaging-migration.zip'),'--benchmark-ticks','1','--benchmark-runs','1'],'QUINITYN PACKAGING MIGRATION PASSED')
finally:
 legacy.unlink(missing_ok=True)
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/runtime")\n')
try:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/trade_migration")\n')
 legacy=harness/'data-final-fixes.lua'
 legacy.write_text('local moved={reputation=true,["chemical-science"]=true,["military-science"]=true,'
  '["production-science"]=true,["utility-science"]=true,["space-science"]=true,'
  '["genetic-trade"]=true,["advanced-genetic-trade"]=true,["industrial-biology-trade"]=true}\n'
  'for name,t in pairs(data.raw.technology) do\n'
  ' local stage=name:gsub("^quinityn%-bridge%-",""):gsub("^quinityn%-",""):gsub("%-recycling$","")\n'
  ' for i=#(t.effects or {}),1,-1 do local e=t.effects[i]; local r=e.recipe or ""; local plain=r:gsub("%-recycling$","");\n'
  '  if moved[stage] or (stage=="trade-biology" and (plain:find("export") or plain:match("^ye_trade"))) or plain=="ypfw_trader_sign" then\n'
  '   local owner=plain=="y-fame-gen" and "mastery" or "trade";\n'
  '   local target=r:match("%-recycling$") and "quinityn-bridge-"..owner.."-recycling" or "quinityn-"..owner;\n'
  '   table.insert(data.raw.technology[target].effects,table.remove(t.effects,i))\n'
  '  end\n end\nend\n')
 run('trade-migration-create',base+['--create',str(a.output/'trade-migration.zip')],'QUINITYN TRADE MIGRATION SETUP')
 legacy.unlink()
 run('trade-migration-reload',base+['--benchmark',str(a.output/'trade-migration.zip'),'--benchmark-ticks','1','--benchmark-runs','1'],'QUINITYN TRADE MIGRATION PASSED')
finally:
 legacy.unlink(missing_ok=True)
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/runtime")\n')
# Native paired surfaces verify the independent planet controls through map generation.
try:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/enemies")\n')
 run('enemies-create',base+['--create',str(a.output/'enemies.zip')],'Factorio initialised')
 run('enemies',base+['--benchmark',str(a.output/'enemies.zip'),
     '--benchmark-ticks','4801','--benchmark-runs','1'],'QUINITYN ENEMY TESTS PASSED')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/stomp_a_trons")\n')
 run('stomp-a-trons-create',base+['--create',str(a.output/'stomp-a-trons.zip')],'Factorio initialised')
 run('stomp-a-trons',base+['--benchmark',str(a.output/'stomp-a-trons.zip'),
     '--benchmark-ticks','14401','--benchmark-runs','1'],'QUINITYN STOMP-A-TRON TESTS PASSED')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/map_controls")\n')
 run('map-controls',base+['--create',str(a.output/'map-controls.zip'),'--map-gen-seed','42'],
     'QUINITYN MAP CONTROL TESTS PASSED')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/production_milestones")\n')
 run('production-milestones-create',base+['--create',str(a.output/'production-milestones.zip')],'Factorio initialised')
 run('production-milestones',base+['--benchmark',str(a.output/'production-milestones.zip'),
     '--benchmark-ticks','30000','--benchmark-runs','1'],'QUINITYN PRODUCTION MILESTONE TESTS PASSED')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/research_progression")\n')
 run('research-progression-create',base+['--create',str(a.output/'research-progression.zip')],'Factorio initialised')
 run('research-progression',base+['--benchmark',str(a.output/'research-progression.zip'),
     '--benchmark-ticks','130000','--benchmark-runs','1'],'QUINITYN RESEARCH PROGRESSION TESTS PASSED',timeout=600)
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/trade_startup")\n')
 run('trade-startup-create',base+['--create',str(a.output/'trade-startup.zip')],'Factorio initialised')
 run('trade-startup',base+['--benchmark',str(a.output/'trade-startup.zip'),
     '--benchmark-ticks','60000','--benchmark-runs','1'],'QUINITYN TRADE STARTUP PASSED',timeout=600)
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/biology_demonstrations")\n')
 run('biology-demonstrations-create',base+['--create',str(a.output/'biology-demonstrations.zip')],'Factorio initialised')
 run('biology-demonstrations',base+['--benchmark',str(a.output/'biology-demonstrations.zip'),
     '--benchmark-ticks','220000','--benchmark-runs','1'],'QUINITYN BIOLOGY DEMONSTRATIONS PASSED',timeout=600)
 # Each callback runs twice through its actual recipes and operating scenes.
 # Batches leave room under Factorio's force limit and exercise save reloads.
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/tutorial_demonstrations")\n')
 stages=sorted(tutorials)
 for offset in range(0,len(stages),16):
  callbacks=json.dumps({stage:tutorials[stage] for stage in stages[offset:offset+16]})
  delimiter='='
  while ']'+delimiter+']' in callbacks:delimiter+='='
  (harness/'tutorial_callbacks.lua').write_text(
   'return helpers.json_to_table(['+delimiter+'['+callbacks+']'+delimiter+'])\n')
  name='tutorial-demonstrations-'+str(offset//16)
  run(name+'-create',base+['--create',str(a.output/(name+'.zip'))],'Factorio initialised')
  run(name,base+['--benchmark',str(a.output/(name+'.zip')),
      '--benchmark-ticks','200000','--benchmark-runs','1'],'QUINITYN TUTORIAL DEMONSTRATIONS PASSED',timeout=600)
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/flyash")\n')
 run('flyash-create',base+['--create',str(a.output/'flyash.zip')],'Factorio initialised')
 run('flyash',base+['--benchmark',str(a.output/'flyash.zip'),
     '--benchmark-ticks','15000','--benchmark-runs','1'],'QUINITYN FLYASH TESTS PASSED')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/landing_routes")\n')
 run('landing-routes-create',base+['--create',str(a.output/'landing-routes.zip')],'Factorio initialised')
 run('landing-routes',base+['--benchmark',str(a.output/'landing-routes.zip'),
     '--benchmark-ticks','22000','--benchmark-runs','1'],'QUINITYN LANDING ROUTE TESTS PASSED',timeout=600)
finally:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/runtime")\n')
# Preserve the upstream heavy-oil conversion opt-out through the new tree.
setting_override=harness/'settings-updates.lua'
try:
 setting_override.write_text('local setting=data.raw["bool-setting"]["yuoki-uc-heavyoil"]; setting.forced_value=false; setting.hidden=true\n')
 run('load-heavy-oil-disabled',base+['--dump-data'],'Factorio initialised')
 disabled=json.loads(dump.read_text())
 assert not disabled['recipe']['y-heavyoil2uc']['enabled']
 assert not any(e.get('recipe')=='y-heavyoil2uc' for t in disabled['technology'].values() for e in t.get('effects',[]))
 print('PASS upstream heavy-oil opt-out')
finally:
 setting_override.unlink(missing_ok=True)
# Activate Yuoki's real cleanup setting with a detection-only Bob's mod stub.
# This exercises upstream cleanup/load order, not Bob's adjustment implementation.
adjustable=mods/'bobinserters';adjustable.mkdir(exist_ok=True)
(adjustable/'info.json').write_text(json.dumps({'name':'bobinserters','version':'3.0.0','factorio_version':'2.1','title':'Detection fixture','author':'jatmn','dependencies':['base >= 2.1.0']}))
mod_list=json.loads((mods/'mod-list.json').read_text())
mod_list['mods'].append({'name':'bobinserters','enabled':True})
(mods/'mod-list.json').write_text(json.dumps(mod_list))
try:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/inserter_opt_out")\n')
 (mods/'mod-settings.dat').unlink(missing_ok=True)
 run('inserters-visible',base+['--create',str(a.output/'inserters-visible.zip')],
     'QUINITYN INSERTER OPT-OUT TESTS PASSED')
 setting_override.write_text('local setting=assert(data.raw["bool-setting"]["yuoki-inserter-cleanup"]); setting.forced_value=true; setting.hidden=true\n')
 run('inserters-hidden',base+['--create',str(a.output/'inserters-hidden.zip')],
     'QUINITYN INSERTER OPT-OUT TESTS PASSED')
 (harness/'tutorial_callbacks.lua').write_text('return helpers.json_to_table([==['+
   json.dumps({'advanced-logistics':tutorials['advanced-logistics']})+']==])\n')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/tutorial_demonstrations")\n')
 run('tutorial-inserters-hidden-create',base+['--create',str(a.output/'tutorial-inserters-hidden.zip')],'Factorio initialised')
 run('tutorial-inserters-hidden',base+['--benchmark',str(a.output/'tutorial-inserters-hidden.zip'),
     '--benchmark-ticks','40000','--benchmark-runs','1'],'QUINITYN TUTORIAL DEMONSTRATIONS PASSED')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/inserter_opt_out")\n')
 run('inserters-disable-reload',base+['--benchmark',str(a.output/'inserters-visible.zip'),
     '--benchmark-ticks','1','--benchmark-runs','1'],'QUINITYN INSERTER OPT-OUT RELOAD PASSED')
 setting_override.write_text('local setting=assert(data.raw["bool-setting"]["yuoki-inserter-cleanup"]); setting.forced_value=false; setting.hidden=true\n')
 run('inserters-enable-reload',base+['--benchmark',str(a.output/'inserters-hidden.zip'),
     '--benchmark-ticks','1','--benchmark-runs','1'],'QUINITYN INSERTER OPT-OUT RELOAD PASSED')
 setting_override.unlink()
 mod_list['mods'][-1]['enabled']=False
 (mods/'mod-list.json').write_text(json.dumps(mod_list))
 run('inserters-remove-adjustable-reload',base+['--benchmark',str(a.output/'inserters-hidden.zip'),
     '--benchmark-ticks','1','--benchmark-runs','1'],'QUINITYN INSERTER OPT-OUT RELOAD PASSED')
finally:
 setting_override.unlink(missing_ok=True)
 mod_list['mods']=[m for m in mod_list['mods'] if m['name']!='bobinserters']
 (mods/'mod-list.json').write_text(json.dumps(mod_list))
 (adjustable/'info.json').unlink()
 adjustable.rmdir()
 (mods/'mod-settings.dat').unlink(missing_ok=True)
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/runtime")\n')
if a.transport_drones:
 run('transport-drones',[sys.executable,str(ROOT/'tools/test_transport_drones.py'),
     '--factorio',str(a.factorio),'--dependencies',str(a.dependencies),
     '--transport-drones',str(a.transport_drones.resolve()),'--output',str(a.output/'transport-drones')],
     'PASS complete helper equality',timeout=1800)
print('All checks passed. Logs:',a.output)
