#!/usr/bin/env python3
"""Run official engine loading, prototype/dependency checks and native runtime fixtures."""
import argparse,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--factorio',type=Path,required=True);p.add_argument('--dependencies',type=Path,required=True);p.add_argument('--output',type=Path,default=ROOT/'build/test');a=p.parse_args()
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
def run(name,args,marker=None):
 result=subprocess.run(args,capture_output=True,text=True,timeout=180)
 text=result.stdout+result.stderr;(a.output/(name+'.log')).write_text(text)
 if result.returncode or 'Error Util.cpp' in text or (marker and marker not in text):
  print(text[-6000:]);raise SystemExit(name+' failed; see '+str(a.output/(name+'.log')))
 print('PASS',name)
# Each run starts from defaults; the option-off fixture persists mod-settings.dat.
(mods/'mod-settings.dat').unlink(missing_ok=True)
run('load',base+['--dump-data'],'Factorio initialised')
dump=a.output/'runtime/script-output/data-raw-dump.json'
for name in ['prototypes','reachability','bootstrap_budget']:
 run(name,[sys.executable,str(ROOT/'tests'/f'{name}.py'),str(dump)],'PASS')
run('localization',[sys.executable,str(ROOT/'tests/localization.py'),str(dump),
  str(a.dependencies/'Yuoki'),str(a.dependencies/'yi_engines'),
  *[str(p) for p in engine_data.iterdir() if p.is_dir()]],'PASS')
for seed in [1,42,8675309]:
 save=a.output/f'seed-{seed}.zip'
 run(f'generate-{seed}',base+['--create',str(save),'--map-gen-seed',str(seed)],'rich starter deposit: y-res2=')
run('worldgen',[sys.executable,str(ROOT/'tests/worldgen.py'),str(a.output)],'PASS')
run('runtime',base+['--benchmark',str(a.output/'seed-42.zip'),'--benchmark-ticks','15001','--benchmark-runs','1'],'QUINITYN RUNTIME TESTS PASSED')
# Native paired surfaces verify the independent planet controls through map generation.
try:
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/map_controls")\n')
 run('map-controls',base+['--create',str(a.output/'map-controls.zip'),'--map-gen-seed','42'],
     'QUINITYN MAP CONTROL TESTS PASSED')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/production_milestones")\n')
 run('production-milestones-create',base+['--create',str(a.output/'production-milestones.zip')],'Factorio initialised')
 run('production-milestones',base+['--benchmark',str(a.output/'production-milestones.zip'),
     '--benchmark-ticks','30000','--benchmark-runs','1'],'QUINITYN PRODUCTION MILESTONE TESTS PASSED')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/flyash")\n')
 run('flyash-create',base+['--create',str(a.output/'flyash.zip')],'Factorio initialised')
 run('flyash',base+['--benchmark',str(a.output/'flyash.zip'),
     '--benchmark-ticks','15000','--benchmark-runs','1'],'QUINITYN FLYASH TESTS PASSED')
 (harness/'control.lua').write_text('require("__yuoki-quinityn__/tests/landing_routes")\n')
 run('landing-routes-create',base+['--create',str(a.output/'landing-routes.zip')],'Factorio initialised')
 run('landing-routes',base+['--benchmark',str(a.output/'landing-routes.zip'),
     '--benchmark-ticks','22000','--benchmark-runs','1'],'QUINITYN LANDING ROUTE TESTS PASSED')
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
print('All checks passed. Logs:',a.output)
