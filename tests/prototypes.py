"""Validate gameplay contracts against the actual engine prototype dump."""
import colorsys,json,re,sys
from pathlib import Path
D=json.loads(Path(sys.argv[1]).read_text());root=Path(__file__).resolve().parents[1]
R=D['recipe'];T=D['technology'];I=D['item'];tiles=D['tile']
assert tiles['quinityn-unicomp-sea']['fluid']=='y-liquid-uc2'
assert tiles['quinityn-unicomp-sea']['destroys_dropped_items']
assert tiles['quinityn-unicomp-sea']['default_cover_tile']=='quinityn-foundation'
normal=set(I['foundation']['place_as_tile']['tile_condition']);alt=set(I['quinityn-foundation']['place_as_tile']['tile_condition'])
assert normal<=alt and alt-normal=={'quinityn-unicomp-sea'}
for name,item in I.items():
 if name!='quinityn-foundation':assert 'quinityn-unicomp-sea' not in item.get('place_as_tile',{}).get('tile_condition',[]),name
assert tiles['quinityn-foundation']['minable']['result']=='quinityn-foundation'
assert tiles['quinityn-foundation']['frozen_variant']=='quinityn-frozen-foundation'
assert tiles['quinityn-frozen-foundation']['thawed_variant']=='quinityn-foundation'
assert R['quinityn-foundation']['surface_conditions']==[{'property':'quinityn-industry','min':1,'max':1}]
for n in ['iron','copper','stone','carbon','timber']:
 assert R['quinityn-'+n]['categories']==['hand-crafting']
assert R['quinityn-hand-sort']['categories']==['hand-crafting','y-crushing']
assert R['quinityn-research-data']['surface_conditions']==[{'property':'quinityn-industry','min':1,'max':1}]
# Every directly named upstream recipe must be gated, including hidden recycling.
owned={n for n in R if re.match(r'^(y[-_]|yi[-_]|ye[-_]|yie[-_]|ypfw[-_])',n)}
unlocks={}
for n,t in T.items():
 for e in t.get('effects',[]):
  if e['type']=='unlock-recipe':unlocks.setdefault(e['recipe'],[]).append(n)
for n in owned:
 assert R[n].get('enabled',True) is False, 'Enabled before visit: '+n
 if n=='y-heavyoil2uc' and R[n].get('hidden'):
  assert not unlocks.get(n), 'Disabled upstream option acquired an unlock'
 else:assert unlocks.get(n) and all(t.startswith('quinityn-') for t in unlocks[n]),'Ungated unlock: '+n
# Every generated Yuoki technology depends transitively on arrival; discovery stays separate.
def ancestry(n,seen=None):
 seen=set() if seen is None else seen
 assert n not in seen,'technology cycle: '+n
 result={n}
 for p in T[n].get('prerequisites',[]):result|=ancestry(p,seen|{n})
 return result
for n in T:
 if n.startswith('quinityn-'):assert 'quinityn-arrival' in ancestry(n),n
plant_inf_recipes={
 'y-pipe-ec','y-pipe-h','y-pipe-hc','y-pipe-to-ground-ec','y-pipe-to-ground-hc','y-pipe-v',
 'y-powerlamp','y-substation-m','y-tank-1000','y-tinylamp','y_lampe_44basement_a','y_lampe_44basement_b',
 'y_lampe_66basement','y_lampe_corner','y_lampe_neotix','y_lampe_yuoki','y_signal_pole','yi_pipe_green',
 'yi_pipe_underground_green'}
def unlock_set(tech):
 return {e['recipe'] for e in T[tech].get('effects',[]) if e['type']=='unlock-recipe'}
# Farming remains useful before trade; machines, starters and their consumers
# must share a reachable research path rather than merely exposing a recipe.
assert unlocks['ye_trade_node']==['quinityn-trade'], 'Trade Node must follow its Laika-Gate ingredient'
biology_owners={
 'husbandry':{'ye_dna_animal0','ye_grow_animal_a','ye_grow_fish1','ye_meatfarm','ye_pool',
              'ye_pool_slurry','ye_cooking_meat','yie_bloodfrommeat','ye-growcorn_ws','ye_cornb_ws'},
 'genetics':{'ye_dnasplicer','ye_dna_animal1','ye_dna_animal2','ye_grow_animal2',
             'ye_dna_plant0','ye_dna_plant1','ye_dna_plant3','ye_grow_plant1'},
 'advanced-genetics':{'ye_dna_animal3','ye_grow_animal3','ye_grow_animal3fast',
                      'ye_dna_plant4','ye_grow_plant2','ye_futtermittel_c'},
 'trade-biology':{'ye_fish2','ye_fish3','ye_fish4','ye_dna_fish2','ye_futtermittel_a',
                  'ye_futtermittel_b','ye_futtermittel_d','ye_smoker','ye_smoked_meat','ye_smoked_fish'},
}
for stage,recipes in biology_owners.items():
 tech='quinityn-'+stage
 assert unlock_set(tech)==recipes, (tech,unlock_set(tech)^recipes)
 for recipe in recipes:
  assert unlocks[recipe]==[tech],recipe
  if recipe+'-recycling' in R:
   bridge='quinityn-bridge-'+stage+'-recycling'
   assert unlocks[recipe+'-recycling']==[bridge],recipe
   assert set(T[bridge]['prerequisites'])=={tech,'recycling'}
for early in ['agriculture','husbandry','packaging']:
 assert {'quinityn-trade','quinityn-genetics','quinityn-quantum'}.isdisjoint(ancestry('quinityn-'+early))
assert 'quinityn-quantum' in ancestry('quinityn-genetics')
assert 'quinityn-trade' not in ancestry('quinityn-industrial-biology')
assert 'quinityn-genetics' not in ancestry('quinityn-trade')
assert set(T['quinityn-trade-biology']['prerequisites'])=={
 'quinityn-trade','quinityn-husbandry','quinityn-slag-paving'}
for recipe,ingredient in [('ye_fish2','ye_dna_fish2'),('ye_fish3','ye_futtermittel_a'),
 ('ye_fish4','ye_futtermittel_b'),('ye_smoked_fish','ye_fish4'),('ye_grow_animal3fast','ye_futtermittel_c')]:
 assert ingredient in {p['name'] for p in R[recipe]['ingredients']}
 assert unlocks[ingredient][0] in ancestry(unlocks[recipe][0]), (recipe,ingredient)
assert R['ye_dna_animal0']['categories']==['crafting']
assert {p['name'] for p in R['ye_dna_animal0']['ingredients']}=={'logistic-science-pack','chemical-science-pack'}
print('PASS: early farming, quantum splicing and complete trade-species/smoking ownership')
# Quantum research must distinguish precursor manufacture from infusion and utilities.
quantum_materials={'y-atomic-quantum-composer','y-quantrinum','y-crystal-cnd','y_data_crystal',
 'y_repair_quantrinum','yi_radar','yi-monument1'}
infusion={'y-alien-infuser','y-infused-mud','y-infused-uca2','y_quantrinum_infusion'}
assert unlock_set('quinityn-quantum')==quantum_materials
assert unlock_set('quinityn-infusion')==infusion
assert unlock_set('quinityn-quantum-utilities')=={'yi_beacon','ye_center'}
assert 'quinityn-quantum' in ancestry('quinityn-infusion')
assert 'quinityn-unicomp-compression' in ancestry('quinityn-quantum')
assert 'quinityn-infusion' in ancestry('quinityn-quantum-utilities')
assert unlocks['y-quantrinum-charge']==['quinityn-quantum-power']
for tech,recipes in [('quinityn-quantum',quantum_materials),('quinityn-infusion',infusion),
 ('quinityn-quantum-utilities',{'yi_beacon','ye_center'})]:
 for recipe in recipes:
  assert unlocks[recipe]==[tech],(recipe,unlocks[recipe])
  if recipe+'-recycling' in R:
   bridge='quinityn-bridge-'+tech.removeprefix('quinityn-')+'-recycling'
   assert unlocks[recipe+'-recycling']==[bridge],recipe
   assert set(T[bridge]['prerequisites'])=={tech,'recycling'}
# All direct consumers retain material ancestry after moving the infusion recipes.
for recipe,r in R.items():
 if recipe.endswith('-recycling'):continue
 if any(p['name'] in {'y-infused-uca2','y-infused-mud','y_quantrinum_infused'} for p in r.get('ingredients',[])):
  for tech in unlocks.get(recipe,[]):
   assert 'quinityn-infusion' in ancestry(tech),(recipe,tech)
# Charging and local rockets must not wait on the new high-power infusion step.
for tech in ['quinityn-thermal-smelting','quinityn-orbital']:
 assert 'quinityn-infusion' not in ancestry(tech)
 assert 'quinityn-quantum-utilities' not in ancestry(tech)
assert set(T['quinityn-plant-infrastructure']['prerequisites'])=={'quinityn-power','quinityn-advanced-components'}
assert unlock_set('quinityn-plant-infrastructure')==plant_inf_recipes
assert set(T['quinityn-fluid-storage-50k']['prerequisites'])=={'quinityn-plant-infrastructure'}
assert unlock_set('quinityn-fluid-storage-50k')=={'y-tank-4500'}
assert set(T['quinityn-fluid-storage-80k']['prerequisites'])=={'quinityn-fluid-storage-50k'}
assert unlock_set('quinityn-fluid-storage-80k')=={'y-tank-8000'}
for tank,volume in [('y-tank-1000',15000),('y-tank-4500',50000),('y-tank-8000',80000)]:
 assert D['storage-tank'][tank]['fluid_box']['volume']==volume,tank
for recipe in plant_inf_recipes:
 assert unlocks[recipe]==['quinityn-plant-infrastructure'],(recipe,unlocks.get(recipe))
assert unlocks['y-tank-4500']==['quinityn-fluid-storage-50k'],unlocks.get('y-tank-4500')
assert unlocks['y-tank-8000']==['quinityn-fluid-storage-80k'],unlocks.get('y-tank-8000')
for recipe in ['yi_radar','yi-monument1','y-crystal-cnd','y-atomic-quantum-composer']:
 assert unlocks[recipe]==['quinityn-quantum'],(recipe,unlocks.get(recipe))
wonder_machines=[n for n,m in D['assembling-machine'].items() if 'yuoki-wonder' in m.get('crafting_categories',[])]
assert wonder_machines==['y-atomic-quantum-composer']
assert 'yuoki-wonder' in R['yi_radar']['categories']
monument_cnd=[p for p in R['yi-monument1']['ingredients'] if p['name']=='y-crystal-cnd']
assert len(monument_cnd)==1 and monument_cnd[0]['amount']==6
assert any(p['name']=='y-substation-m' for p in R['y_compensator_25']['ingredients'])
assert 'quinityn-quantum' not in ancestry('quinityn-plant-infrastructure')
assert 'quinityn-quantum' not in ancestry('quinityn-fluid-storage-50k')
assert 'quinityn-quantum' not in ancestry('quinityn-fluid-storage-80k')
assert 'quinityn-plant-infrastructure' in ancestry('quinityn-fluid-storage-50k')
assert 'quinityn-plant-infrastructure' in ancestry('quinityn-fluid-storage-80k')
for n in ['quinityn-mining-productivity','quinityn-plasma-damage']:
 assert T[n]['max_level']=='infinite'
 assert ['quinityn-research-data',2] in T[n]['unit']['ingredients']
 assert T[n]['unit']['count_formula']=='1000*1.5^(L-1)'
tips=[n for n in D['tips-and-tricks-item'] if n.startswith('quinityn-')]
assert len(tips)==128
# The seven biology process tips must ship native simulations at their actual
# research unlocks; biology_demonstrations executes these declared callbacks
# exported by tools/test.py from this same engine dump.
for stage in ['agriculture','husbandry','genetics','advanced-genetics',
              'industrial-biology','trade','trade-biology']:
 tip=D['tips-and-tricks-item']['quinityn-'+stage]
 assert tip['trigger']=={'type':'research','technology':'quinityn-'+stage},stage
 scene=tip['simulation']
 assert scene['planet']=='quinityn' and scene.get('init') and scene.get('update'),stage
# Localized rich-text links must point at actual prototypes.
text=(root/'locale/en/quinityn.cfg').read_text()
for kind,name in re.findall(r'\[(item|entity|fluid|recipe|technology|planet)=([^\]]+)\]',text):
 exists=name in D.get(kind,{})
 if kind=='item':exists=exists or name in D.get('tool',{})
 if kind=='entity':exists=any(name in group for group in D.values() if isinstance(group,dict))
 assert exists,f'Broken guide link: {kind}={name}'
for name in ['quinityn-basalt','quinityn-slag','quinityn-ruined-district','quinityn-unicomp-sea']:
 assert tiles[name]['absorptions_per_second']['pollution']==.000001
print(f'PASS: {len(owned)} named upstream recipe gates; technology DAG; {len(tips)} guide chapters; foundations; science sinks; pollution')
# A compact reviewable manifest is generated from the engine, not a parallel source of truth.
manifest={n:[e['recipe'] for e in t.get('effects',[]) if e['type']=='unlock-recipe'] for n,t in T.items() if n.startswith('quinityn-')}
(root/'docs/recipe-unlocks.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')

# Exclusive factory manufacture and early factory access prevent a science deadlock.
factories={'ye_fassembly1','ye_fassembly2','ye_fassembly_sp'}
for name, machine in D['assembling-machine'].items():
 assert ('quinityn-science' in machine.get('crafting_categories',[])) == (name in factories), name
assert 'quinityn-science' not in D['character']['character']['crafting_categories']
assert R['quinityn-research-data']['categories']==['quinityn-science']
assert R['quinityn-technic-sign']['categories']==['quinityn-science']
assert R['quinityn-technic-sign']['results']==[{'type':'item','name':'y_rwtechsign','amount':1}]
assert R['quinityn-technic-sign']['energy_required']>=30
assert unlocks['ye_fassembly1']==['quinityn-basic-factory']
assert 'unit' not in T['quinityn-materials']
assert unlocks['quinityn-research-data']==['quinityn-industrial-science']
separator=D['assembling-machine']['quinityn-burner-separator']
source=D['assembling-machine']['y-atomic-constructor']
def channels(tint):
 if tint is None: return [1, 1, 1, 1]
 if isinstance(tint, dict):
  return [tint.get('r', 0), tint.get('g', 0), tint.get('b', 0), tint.get('a', 1)]
 tint=list(tint)
 return tint if len(tint) == 4 else tint + [1]
def is_sprite(value):
 return isinstance(value,dict) and any(k in value for k in ['filename','filenames','stripes'])
def walk_sprites(value):
 if isinstance(value,dict):
  if is_sprite(value):
   yield value
   if value.get('draw_as_shadow') or value.get('draw_as_light') or value.get('draw_as_glow'): return
  for key,child in value.items():
   if key!='tint' and key!='stripes': yield from walk_sprites(child)
 elif isinstance(value,list):
  for child in value: yield from walk_sprites(child)
def without_tint(value):
 if isinstance(value,dict): return {k:without_tint(v) for k,v in value.items() if k!='tint'}
 if isinstance(value,list): return [without_tint(v) for v in value]
 return value
purple=[0.8,0.45,1]
def check_sprite(before, after):
 if before.get('draw_as_shadow') or before.get('draw_as_light') or before.get('draw_as_glow'):
  assert after==before
 else:
  assert without_tint(after)==without_tint(before)
  got=channels(after.get('tint'))
  for i,c in enumerate(purple): assert abs(got[i]-c)<1e-6
  assert abs(got[3]-1)<1e-6
  base=channels(before.get('tint'))
  assert not all(abs(base[i]-purple[i])<1e-6 for i in range(3))
def tinted(sprite, **nested):
 out=dict(sprite)
 out['tint']=[0.8,0.45,1]
 out.update(nested)
 return out
# A filename-only sprite is still a sprite. Ignoring it, or leaving it untinted, fails.
assert list(walk_sprites({'layers':[{'filename':'visible-only.png'}]}))==[{'filename':'visible-only.png'}]
try:
 check_sprite({'filename':'visible-only.png'}, {'filename':'visible-only.png'})
except AssertionError:
 pass
else:
 raise AssertionError('filename-only sprite left untinted was accepted')
stripe={'stripes':[{'filename':'frame.png','width_in_frames':4,'height_in_frames':1}],'hr_version':{'filename':'hr-only.png'}}
found=list(walk_sprites({'layers':[stripe, {'filename':'shadow.png','draw_as_shadow':True,'hr_version':{'filename':'shadow-hr.png'}}]}))
assert len(found)==3 and 'stripes' in found[0] and found[1]['filename']=='hr-only.png' and found[2]['filename']=='shadow.png'
assert all(s.get('filename') not in ('frame.png','shadow-hr.png') for s in found)
raw={'layers':[
 {'filename':'visible-only.png'},
 {'filenames':['a.png','b.png']},
 {'stripes':[{'filename':'frame.png','width_in_frames':4,'height_in_frames':1}]},
 {'filename':'shadow.png','draw_as_shadow':True,'hr_version':{'filename':'shadow-hr.png'}},
 {'filename':'light.png','draw_as_light':True},
 {'filename':'glow.png','draw_as_glow':True,'hr_version':{'filename':'glow-hr.png'}},
 {'filename':'visible.png','width':32,'hr_version':{'filename':'visible-hr.png'}},
]}
done={'layers':[
 tinted({'filename':'visible-only.png'}),
 tinted({'filenames':['a.png','b.png']}),
 tinted({'stripes':[{'filename':'frame.png','width_in_frames':4,'height_in_frames':1}]}),
 {'filename':'shadow.png','draw_as_shadow':True,'hr_version':{'filename':'shadow-hr.png'}},
 {'filename':'light.png','draw_as_light':True},
 {'filename':'glow.png','draw_as_glow':True,'hr_version':{'filename':'glow-hr.png'}},
 tinted({'filename':'visible.png','width':32}, hr_version=tinted({'filename':'visible-hr.png'})),
]}
left,right=list(walk_sprites(raw)),list(walk_sprites(done))
assert len(left)==len(right)==8
for before,after in zip(left,right): check_sprite(before, after)
prim=list(walk_sprites(separator['graphics_set']));orig=list(walk_sprites(source['graphics_set']))
assert len(prim)==len(orig) and len(prim)>=1
for before,after in zip(orig,prim): check_sprite(before, after)
assert separator['graphics_set']!=source['graphics_set']
assert separator['fluid_boxes']==source['fluid_boxes']
assert separator['circuit_connector']==D['assembling-machine']['chemical-plant']['circuit_connector']
item_tint=channels(I['quinityn-burner-separator']['icons'][0]['tint'])
for i,c in enumerate(purple): assert abs(item_tint[i]-c)<1e-6
assert R['quinityn-burner-separator']['icons']==I['quinityn-burner-separator']['icons']
assert separator['crafting_speed']==0.5 and separator['energy_usage']=='180kW'
assert separator['energy_source']['emissions_per_minute']['pollution']==6
assert separator['module_slots']==0 and not separator['quality_affects_module_slots']
assert I['y-res2']['fuel_value']=='1MJ' and I['wood']['fuel_value']=='2MJ'
assert 'chemical' in I['y-res2']['fuel_categories']
assert len(D['planet']['quinityn']['map_gen_settings']['autoplace_settings']['decorative']['settings'])>=5
assert 'quinityn-unicomp-sea' not in I['landfill']['place_as_tile']['tile_condition']
# PNG alpha, dimensions and prototype paths are checked independently of headless graphics loading.
import struct
for name,group in [('quinityn-salvage',I),('quinityn-research-data',D['tool'])]:
 p=group[name];path=root/p['icon'].removeprefix('__yuoki-quinityn__/')
 image=path.read_bytes();assert image[:8]==b'\x89PNG\r\n\x1a\n'
 width,height,depth,color=struct.unpack('>IIBB',image[16:26])
 assert width==height==p['icon_size']==256 and depth==8 and color==6
print('PASS: factory-only science/signs, early factory, primitive Cimota/F7 fuel, decorative coverage and RGBA icons')
tool=D['tool']
science=tool['quinityn-research-data']
assert R['quinityn-research-data']['subgroup']==science['subgroup']=='science-pack'
assert R['quinityn-research-data']['order']==science['order']=='z[quinityn]'
assert science['order']>I['promethium-science-pack']['order']
assert R['quinityn-foundation']['subgroup']==I['quinityn-foundation']['subgroup']=='terrain'
assert R['quinityn-foundation']['order']==I['quinityn-foundation']['order']=='c[landfill]-h[quinityn]'
assert R['quinityn-foundation']['order']>I['foundation']['order']=='c[landfill]-g[foundation]'
assert R['quinityn-low-density-structure']['subgroup']==I['low-density-structure']['subgroup']=='intermediate-product'
assert R['quinityn-low-density-structure']['order']==I['low-density-structure']['order']=='d[rocket-parts]-a[low-density-structure]'
assert R['quinityn-processing-unit']['subgroup']==I['processing-unit']['subgroup']=='intermediate-product'
assert R['quinityn-processing-unit']['order']==I['processing-unit']['order']=='b[circuits]-c[processing-unit]'
for name in ['quinityn-hand-sort','quinityn-iron','quinityn-copper','quinityn-carbon','quinityn-stone','quinityn-timber',
             'quinityn-burner-separator','quinityn-water','quinityn-technic-sign']:
 assert R[name]['subgroup']=='quinityn-fieldwork' and R[name]['order']==name
assert I['quinityn-salvage']['subgroup']==I['quinityn-burner-separator']['subgroup']=='quinityn-fieldwork'
assert R['quinityn-research-data']['categories']==['quinityn-science']
assert R['quinityn-foundation']['categories']==['yuoki-formpress']
assert R['quinityn-low-density-structure']['categories']==['crafting']
assert R['quinityn-processing-unit']['categories']==['crafting-with-fluid']
assert R['quinityn-technic-sign']['categories']==['quinityn-science']
for name in ['quinityn-research-data','quinityn-foundation','quinityn-low-density-structure','quinityn-processing-unit']:
 assert R[name]['surface_conditions']==[{'property':'quinityn-industry','min':1,'max':1}] and R[name].get('enabled',True) is False
assert unlocks['quinityn-research-data']==['quinityn-industrial-science']
assert unlocks['quinityn-foundation']==['quinityn-foundation']
assert unlocks['quinityn-low-density-structure']==unlocks['quinityn-processing-unit']==['quinityn-orbital']
assert unlocks['quinityn-technic-sign']==['quinityn-industrial-science']
assert R['quinityn-research-data']['ingredients']==[{'type':'item','name':'y-unicomp-raw','amount':1},{'type':'item','name':'y-refined-yres2','amount':1},
 {'type':'item','name':'y_rwtechsign','amount':1},{'type':'item','name':'y-pol-waste','amount':5}]
assert R['quinityn-research-data']['results']==[{'type':'item','name':'quinityn-research-data','amount':5}]
assert R['quinityn-research-data']['energy_required']==5
assert R['quinityn-foundation']['ingredients']==[{'type':'item','name':'y_structure_element','amount':2},{'type':'item','name':'y_structure_vessel','amount':1},
 {'type':'item','name':'y-orange-stuff','amount':5},{'type':'item','name':'stone-brick','amount':10}]
assert R['quinityn-foundation']['results']==[{'type':'item','name':'quinityn-foundation','amount':4}]
assert R['quinityn-foundation']['energy_required']==8
assert R['quinityn-low-density-structure']['ingredients']==[{'type':'item','name':'y_structure_element','amount':2},{'type':'item','name':'y-unicomp-raw','amount':5},
 {'type':'item','name':'plastic-bar','amount':5}]
assert R['quinityn-low-density-structure']['results']==[{'type':'item','name':'low-density-structure','amount':1}]
assert R['quinityn-low-density-structure']['energy_required']==15
assert R['quinityn-processing-unit']['ingredients']==[{'type':'item','name':'y-chip-2','amount':2},{'type':'item','name':'y-conductive-wire-1','amount':4},
 {'type':'fluid','name':'sulfuric-acid','amount':5}]
assert R['quinityn-processing-unit']['results']==[{'type':'item','name':'processing-unit','amount':1}]
assert R['quinityn-processing-unit']['energy_required']==10
print('PASS: recipe family grouping for science, foundation and orbital products')

# UI planet badges are derived from control membership, not nonzero settings.
for name,planet in D['planet'].items():
 mg=planet.get('map_gen_settings',{})
 for ore in ['y-res1','y-res2']:
  assert (ore in mg.get('autoplace_controls',{})) == (name=='quinityn'), (name,ore)
mg=D['planet']['quinityn']['map_gen_settings']
assert 'enemy-base' not in mg['autoplace_controls']
for control,category in [('quinityn_water','terrain'),('quinityn_cliff','cliff'),('quinityn_enemy_base','enemy'),('quinityn_trees','terrain')]:
 assert control in mg['autoplace_controls'] and D['autoplace-control'][control]['category']==category
sort=R['quinityn-hand-sort']
assert sort['icons']==[{'icon':I['quinityn-salvage']['icon'],'icon_size':I['quinityn-salvage']['icon_size']}]
assert not sort.get('hidden',False) and not sort.get('hide_from_player_crafting',False)
assert sort['ingredients']==[{'type':'item','name':'quinityn-salvage','amount':1}]
assert {p['name']:p['amount'] for p in sort['results']}=={'y-res1':2,'y-res2':2,'stone':2,'wood':1}
assert unlocks['quinityn-hand-sort']==['quinityn-arrival']
assert 'hand-crafting' in D['character']['character']['crafting_categories']
assert sort.get('allow_productivity') is not True and sort.get('allow_quality') is not True
assert sort['surface_conditions']==[{'property':'quinityn-industry','min':1,'max':1}]
assert sort['energy_required']==3
ycrush=sorted(n for n,m in D['assembling-machine'].items() if 'y-crushing' in m.get('crafting_categories',[]))
assert ycrush==['y-crusher','y_crusher2'], ycrush
assert 'crushing' not in sort['categories']
assert 'y-crushing' not in D['assembling-machine']['crusher']['crafting_categories']
assert D['assembling-machine']['crusher']['crafting_categories']==['crushing']
print('PASS: planet-specific map control membership and visible salvage sorting identity/unlock')

# Research is anchored beyond space travel; native milestones bootstrap local science.
assert T['quinityn-arrival']['prerequisites']==['planet-discovery-quinityn']
assert 'space-science-pack' in [i[0] for i in T['planet-discovery-quinityn']['unit']['ingredients']]
assert T['planet-discovery-quinityn']['effects']==[
 {'type':'unlock-space-location','space_location':'quinityn','use_icon_overlay_constant':True},
 {'type':'unlock-travel-to-space-platforms','modifier':True},
]
for name,t in T.items():
 if not name.startswith('quinityn-'):continue
 assert 'planet-discovery-quinityn' in ancestry(name),name
 if t.get('unit'):
  assert 'quinityn-research-data' in [i[0] for i in t['unit']['ingredients']],name
 assert 'sign_tech_icon' not in str(t.get('icons',t.get('icon',''))),name
def tech_recipes(tech):
 return {e['recipe'] for e in T[tech].get('effects',[]) if e['type']=='unlock-recipe'}
power_stayers={'y-coal-dust','y-coal-brikett','y-wooden-brikett','y-heat-pipe','y-notfall-generator-s2','y_bg-1'}
assert tech_recipes('quinityn-power')==power_stayers
storage_stayers={'y-battery-single-use1','y-battery-single-use2','y-battery-single-use3','y-battery-rip1','y_blocked_capa','y-accumulator-m'}
assert tech_recipes('quinityn-energy-storage')==storage_stayers
assert tech_recipes('quinityn-advanced-generation')=={'y-seg'}
reactors_stayers={'y_moxmixer','y_mox1mixed','y_reactor_mox1','y_mox1fuel','y_reactor_mf1','y-obninsk-reactor','y-rare-wall-adv','yi_graphite'}
assert tech_recipes('quinityn-reactors')==reactors_stayers
assert 'y_alien_solar2' in tech_recipes('quinityn-quantum-power') and 'y_alien_solar' not in tech_recipes('quinityn-quantum-power')
new_tech_recipes={
 'quinityn-compressed-fuel':{'y-coal-stack'},
 'quinityn-mixed-fuel':{'y-coaldust-mixing','y-mixfuel-load'},
 'quinityn-residue-fuel':{'y_mud2solidfuel'},
 'quinityn-field-repair':{'y-repair-durotal'},
 'quinityn-solar-dish':{'y-stirling-solar-dish'},
 'quinityn-solar-collector':{'y_alien_solar'},
 'quinityn-accumulator-capacity':{'y-accumulator-b'},
 'quinityn-flywheel-storage':{'y-ups-flywheel-b'},
 'quinityn-high-flow-storage':{'y_compensator_25'},
 'quinityn-medium-generation':{'y-meg-s'},
 'quinityn-big-generation':{'y-beg'},
 'quinityn-huge-generation':{'y-heg'},
 'quinityn-high-capacity-boiler':{'y-boiler-iv'},
 'quinityn-high-pressure-steam-turbine':{'y-steam-turbine'},
 'quinityn-electric-water':{'y-water-gen-e'},
}
for tech,recipes in new_tech_recipes.items():
 assert tech_recipes(tech)==recipes,tech
sole_owner={
 'quinityn-power':power_stayers,
 'quinityn-energy-storage':storage_stayers,
 'quinityn-advanced-generation':{'y-seg'},
 'quinityn-reactors':{'yi_graphite'},
}
sole_owner.update(new_tech_recipes)
for tech,recipes in sole_owner.items():
 for recipe in sorted(recipes):
  assert unlocks[recipe]==[tech],(recipe,unlocks.get(recipe))
recycling_sole_owner={
 'quinityn-bridge-power-recycling':{'y-coal-brikett-recycling','y-coal-dust-recycling','y-heat-pipe-recycling','y-mixed-fuel-loaded-recycling','y-notfall-generator-s2-recycling','y-wooden-brikett-recycling','y_bg-1-recycling'},
 'quinityn-bridge-energy-storage-recycling':{'y-accumulator-m-recycling','y-battery-single-use1-recycling','y-battery-single-use2-recycling','y-battery-single-use3-recycling','y_blocked_capa-recycling'},
 'quinityn-bridge-advanced-generation-recycling':{'y-seg-recycling'},
 'quinityn-bridge-compressed-fuel-recycling':{'y-coal-stack-recycling'},
 'quinityn-bridge-field-repair-recycling':{'y-repair-durotal-recycling'},
 'quinityn-bridge-high-pressure-steam-turbine-recycling':{'y-steam-turbine-recycling'},
 'quinityn-bridge-solar-dish-recycling':{'y-stirling-solar-dish-recycling'},
 'quinityn-bridge-solar-collector-recycling':{'y_alien_solar-recycling'},
 'quinityn-bridge-accumulator-capacity-recycling':{'y-accumulator-b-recycling'},
 'quinityn-bridge-flywheel-storage-recycling':{'y-ups-flywheel-b-recycling'},
 'quinityn-bridge-high-flow-storage-recycling':{'y_compensator_25-recycling'},
 'quinityn-bridge-big-generation-recycling':{'y-beg-recycling'},
 'quinityn-bridge-high-capacity-boiler-recycling':{'y-boiler-iv-recycling'},
 'quinityn-bridge-huge-generation-recycling':{'y-heg-recycling'},
 'quinityn-bridge-medium-generation-recycling':{'y-meg-s-recycling'},
 'quinityn-bridge-electric-water-recycling':{'y-water-gen-e-recycling'},
 'quinityn-bridge-reactors-recycling':{'yi_graphite-recycling'},
}
for tech,recipes in recycling_sole_owner.items():
 for recipe in sorted(recipes):
  assert unlocks[recipe]==[tech],(recipe,unlocks.get(recipe))
assert unlocks['y-coaldust-mixing']==unlocks['y-mixfuel-load']
assert unlocks['y_mixedfuel2rocketfuel']==['quinityn-engines']
assert unlocks['y-repair-krakon']==['quinityn-cimota']
assert unlocks['y_repair_quantrinum']==['quinityn-quantum']
comp_tech=unlocks['y_compensator_25'][0]
assert 'quinityn-quantum' not in ancestry(comp_tech) and 'quinityn-quantum-power' not in ancestry(comp_tech)
composer_tech=unlocks['y-atomic-quantum-composer'][0]
assert comp_tech in ancestry(composer_tech)
assert unlocks['yi_graphite-recycling']==['quinityn-bridge-reactors-recycling']
assert unlocks['y-coal-dust-recycling']==['quinityn-bridge-power-recycling']
for first,upgrade in [('y-crush-unicomp-raw','y-crush-blue_whead'),('y-crush-fuel-raw','y-crush-green_whead'),
 ('y-digfdirt','y-digfdirt2'),('y-pure-iron','y_pure_iron_wtool'),('y-pure-copper','y_pure_copper_wtool'),
 ('y-water-gen','y-water-gen-e'),('y-crusher','y_crusher2'),('y-heat-form-press','y_formpress2'),('y-mining-drill','y-mining-drill-e2'),
 ('y-coal-brikett','y-coal-stack'),('y-notfall-generator-s2','y-steam-turbine'),('y-boiler-iv','y-steam-turbine'),
 ('y-stirling-solar-dish','y_alien_solar'),('y-seg','y-meg-s'),('y-meg-s','y-beg'),('y-beg','y-heg'),
 ('y-accumulator-m','y-accumulator-b'),('y-accumulator-m','y-accumulator-m-t2'),('y-accumulator-b','y-accumulator-b-t2'),
 ('y-accumulator-b-t2','y-accumulator-b-tx'),('ye_fassembly1','ye_fassembly2'),
 ('y_turret_gun1f12','y_turret_gun2f12'),('yi_armor_gray','yi_armor_red'),('yi_armor_red','yi_armor_gold'),
 ('yi_armor_gold','yi_walker_a'),('yi_walker_a','yi_walker_c'),
 ('y-pink-module-1','y-pink-module-2'),('y-pink-module-2','y-pink-module-3'),
 ('y-speed-module-1','y-speed-module-2'),('y-green-module-1','y-green-module-2'),
 ('ye_dna_animal2','ye_dna_animal3'),('ye_dna_animal3','ye_dna_animal4'),
 ('yi_construction-robot','j_construction2-robot'),('yi_logistic-robot','j_logistic2-robot')]:
 a,b=unlocks[first][0],unlocks[upgrade][0]
 assert a!=b and a in ancestry(b),(first,upgrade,a,b)
print('PASS: discovery ancestry, mandatory post-milestone science, representative icons and ordered production tiers')

# Factory upgrades and free reputation generation must be distinct research steps.
y2,p3,center=(unlocks[n][0] for n in ['ye_fassembly2','ye_fassembly_sp','yie_science_blue_gen'])
assert len({y2,p3,center})==3
assert {e['recipe'] for e in T[y2]['effects'] if e['type']=='unlock-recipe'}=={'ye_fassembly2'}
assert y2 in ancestry(p3) and p3 in ancestry(center)
assert 'quinityn-advanced-modules' in ancestry(p3) and 'quinityn-mastery' in ancestry(center)
assert T[p3]['unit']['count']>=1000 and T[center]['unit']['count']>=5000
assert T[center]['unit']['time']==40
assert {i[0] for i in T[center]['unit']['ingredients']}=={
 'automation-science-pack','logistic-science-pack','military-science-pack','chemical-science-pack',
 'production-science-pack','utility-science-pack','space-science-pack','quinityn-research-data'}
assert unlocks['ye_science_blue']==[center]
# Existing reputation byproducts remain available before the free generator.
for name in ['yi_radar','y-quantrinum']:
 assert all(center not in ancestry(t) for t in unlocks[name])
 assert any(p['name']=='ye_science_blue' for p in R[name]['results'])

robotics=unlocks['yi_logistic-robot'][0]
assert {e['recipe'] for e in T[robotics]['effects'] if e['type']=='unlock-recipe'}=={
 'yi_roboport','yi_logistic-robot','yi_construction-robot'}
network=unlocks['j_yi_roboport1'][0]
assert network!=robotics and robotics in ancestry(network)
advanced=unlocks['j_logistic2-robot'][0]
milestones=[n for n in ancestry(advanced) if T[n].get('research_trigger')==
 {'type':'craft-item','item':'yi_logistic-robot','count':500}]
assert len(milestones)==1 and robotics in ancestry(milestones[0])
assert not T[milestones[0]].get('unit') and not T[milestones[0]].get('effects')
assert T[advanced]['unit']['count']>240 and 'research_trigger' not in T[advanced]
for n in [robotics,network,advanced]:
 assert {'logistic-science-pack','chemical-science-pack'}<={i[0] for i in T[n]['unit']['ingredients']}
 assert 'chemical-science-pack' in ancestry(n)
print('PASS: separate Y2/P3/research center, endgame science/costs and robot manufacturing plus lab gates')

def tech_unlocks(tech):
 return {e['recipe'] for e in T[tech].get('effects',[]) if e['type']=='unlock-recipe'}
def assert_unlocks(tech,recipes):
 got=tech_unlocks(tech)
 want=set(recipes)
 assert got==want,(tech,got,want)
assert_unlocks('quinityn-defense',['y_wood_wall','y-mud-wall','y-bullet-case','y_turret_gun1f12','yi_cannon_shell'])
assert_unlocks('quinityn-advanced-defense',['y_turret_gun2f12','y-ammo-hohlspitz','y-ammo-acid-2','y-ammo-poison',
 'y-ammo-krakon','y-ammo-explosiv','y-ammo-biggun'])
assert_unlocks('quinityn-durotal-walls',['y-rare-wall-basic'])
assert_unlocks('quinityn-forcefield-walls',['y-wall-forcefield'])
assert_unlocks('quinityn-hardic-walls',['y_wall22_hardic'])
assert_unlocks('quinityn-ammunition-cases',['y_ammo_case'])
assert_unlocks('quinityn-laser-turret',['y_turret_laser22f12'])
assert_unlocks('quinityn-plasma-weapons',['y_turret_plasma','y_ammo_plasma'])
assert_unlocks('quinityn-chemical-weapons',['y_turret_flame','y_ammo_flame'])
assert_unlocks('quinityn-poison-mines',['yi_mine_impact'])
assert_unlocks('quinityn-plasma-mines',['yi_mine_plasma'])
assert_unlocks('quinityn-artillery-shells',['yi_artillery_shell'])
assert_unlocks('quinityn-zero-time-weapon',['y-weapon-ztt'])
defense_split_owners={
 'y_wood_wall':'quinityn-defense','y-mud-wall':'quinityn-defense','y-bullet-case':'quinityn-defense',
 'y_turret_gun1f12':'quinityn-defense','yi_cannon_shell':'quinityn-defense',
 'y_turret_gun2f12':'quinityn-advanced-defense','y-ammo-hohlspitz':'quinityn-advanced-defense',
 'y-ammo-acid-2':'quinityn-advanced-defense','y-ammo-poison':'quinityn-advanced-defense',
 'y-ammo-krakon':'quinityn-advanced-defense','y-ammo-explosiv':'quinityn-advanced-defense',
 'y-ammo-biggun':'quinityn-advanced-defense',
 'y-rare-wall-basic':'quinityn-durotal-walls','y-wall-forcefield':'quinityn-forcefield-walls',
 'y_wall22_hardic':'quinityn-hardic-walls','y-rare-wall-adv':'quinityn-reactors','y_ammo_case':'quinityn-ammunition-cases',
 'y_turret_laser22f12':'quinityn-laser-turret','y_turret_plasma':'quinityn-plasma-weapons',
 'y_ammo_plasma':'quinityn-plasma-weapons','y_turret_flame':'quinityn-chemical-weapons',
 'y_ammo_flame':'quinityn-chemical-weapons','yi_mine_impact':'quinityn-poison-mines',
 'yi_mine_plasma':'quinityn-plasma-mines','yi_artillery_shell':'quinityn-artillery-shells',
 'y-weapon-ztt':'quinityn-zero-time-weapon',
}
for recipe,owner in defense_split_owners.items():
 assert unlocks[recipe]==[owner],(recipe,unlocks.get(recipe))
defense_moved_recycling={
 'y-ammo-acid-2-recycling':'quinityn-bridge-advanced-defense-recycling',
 'y-ammo-biggun-recycling':'quinityn-bridge-advanced-defense-recycling',
 'y-ammo-explosiv-recycling':'quinityn-bridge-advanced-defense-recycling',
 'y-ammo-hohlspitz-recycling':'quinityn-bridge-advanced-defense-recycling',
 'y-ammo-krakon-recycling':'quinityn-bridge-advanced-defense-recycling',
 'y-ammo-poison-recycling':'quinityn-bridge-advanced-defense-recycling',
 'y-rare-wall-basic-recycling':'quinityn-bridge-durotal-walls-recycling',
 'y_ammo_case-recycling':'quinityn-bridge-ammunition-cases-recycling',
 'y-wall-forcefield-recycling':'quinityn-bridge-forcefield-walls-recycling',
 'y_wall22_hardic-recycling':'quinityn-bridge-hardic-walls-recycling',
 'y_turret_laser22f12-recycling':'quinityn-bridge-laser-turret-recycling',
 'y_turret_plasma-recycling':'quinityn-bridge-plasma-weapons-recycling',
 'y_ammo_plasma-recycling':'quinityn-bridge-plasma-weapons-recycling',
 'y_turret_flame-recycling':'quinityn-bridge-chemical-weapons-recycling',
 'y_ammo_flame-recycling':'quinityn-bridge-chemical-weapons-recycling',
 'yi_mine_impact-recycling':'quinityn-bridge-poison-mines-recycling',
 'yi_mine_plasma-recycling':'quinityn-bridge-plasma-mines-recycling',
 'yi_artillery_shell-recycling':'quinityn-bridge-artillery-shells-recycling',
 'y-weapon-ztt-recycling':'quinityn-bridge-zero-time-weapon-recycling',
}
for recipe,owner in defense_moved_recycling.items():
 assert unlocks[recipe]==[owner],(recipe,unlocks.get(recipe))
assert 'y-weapon-ztt' not in tech_unlocks('quinityn-quantum-power')
powered={e['recipe'] for e in T['quinityn-powered-armor']['effects'] if e['type']=='unlock-recipe'}
assert powered=={'yi_ammo_energie','yi_armor_gray','yi_equip_battery_a','yi_equip_legs_a','yi_equip_roboport',
 'yi_equip_shield_a','yi_lasergun','yi_minigun','yi_pld_equipment'}
assert T['quinityn-defense']['unit']['count']==100
assert T['quinityn-defense']['prerequisites']==['quinityn-power','quinityn-washing','quinityn-slag-materials']
assert T['quinityn-advanced-defense']['unit']['count']==160
assert T['quinityn-advanced-defense']['prerequisites']==['quinityn-defense','quinityn-advanced-components','quinityn-energy-storage']
assert T['quinityn-powered-armor']['prerequisites']==['quinityn-trade','quinityn-advanced-defense','quinityn-energy-storage','quinityn-laser-turret','quinityn-infusion']
assert 'quinityn-laser-turret' in ancestry('quinityn-powered-armor')
assert any(p['name']=='y_turret_laser22f12' for p in R['yi_pld_equipment']['ingredients'])
assert T['quinityn-walker-1']['prerequisites']==['quinityn-armor-3','quinityn-mastery']
assert T['quinityn-walker-2']['prerequisites']==['quinityn-walker-1']
assert 'quinityn-durotal-walls' in ancestry('quinityn-reactors')
assert 'quinityn-durotal-walls' in ancestry('quinityn-forcefield-walls')
assert 'quinityn-durotal-walls' in ancestry('quinityn-hardic-walls')
assert 'quinityn-chemical-weapons' in ancestry('quinityn-poison-mines')
assert 'quinityn-plasma-weapons' in ancestry('quinityn-plasma-mines')
assert 'quinityn-ammunition-cases' in ancestry('quinityn-plasma-weapons')
assert 'quinityn-ammunition-cases' in ancestry('quinityn-chemical-weapons')
assert 'quinityn-ammunition-cases' in ancestry('quinityn-artillery-shells')
assert 'artillery' in ancestry('quinityn-artillery-shells')
assert 'concrete' in ancestry('quinityn-hardic-walls')
assert 'quinityn-reactors' in ancestry('quinityn-zero-time-weapon')
assert 'quinityn-advanced-storage' in ancestry('quinityn-zero-time-weapon')
assert 'quinityn-quantum-power' not in ancestry('quinityn-zero-time-weapon')
new_defense=['quinityn-durotal-walls','quinityn-forcefield-walls','quinityn-hardic-walls','quinityn-ammunition-cases',
 'quinityn-laser-turret','quinityn-plasma-weapons','quinityn-chemical-weapons','quinityn-poison-mines',
 'quinityn-plasma-mines','quinityn-artillery-shells','quinityn-zero-time-weapon']
for n in new_defense:
 assert 'quinityn-defense' in ancestry(n),n
 assert 'research_trigger' not in T[n],n
 assert T[n]['unit']['time']==20,n
 assert {i[0] for i in T[n]['unit']['ingredients']}=={'automation-science-pack','logistic-science-pack','quinityn-research-data'},n
assert 'gun2_icon' in str(T['quinityn-advanced-defense'].get('icons',T['quinityn-advanced-defense'].get('icon','')))
assert 'gun_1_icon' in str(T['quinityn-defense'].get('icons',T['quinityn-defense'].get('icon','')))
print('PASS: staged defense walls, specialized weapons, ancestry and icons')
def direct_unlocks(tech):
 return {e['recipe'] for e in T[tech].get('effects',[]) if e['type']=='unlock-recipe'}
def quinityn_prerequisites(tech):
 return {p for p in T[tech]['prerequisites'] if p.startswith('quinityn-')}
logistics_kept={'y-inserter-fast','y-inserter-s4','y_sc11'}
assert direct_unlocks('quinityn-logistics')==logistics_kept
logistics_tiers={
 'quinityn-expanded-storage':({'quinityn-logistics'},40,{'y_c22'}),
 'quinityn-large-storage':({'quinityn-expanded-storage'},60,{'y_cg33'}),
 'quinityn-bulk-storage':({'quinityn-large-storage'},80,{'y_sc44'}),
 'quinityn-logistic-storage':({'quinityn-logistics'},80,{'j-dl-provider','y-rare-chest-log'}),
 'quinityn-logistic-provider-capacity':({'quinityn-logistic-storage'},40,{'y_pc22'}),
 'quinityn-logistic-bunker':({'quinityn-logistic-storage','quinityn-large-storage'},60,{'y-rare-m1bunker-log'}),
 'quinityn-logistic-requests':({'quinityn-logistic-storage','quinityn-robotics'},100,{'j-dl-request','j-dl-buffer'}),
 'quinityn-wide-logistic-requests':({'quinityn-logistic-requests'},40,{'y_rc22','y_bc22'}),
}
for tech,(parents,count,recipes) in logistics_tiers.items():
 assert quinityn_prerequisites(tech)==parents,tech
 assert T[tech]['unit']['count']==count,tech
 assert direct_unlocks(tech)==recipes,tech
 for recipe in recipes:
  assert unlocks[recipe]==[tech],(recipe,unlocks.get(recipe))
for recipe in logistics_kept:
 assert unlocks[recipe]==['quinityn-logistics'],(recipe,unlocks.get(recipe))
requests=T['quinityn-logistic-requests']
assert 'logistic-system' in requests['prerequisites']
assert 'chemical-science-pack' not in {i[0] for i in requests['unit']['ingredients']}
advanced_logistics_recipes={
 'y-inserter-smart','y-inserter-smart-long','y_inserter_diagonal','y_inserter_evade_shortL','y_inserter_evade_shortR',
 'y_inserter_smart_LL','y_inserter_smart_RR','y_inserter_smart_leftR2','y_inserter_smart_rightR2'}
assert direct_unlocks('quinityn-advanced-logistics')==advanced_logistics_recipes
assert quinityn_prerequisites('quinityn-advanced-logistics')=={'quinityn-logistics','quinityn-infusion'}
for recipe in advanced_logistics_recipes:
 assert unlocks[recipe]==['quinityn-advanced-logistics'],(recipe,unlocks.get(recipe))
 assert unlocks[recipe+'-recycling']==['quinityn-bridge-advanced-logistics-recycling'],recipe
robotics_stayers={'yi_roboport','yi_logistic-robot','yi_construction-robot'}
assert direct_unlocks('quinityn-robotics')==robotics_stayers
for recipe in robotics_stayers:
 assert unlocks[recipe]==['quinityn-robotics'],(recipe,unlocks.get(recipe))
 assert unlocks[recipe+'-recycling']==['quinityn-bridge-robotics-recycling'],recipe
new_logistics={
 'quinityn-expanded-storage','quinityn-large-storage','quinityn-bulk-storage','quinityn-logistic-storage',
 'quinityn-logistic-provider-capacity','quinityn-logistic-bunker','quinityn-logistic-requests','quinityn-wide-logistic-requests'}
for tech in new_logistics:
 assert 'quinityn-logistics' in ancestry(tech),tech
 assert 'quinityn-advanced-logistics' not in ancestry(tech),tech
assert 'quinityn-expanded-storage' in ancestry('quinityn-large-storage')
assert 'quinityn-large-storage' in ancestry('quinityn-bulk-storage')
assert 'quinityn-logistic-storage' in ancestry('quinityn-logistic-provider-capacity')
assert {'quinityn-logistic-storage','quinityn-large-storage'}<=ancestry('quinityn-logistic-bunker')
assert {'quinityn-logistic-storage','quinityn-robotics','logistic-system'}<=ancestry('quinityn-logistic-requests')
assert 'quinityn-logistic-requests' in ancestry('quinityn-wide-logistic-requests')
assert 'logistic-robotics' in ancestry('quinityn-logistics')
for tech in ['quinityn-logistics','quinityn-expanded-storage','quinityn-large-storage','quinityn-bulk-storage',
             'quinityn-logistic-storage','quinityn-logistic-provider-capacity','quinityn-logistic-bunker']:
 assert 'logistic-system' not in ancestry(tech),tech
for protected in ['quinityn-arrival','quinityn-surplus','quinityn-power','quinityn-industrial-science','quinityn-orbital']:
 for tech in new_logistics:
  assert tech not in ancestry(protected),protected+' blocked by '+tech
for name,size in [('y_sc11',60),('y_c22',100),('y_cg33',140),('y_sc44',220)]:
 assert D['container'][name]['inventory_size']==size,name
for name,mode,size in [
 ('j-dl-provider','passive-provider',60),('y-rare-chest-log','storage',60),('j-dl-request','requester',60),
 ('j-dl-buffer','buffer',60),('y_pc22','passive-provider',70),('y_rc22','requester',70),('y_bc22','buffer',70),
 ('y-rare-m1bunker-log','storage',140)]:
 chest=D['logistic-container'][name]
 assert chest['inventory_size']==size and chest['logistic_mode']==mode,name
def insert_reach(ins):
 pos=ins['insert_position']
 return pos[1] if isinstance(pos,list) else pos['y']
fast=D['inserter']['y-inserter-fast'];long=D['inserter']['y-inserter-s4']
assert abs(insert_reach(fast)-1.2)<1e-6 and abs(insert_reach(long)-4.2)<1e-6
assert unlocks['y-inserter-fast']==unlocks['y-inserter-s4']==['quinityn-logistics']
retained_recycling={'y-inserter-fast-recycling','y-inserter-s4-recycling','y_sc11-recycling'}
assert set(manifest['quinityn-bridge-logistics-recycling'])==retained_recycling
moved_recycling={
 'y_c22-recycling':'quinityn-bridge-expanded-storage-recycling',
 'y_cg33-recycling':'quinityn-bridge-large-storage-recycling',
 'y_sc44-recycling':'quinityn-bridge-bulk-storage-recycling',
 'j-dl-provider-recycling':'quinityn-bridge-logistic-storage-recycling',
 'y-rare-chest-log-recycling':'quinityn-bridge-logistic-storage-recycling',
 'y_pc22-recycling':'quinityn-bridge-logistic-provider-capacity-recycling',
 'y-rare-m1bunker-log-recycling':'quinityn-bridge-logistic-bunker-recycling',
 'j-dl-request-recycling':'quinityn-bridge-logistic-requests-recycling',
 'j-dl-buffer-recycling':'quinityn-bridge-logistic-requests-recycling',
 'y_rc22-recycling':'quinityn-bridge-wide-logistic-requests-recycling',
}
if 'y_bc22-recycling' in unlocks:
 moved_recycling['y_bc22-recycling']='quinityn-bridge-wide-logistic-requests-recycling'
for recipe,bridge in moved_recycling.items():
 assert unlocks[recipe]==[bridge],recipe
 assert recipe not in manifest['quinityn-bridge-logistics-recycling'],recipe
print('PASS: staged logistics storage, requester and buffer unlocks')

# Every active Yuoki module has its own research, including ultimate products
# outside the ordinary module crafting subgroup. Recipe inputs establish lineage.
modules={n for n in D['module'] if n.startswith('y')}
assert len(modules)==11
module_owners={}
for name in modules:
 owners=unlocks[name]
 assert len(owners)==1,(name,owners)
 owner=owners[0];module_owners[name]=owner
 assert [e['recipe'] for e in T[owner]['effects'] if e['type']=='unlock-recipe']==[name], \
  'Module still shares a research unlock: '+name
for name,owner in module_owners.items():
 for ingredient in R[name]['ingredients']:
  if ingredient['name'] in modules:
   assert module_owners[ingredient['name']] in ancestry(owner),(name,ingredient['name'])
assert module_owners['y-green-module-2'] in ancestry(module_owners['y_modul_green_op'])
assert module_owners['y-pink-module-3'] in ancestry(module_owners['y_modul_science'])
assert 'quinityn-mastery' in ancestry(module_owners['y_modul_green_op'])
assert 'quinityn-mastery' in ancestry(module_owners['y_modul_science'])
assert 'quality-module-2' in ancestry(module_owners['y-quality-module-1'])
allowed_packs={'automation-science-pack','logistic-science-pack','military-science-pack',
 'chemical-science-pack','production-science-pack','utility-science-pack','space-science-pack','quinityn-research-data'}
for owner in module_owners.values():
 for parent in ancestry(owner)|{owner}:
  assert {i[0] for i in T[parent].get('unit',{}).get('ingredients',[])}<=allowed_packs,(owner,parent)
# Compare ordinary tiers to the installed vanilla units, with local science added.
for family,vanilla in [('speed','speed'),('green','efficiency'),('pink','productivity')]:
 for tier in [1,2]:
  name=f'y-{family}-module-{tier}'
  unit=T[module_owners[name]]['unit']
  base=T[f'{vanilla}-module'+('' if tier==1 else '-2')]['unit']
  assert unit['count']==base['count'] and unit['time']==base['time']
  assert dict(unit['ingredients'])==dict(base['ingredients'])|{'quinityn-research-data':1}
 first=module_owners[f'y-{family}-module-1']
 assert not (set(module_owners.values())-{first})&ancestry(first),family
late_packs={'automation-science-pack','logistic-science-pack','chemical-science-pack',
 'production-science-pack','space-science-pack','quinityn-research-data'}
for name,count in [('y-pink-module-3',300),('y_modul_red2',1000),('y_modul_green_op',5000),
 ('y_modul_science',5000),('y-quality-module-1',5000)]:
 unit=T[module_owners[name]]['unit']
 expected=late_packs if name=='y-pink-module-3' else late_packs|{'utility-science-pack'}
 assert dict(unit['ingredients'])==dict.fromkeys(expected,1),name
 assert unit['count']==count and unit['time']==60,name
print('PASS: eleven individual modules, ingredient ancestry, vanilla tier 1/2 costs and Nauvis/space-only advanced science')

assert mg['cliff_settings']['name']=='quinityn-cliff'
assert D['cliff']['quinityn-cliff']['orientations']==D['cliff']['cliff-fulgora']['orientations']
assert 'quinityn-cliff-blocker' not in D['cliff']['cliff-fulgora']['collision_mask']['layers']
for name in mg['autoplace_settings']['tile']['settings']:
 assert bool(tiles[name]['collision_mask']['layers'].get('quinityn-cliff-blocker')) == (name!='quinityn-ruined-district')
assert D['autoplace-control']['quinityn_trees']['can_be_disabled']
for name in ['quinityn-dry-tree','quinityn-dead-dry-hairy-tree']:
 tree=D['tree'][name]
 assert name in mg['autoplace_settings']['entity']['settings']
 assert tree['minable']['result']=='wood'
 for sprite in tree['pictures']:
  assert sprite['tint'][0]>sprite['tint'][1] and sprite['tint'][2]>sprite['tint'][1]
print('PASS: Fulgora cliffs and controllable purple dead-tree sprites')

# Each bootstrap stage is a native crafting milestone, with its trigger producible
# from earlier unlocks. Cheap red-only research must not recreate the starter tier.
for name in ['materials','pressing','compacting','alloying','structures','electronics','fuel-processing','basic-factory']:
 t=T['quinityn-'+name]
 assert 'unit' not in t and t['research_trigger']['type']=='craft-item'
 assert len([e for e in t['effects'] if e['type']=='unlock-recipe'])<=4,(name,t['effects'])
 assert 'quinityn-research-data' not in [e.get('recipe') for e in t['effects']] or name=='industrial-science'
for early,later in [('y-crusher','y-heat-form-press'),('y-smelt-crush-res1','y-unicomp-raw'),
 ('y-unicomp-raw','y_structure_element'),('y-orange-stuff','y-chip-1'),
 ('y_structure_element','ye_fassembly1'),('y-chip-1','ye_fassembly1')]:
 assert unlocks[early][0] in ancestry(unlocks[later][0]),(early,later)
for name,t in T.items():
 if name.startswith('quinityn-') and t.get('unit'):
  assert 'quinityn-industrial-science' in ancestry(name),name
print('PASS: eight crafting milestones, separate rock discovery and factory unlocks and science-rooted lab research')

# Habitat is a surface-local generation override, never an enemy collision rule.
for name in ['biter-spawner','spitter-spawner','small-worm-turret','medium-worm-turret','big-worm-turret','behemoth-worm-turret']:
 key='entity:quinityn-'+name+':probability'
 assert key in mg['property_expression_names']
 entity=D.get('unit-spawner',{}).get(name,D.get('turret',{}).get(name))
 assert 'quinityn' not in str(entity.get('collision_mask'))
 assert 'quinityn' not in str(entity['autoplace'])
 for planet in D['planet'].values():
  if planet['name']!='quinityn':
   assert 'quinityn' not in str(planet.get('map_gen_settings',{}).get('property_expression_names',{}).get(key,''))
print('PASS: machinery-only cliff masks and surface-local enemy generation habitat')

# Every size retains its combat/collision identity and stays in a closed colony
# graph. No vanilla unit or nest can introduce a Uni-touched enemy elsewhere.
def particle_effects(value):
 if isinstance(value,dict):
  if value.get('type')=='create-particle':yield value
  for child in value.values():yield from particle_effects(child)
 elif isinstance(value,list):
  for child in value:yield from particle_effects(child)

def royal_violet(tint):
 # The royal-violet base permits distinct blue-violet through grape variants.
 hue,saturation,brightness=colorsys.rgb_to_hsv(*tint[:3])
 assert 240<=hue*360<=295 and .3<=saturation<=.75 and brightness>0,tint

def sprite_layers(value):
 if isinstance(value,dict):
  if any(k in value for k in ['filename','filenames','stripes']) and ('width' in value or 'size' in value):yield value
  for child in value.values():yield from sprite_layers(child)
 elif isinstance(value,list):
  for child in value:yield from sprite_layers(child)

def check_enemy_visuals(native,variant):
 original=list(sprite_layers(native));modified=list(sprite_layers(variant))
 assert original and len(original)==len(modified)
 shade=None
 for before,after in zip(original,modified):
  if before.get('draw_as_shadow'):
   assert after==before
  else:
   assert {k:v for k,v in after.items() if k!='tint'}=={k:v for k,v in before.items() if k!='tint'}
   royal_violet(after['tint'])
   tint=before.get('tint',[1,1,1,1])
   if isinstance(tint,dict):tint=[tint.get(k,1 if k=='a' else 0) for k in ['r','g','b','a']]
   assert abs(max(after['tint'][:3])-max(tint[:3]))<1e-6
   assert after['tint'][3]==tint[3]
   if shade is None and 'tint' in before:
    shade=tuple(round(c,6) for c in colorsys.rgb_to_hsv(*after['tint'][:3])[:2])
 royal_violet(variant['icons'][0]['tint'])
 return shade

for kind,names in [('unit',[s+'-'+k for s in ['small','medium','big','behemoth'] for k in ['biter','spitter']]),
                   ('turret',[s+'-worm-turret' for s in ['small','medium','big','behemoth']]),
                   ('unit-spawner',['biter-spawner','spitter-spawner'])]:
 shades=set()
 for name in names:
  source=D[kind][name];enemy=D[kind]['quinityn-'+name]
  shade=check_enemy_visuals(source,enemy)
  assert shade is not None and shade not in shades,(name,'variant colors collapsed',shade)
  shades.add(shade)
  for key in ['max_health','collision_box','movement_speed','spawning_cooldown']:
   assert enemy.get(key)==source.get(key),(name,key)
  original={r['type']:r for r in source.get('resistances',[])}
  modified={r['type']:r for r in enemy['resistances']}
  laser=modified.pop('laser');native=original.pop('laser',{})
  assert modified==original,name
  assert abs((100-laser['percent'])-(100-native.get('percent',0))*.95)<1e-8,name
  assert laser.get('decrease',0)==native.get('decrease',0),name
  if kind=='unit':
   assert enemy['buildable_entities']==['quinityn-'+n for n in source['buildable_entities']]
   assert enemy['run_animation']!=source['run_animation']
  if kind=='unit-spawner':
   ordinary=[result for result in enemy['result_units'] if not result[0].endswith('-stomp-a-tron')]
   assert ordinary==[['quinityn-'+n,points] for n,points in source['result_units']]
   assert enemy['graphics_set']!=source['graphics_set']
  if kind=='turret':assert enemy['prepared_animation']!=source['prepared_animation']
  if 'autoplace' in enemy:
   assert enemy['autoplace']['probability_expression']==0
   assert enemy['autoplace']['default_enabled'] is False
   assert 'quinityn-'+name in mg['autoplace_settings']['entity']['settings']
   assert name not in mg['autoplace_settings']['entity']['settings']
  for field in ['corpse','folded_state_corpse','dying_explosion']:
   if field in source:assert enemy[field]=='quinityn-'+source[field]
  for field in ['corpse','folded_state_corpse']:
   if field in source:check_enemy_visuals(D['corpse'][source[field]],D['corpse'][enemy[field]])
  native_particles=list(particle_effects(D['explosion'][source['dying_explosion']]['created_effect']))
  tinted_particles=list(particle_effects(D['explosion'][enemy['dying_explosion']]['created_effect']))
  assert native_particles and len(tinted_particles)==len(native_particles),name
  for native,tinted in zip(native_particles,tinted_particles):
   assert {k:v for k,v in tinted.items() if k!='tint'}==native,(name,'death effect changed beyond tint')
   tint=tinted.get('tint')
   assert tint is not None,(name,'death particle lacks Uni-touched tint')
   royal_violet(tint)
   assert tint[3]==1,(name,tint)
for kind in ['unit','unit-spawner']:
 for name,entity in D[kind].items():
  if not name.startswith('quinityn-'):
   assert 'quinityn-' not in str(entity.get('buildable_entities',[])),name
   assert 'quinityn-' not in str(entity.get('result_units',[])),name
print('PASS: Uni-touched enemy identity, minor laser resistance, and isolated spawn/expansion graph')
print('PASS: all 14 Uni-touched death bursts have local particle tints and unchanged effect mechanics')
print('PASS: distinct violet variants preserve sprite geometry, shadows, brightness and opacity through live/remains/icon/particle visuals')

# The new natural remnants stay cosmetic and planet-local, with water shorelines
# rather than lava/void edges. Native source prototypes remain available unchanged.
for name,source in [('quinityn-weathered-soil','dirt-6'),('quinityn-dead-turf','grass-4'),
                    ('quinityn-ash-soil','volcanic-ash-soil')]:
 tile=tiles[name]
 assert tile['absorptions_per_second']['pollution']==.000001
 assert tile['variants']==tiles[source]['variants']
 assert tile['tint']!=tiles[source].get('tint')
 shore=[t for t in tile['transitions'] if 'quinityn-unicomp-sea' in t.get('to_tiles',[])]
 assert len(shore)==1 and 'water' in shore[0]['to_tiles']
 assert all('quinityn-unicomp-sea' not in t.get('to_tiles',[]) for t in tiles[source]['transitions'])
for name in ['quinityn-dead-shrub','quinityn-dry-tuft','quinityn-dead-grass','quinityn-dead-groundcover',
             'quinityn-tiny-rock','quinityn-small-rock']:
 assert name in D['optimized-decorative'] and name in mg['autoplace_settings']['decorative']['settings']
 assert name not in mg['autoplace_settings']['entity']['settings']
 assert 'minable' not in D['optimized-decorative'][name]
for name,planet in D['planet'].items():
 if name!='quinityn':
  assert 'quinityn-weathered-soil' not in planet.get('map_gen_settings',{}).get('autoplace_settings',{}).get('tile',{}).get('settings',{})
print('PASS: decayed soil/turf, native water transitions and non-mineable plant/stone decoratives')

# Discovery and added loot belong exclusively to the Quinityn rock clones.
rocks={'quinityn-big-rock','quinityn-huge-rock'}
science=T['quinityn-industrial-science']
assert science['research_trigger']=={'type':'mine-entity','entities':['quinityn-big-rock','quinityn-huge-rock']}
assert science['prerequisites']==['quinityn-arrival']
assert next(p['amount'] for p in R['quinityn-research-data']['ingredients'] if p['name']=='y-pol-waste')==5
for source,ash in [('big-rock',2),('huge-rock',4)]:
 native=D['simple-entity'][source];rock=D['simple-entity']['quinityn-'+source]
 assert all(p['name']!='y-pol-waste' for p in native['minable'].get('results',[]))
 expected=native['minable'].get('results',[{'type':'item','name':native['minable'].get('result'),'amount':native['minable'].get('count',1)}])
 assert rock['minable']['results']==expected+[{'type':'item','name':'y-pol-waste','amount':ash}]
 assert len(rock['pictures'])==len(native['pictures'])>=16
 assert [p['filename'] for p in rock['pictures']]==[p['filename'] for p in native['pictures']]
 for sprite in rock['pictures']:
  assert sprite['tint'][0]>sprite['tint'][1] and sprite['tint'][2]>sprite['tint'][1]
for name,planet in D['planet'].items():
 mg=planet.get('map_gen_settings',{})
 for rock in rocks:
  assert (rock in mg.get('autoplace_settings',{}).get('entity',{}).get('settings',{})) == (name=='quinityn')
  if name!='quinityn' and mg:assert mg['property_expression_names']['entity:'+rock+':probability']=='0'
for name in ['big-rock','huge-rock','big-sand-rock']:
 assert D['planet']['quinityn']['map_gen_settings']['property_expression_names']['entity:'+name+':probability']=='0'
assert unlocks['y-electric-air-heater']==unlocks['y-rmvpol']==['quinityn-air-scrubbing']
assert not R['y-rmvpol'].get('hidden',False)
for name in ['j-airfilter','j-airfilter_dirty','j-airfilter_cleaning']:
 assert unlocks[name]==['quinityn-air-filters'] and not R[name].get('enabled',True)
def direct_unlocks(tech):
 return {e['recipe'] for e in T[tech].get('effects',[]) if e['type']=='unlock-recipe'}
assert direct_unlocks('quinityn-washing')=={'y-dirtwasher','y-filtering-dust','y-pressed_dry_mud','y-pure-copper','y-pure-iron','y-release-cwater','y-refined-copper','y-refined-iron'}
assert direct_unlocks('quinityn-archaeology')=={'y-wash-dirt','y-wash-special'}
assert direct_unlocks('quinityn-unicomp-compression')=={'y-press-richdust'}
assert direct_unlocks('quinityn-slag-materials')=={'y_slag_granulate','y_slag_brick','y_slag_brick_burn','y_steinmehl'}
assert direct_unlocks('quinityn-slag-paving')=={'y_tile_slagbricks','y_tile_slagfilled','y_tile_slagpattern'}
for tech in ['quinityn-washing','quinityn-archaeology','quinityn-unicomp-compression','quinityn-slag-materials','quinityn-slag-paving']:
 for recipe in direct_unlocks(tech):
  assert unlocks[recipe]==[tech],(recipe,unlocks[recipe])
assert {'quinityn-washing','quinityn-excavation'}<=ancestry('quinityn-archaeology')
assert 'quinityn-washing' in ancestry('quinityn-unicomp-compression')
assert 'quinityn-washing' in ancestry('quinityn-slag-materials')
assert 'quinityn-slag-materials' in ancestry('quinityn-slag-paving')
assert 'quinityn-slag-materials' in ancestry('quinityn-air-filters')
assert 'quinityn-slag-materials' in ancestry('quinityn-defense')
assert 'quinityn-slag-materials' in ancestry('quinityn-crystal-processing')
assert 'quinityn-archaeology' in ancestry('quinityn-quantum')
assert 'quinityn-cimota' not in unlocks.get('y-press-richdust',[])
assert unlocks['y_mc_dirtwasher']==['quinityn-mastery']
assert unlocks['y_pure_copper_wtool']==['quinityn-tooling']
assert unlocks['y_mud2solidfuel']==['quinityn-residue-fuel']
assert unlocks['y-digfdirt']==['quinityn-excavation']
assert unlocks['y_data_crystal']==['quinityn-quantum']
assert {'quinityn-air-scrubbing','quinityn-washing','quinityn-engines','quinityn-slag-materials'}<=ancestry('quinityn-air-filters')
assert next(p['amount'] for p in R['j-airfilter_dirty']['ingredients'] if p['name']=='j-airfilter')==1
assert {p['name']:p['amount'] for p in R['j-airfilter_cleaning']['results']}=={'j-airfilter':1,'y-pol-waste':6}
assert R['j-airfilter_dirty']['emissions_multiplier']==2*R['y-rmvpol'].get('emissions_multiplier',1)
assert 6/R['j-airfilter_dirty']['energy_required']>1/R['y-rmvpol']['energy_required']
assert unlocks['y-waste-condense']==unlocks['y_mixedfuel2rocketfuel']==['quinityn-engines']
def direct_unlocks(tech):
 return {e['recipe'] for e in T[tech].get('effects',[]) if e['type']=='unlock-recipe'}
def quinityn_prerequisites(tech):
 return {p for p in T[tech]['prerequisites'] if p.startswith('quinityn-')}
engines_kept={
 'y-1stirling-engine','y-mf1a','y-mf1a1','y-mf1f','y-mftrans-shaft','y-mftrans-shaft-ground',
 'y-mftrans-shaft-ground-red','y-mftrans-shaft-red','y-mfwater','y-mwater-pump','y-sfe',
 'y-waste-condense','y_flowcheck_10','y_gauge_analog','y_mixedfuel2rocketfuel',
 'ye_tranport_tube_orange','ye_tranport_tube_orange_splitter','ye_tranport_tube_orange_underground','ye_water2mf'}
assert direct_unlocks('quinityn-engines')==engines_kept
advanced_engine_recipes={'y-ffe','y-mf2a','y-mf2b','y-mf2c','y-mf2d','y-mf2e','ye_gasmotor'}
assert direct_unlocks('quinityn-advanced-engines')==advanced_engine_recipes
assert quinityn_prerequisites('quinityn-advanced-engines')=={'quinityn-advanced-factories','quinityn-advanced-components'}
transmission_recipes={'ye_buechsenblech','ye_tranport_tube_green','ye_tranport_tube_green_splitter','ye_tranport_tube_green_underground'}
assert direct_unlocks('quinityn-advanced-transmission')==transmission_recipes
assert quinityn_prerequisites('quinityn-advanced-transmission')=={'quinityn-engines','quinityn-advanced-components'}
assert 'foundry' in ancestry('quinityn-advanced-transmission') and 'foundry' not in ancestry('quinityn-engines')
assert direct_unlocks('quinityn-medium-mf-pump')=={'ye_wpump_m','y_mpump_mf','y_mpump_water'}
assert quinityn_prerequisites('quinityn-medium-mf-pump')=={'quinityn-engines','quinityn-advanced-components'}
assert direct_unlocks('quinityn-medium-electric-motor')=={'ye_emotor_m','ye_motorm_mf'}
assert direct_unlocks('quinityn-mf-heat-generator')=={'ye_mfheatmotor_m','ye_mf_mfheatmotor_m'}
assert 'quinityn-medium-electric-motor' in T['quinityn-mf-heat-generator']['prerequisites']
assert 'ye_emotor_m' not in direct_unlocks('quinityn-mf-heat-generator')
assert direct_unlocks('quinityn-steam-overheating')=={'ye_overheater','ye_makesteam'}
assert direct_unlocks('quinityn-steam-turbine')=={'ye_sturbine','ye_steam2mf','ye_steam3mf'}
assert 'quinityn-steam-overheating' in T['quinityn-steam-turbine']['prerequisites']
assert direct_unlocks('quinityn-high-temperature-generation')=={'ye_tfmw_generator-s','ye_tfmw_turbine-s'}
assert {'quinityn-medium-electric-motor','quinityn-steam-turbine'}<=set(T['quinityn-high-temperature-generation']['prerequisites'])
assert direct_unlocks('quinityn-substrat-neutralization')=={'ye_neutralisatzion'}
assert 'quinityn-genetics' in T['quinityn-substrat-neutralization']['prerequisites']
assert 'ye_neutralisatzion' not in direct_unlocks('quinityn-engines')
assert direct_unlocks('quinityn-advanced-generation')=={'y-seg'}
assert direct_unlocks('quinityn-air-scrubbing')=={
 'y-electric-air-heater','y-emotor-s','y-iron-case','y-mf1c','y-rmvpol','y-winding','yie_hard_metals'}
# One owner each. A second technology unlocking the same recipe would still pass the effect-set checks above.
sole_owner={
 'quinityn-engines':engines_kept,
 'quinityn-advanced-engines':advanced_engine_recipes,
 'quinityn-advanced-transmission':transmission_recipes,
 'quinityn-medium-mf-pump':{'ye_wpump_m','y_mpump_mf','y_mpump_water'},
 'quinityn-substrat-neutralization':{'ye_neutralisatzion'},
 'quinityn-medium-electric-motor':{'ye_emotor_m','ye_motorm_mf'},
 'quinityn-mf-heat-generator':{'ye_mfheatmotor_m','ye_mf_mfheatmotor_m'},
 'quinityn-steam-overheating':{'ye_overheater','ye_makesteam'},
 'quinityn-steam-turbine':{'ye_sturbine','ye_steam2mf','ye_steam3mf'},
 'quinityn-high-temperature-generation':{'ye_tfmw_generator-s','ye_tfmw_turbine-s'},
 'quinityn-advanced-generation':{'y-seg'},
 'quinityn-air-scrubbing':{
  'y-electric-air-heater','y-emotor-s','y-iron-case','y-mf1c','y-rmvpol','y-winding','yie_hard_metals'},
}
for tech,recipes in sole_owner.items():
 for recipe in recipes:
  assert unlocks[recipe]==[tech],(recipe,unlocks.get(recipe))
assert 'quinityn-advanced-engines' in ancestry('quinityn-p3-factory')
for tech in T:
 if tech.startswith('quinityn-') and tech in {
  'quinityn-medium-mf-pump','quinityn-substrat-neutralization','quinityn-medium-electric-motor',
  'quinityn-mf-heat-generator','quinityn-steam-overheating','quinityn-steam-turbine',
  'quinityn-high-temperature-generation'}:
  assert 'quinityn-arrival' in ancestry(tech),tech
assert D['assembling-machine']['ye_emotor_m']['energy_usage']=='350kW'
assert D['assembling-machine']['ye_mfheatmotor_m']['energy_usage']=='6MW'
assert D['assembling-machine']['ye_overheater']['energy_usage']=='28MW'
assert D['assembling-machine']['ye_wpump_m']['crafting_speed']==4
assert D['assembling-machine']['y-mwater-pump']['crafting_speed']==1
assert R['y-mf2a']['categories']==['yrcat-mf1b'] and R['y-mf2b']['categories']==['yrcat-mf1b']
assert R['y-mf2c']['categories']==['yrcat-mf1gm'] and R['y-mf2d']['categories']==['yrcat-mf1gm']
def steam_ingredient(recipe,fluid):
 for p in R[recipe]['ingredients']:
  if p.get('type')=='fluid' and p['name']==fluid:return p
 raise AssertionError(recipe+' missing '+fluid)
def mf_result(recipe):
 for p in R[recipe]['results']:
  if p.get('type')=='fluid' and p['name']=='y-mechanical-force':return p
 raise AssertionError(recipe+' missing mechanical force')
s2=steam_ingredient('ye_steam2mf','steam');s3=steam_ingredient('ye_steam3mf','steam')
assert s2['amount']==560 and s2.get('minimum_temperature')==500
assert s3['amount']==800 and s3.get('minimum_temperature')==950
assert mf_result('ye_steam2mf')['amount']==25 and mf_result('ye_steam3mf')['amount']==75
for name in ['ye_tranport_tube_green','ye_tranport_tube_green_splitter','ye_tranport_tube_green_underground']:
 assert 'metallurgy' in R[name]['categories']
 assert any(p['name']=='tungsten-plate' for p in R[name]['ingredients'])
for name in ['y-mftrans-shaft-red','y-mftrans-shaft-ground-red']:
 assert not any(p.get('name')=='tungsten-plate' for p in R[name]['ingredients'])
print('PASS: Quinityn-only rock discovery/loot, dedicated Fatmice, later reusable filters and flyash rocket fuel')
print('PASS: staged mechanical-force engine and transmission unlocks')

prim=D['assembling-machine']['quinityn-burner-separator']
assert prim['crafting_categories']==['quinityn-separation','quinityn-primitive-conversion']
full=D['assembling-machine']['y-atomic-constructor']
assert full['crafting_categories']==['yuoki-atomics'] and full['crafting_speed']==2 and full['energy_usage']=='1200kW'
assert 'quinityn-primitive-conversion' not in D['character']['character']['crafting_categories']
surplus_specs={
 'quinityn-stone-to-uc':([('stone',40)],[('y-unicomp-a2',1)]),
 'quinityn-wood-to-uc':([('wood',40)],[('y-unicomp-a2',1)]),
 'quinityn-uc-to-coal':([('y-unicomp-a2',1)],[('coal',10)]),
 'quinityn-uc-to-iron':([('y-unicomp-a2',1)],[('iron-ore',10)]),
 'quinityn-uc-to-copper':([('y-unicomp-a2',1)],[('copper-ore',10)]),
}
for name,(ing,res) in surplus_specs.items():
 r=R[name]
 assert r['categories']==['quinityn-primitive-conversion'] and r['energy_required']==8
 assert r.get('enabled',True) is False and r['subgroup']=='quinityn-fieldwork' and r['order']==name
 assert not r.get('allow_productivity',True) and r.get('auto_recycle') is False
 assert [(p['name'],p['amount']) for p in r['ingredients']]==ing
 assert [(p['name'],p['amount']) for p in r['results']]==res
 assert unlocks[name]==['quinityn-surplus']
surplus=T['quinityn-surplus']
assert surplus['prerequisites']==['quinityn-arrival'] and 'unit' not in surplus
assert surplus['research_trigger']=={'type':'craft-item','item':'quinityn-burner-separator','count':1}
assert 'quinityn-power' not in ancestry('quinityn-surplus')
assert 'quinityn-cimota' not in ancestry('quinityn-surplus')
for upstream in ['y-ac-stone2uc','y-ac-wood2uc','y-ac-uc2coal','y-ac-uc2iron-ore','y-ac-uc2copper-ore']:
 assert unlocks[upstream]==['quinityn-cimota']
prim_time=lambda r,s: r['energy_required']/s
prim_chain=prim_time(R['quinityn-wood-to-uc'],0.5)+prim_time(R['quinityn-uc-to-coal'],0.5)
full_chain=prim_time(R['y-ac-wood2uc'],2)+prim_time(R['y-ac-uc2coal'],2)
assert prim_chain>full_chain
def recipe_amount(recipe_name,field,item_name):
 recipe=R[recipe_name]
 parts=[p for p in (recipe.get(field) or []) if p.get('name')==item_name]
 assert len(parts)==1 and isinstance(parts[0].get('amount'),(int,float)) and parts[0]['amount']>0, recipe_name+' missing '+item_name+' in '+field
 return parts[0]['amount']
wood_in,coal_out=40,10
full_wood=recipe_amount('y-ac-wood2uc','ingredients','wood')
full_coal=recipe_amount('y-ac-uc2coal','results','coal')
assert wood_in/full_wood>coal_out/full_coal, 'Primitive wood-to-coal yield must stay below the loaded full Cimota recipes'
coal_fuel=I.get('coal',{}).get('fuel_value','4MJ')
if coal_fuel=='4MJ':
 assert int(I['wood']['fuel_value'][:-2])*wood_in>=int(coal_fuel[:-2])*coal_out, 'Primitive wood-to-coal must not multiply fuel energy'
assert unlocks['quinityn-water']==['quinityn-arrival']
refining_kept={
 'y-sulfuric-acid','y-water-gen','y-water-gen-fluid','y_catalyst_bp','y_catalyst_ft','y_coal2liquid','y_ft',
 'y_granulate_wood','y_rawsyngas1','y_rawsyngas2','y_refinehydrogen','y_regcatbp','y_regcatft'}
assert {e['recipe'] for e in T['quinityn-refining']['effects'] if e['type']=='unlock-recipe'}==refining_kept
thermal={
 'y_smelter','y_charger','y_block_heat','y_hps_purecopper','y_hps_pureiron','y_hps_steel'}
assert {e['recipe'] for e in T['quinityn-thermal-smelting']['effects'] if e['type']=='unlock-recipe'}==thermal
assert set(T['quinityn-refining']['prerequisites'])=={'quinityn-engines','quinityn-advanced-components'}
assert set(T['quinityn-thermal-smelting']['prerequisites'])=={'quinityn-refining','quinityn-quantum'}
assert {'quinityn-refining','quinityn-quantum'}<=ancestry('quinityn-thermal-smelting')
assert 'quinityn-quantum' not in ancestry('quinityn-refining')
assert set(T['quinityn-washing']['prerequisites'])=={'quinityn-industrial-science','quinityn-basic-factory','quinityn-fuel-processing'}
assert set(T['quinityn-energy-storage']['prerequisites'])=={'quinityn-power','quinityn-washing','quinityn-advanced-components'}
assert 'quinityn-archaeology' in ancestry('quinityn-quantum')
assert 'quinityn-excavation' in ancestry('quinityn-thermal-smelting')
assert 'quinityn-plant-infrastructure' not in ancestry('quinityn-thermal-smelting')
assert unlocks['y_data_crystal']==['quinityn-quantum']
assert unlocks['y-atomic-quantum-composer']==['quinityn-quantum']
assert 'y_charger' not in {e['recipe'] for e in T['quinityn-quantum']['effects'] if e['type']=='unlock-recipe'}
adv_comp={e['recipe'] for e in T['quinityn-advanced-components']['effects'] if e['type']=='unlock-recipe'}
assert 'y_block_heat' not in adv_comp and 'y_block_cold' in adv_comp
slurry=R['ye_slurry2ethanol']
assert slurry['main_product']=='y_syngas_raw'
assert [p['name'] for p in slurry['results']]==['y_syngas_raw']
assert {p['name'] for p in slurry['ingredients']}=={'ye_slurry','ye_sugar'}
bio={'ye_biofuel','ye_granulate_corn','ye_granulate_trifitan','ye_granulate_vuger'}
assert {e['recipe'] for e in T['quinityn-biological-feedstock']['effects'] if e['type']=='unlock-recipe'}==bio
assert set(T['quinityn-biological-feedstock']['prerequisites'])=={'quinityn-agriculture'}
assert {e['recipe'] for e in T['quinityn-slurry-syngas']['effects'] if e['type']=='unlock-recipe'}=={'ye_slurry2ethanol'}
assert set(T['quinityn-slurry-syngas']['prerequisites'])=={'quinityn-biological-feedstock','quinityn-husbandry'}
molten={'yi-molten-iron','yi-molten-copper'}
assert {e['recipe'] for e in T['quinityn-foundry-melting']['effects'] if e['type']=='unlock-recipe'}==molten
assert set(T['quinityn-foundry-melting']['prerequisites'])=={'quinityn-refining','foundry'}
assert 'foundry' in ancestry('quinityn-foundry-melting')
assert 'foundry' not in ancestry('quinityn-refining')
crush={'j_crushing_to_n4','j_crushing_to_f7'}
assert {e['recipe'] for e in T['quinityn-asteroid-crushing']['effects'] if e['type']=='unlock-recipe'}==crush
assert set(T['quinityn-asteroid-crushing']['prerequisites'])=={'quinityn-materials','quinityn-industrial-science','space-platform'}
assert 'space-platform' in ancestry('quinityn-asteroid-crushing')
assert 'quinityn-industrial-science' in ancestry('quinityn-asteroid-crushing')
for recipe in refining_kept:
 assert unlocks[recipe]==['quinityn-refining'],recipe
for recipe in thermal:
 assert unlocks[recipe]==['quinityn-thermal-smelting'],recipe
for recipe in bio:
 assert unlocks[recipe]==['quinityn-biological-feedstock'], recipe
assert unlocks['ye_slurry2ethanol']==['quinityn-slurry-syngas']
for recipe in molten:
 assert unlocks[recipe]==['quinityn-foundry-melting'], recipe
for recipe in crush:
 assert unlocks[recipe]==['quinityn-asteroid-crushing'], recipe
for tech in ['quinityn-thermal-smelting','quinityn-biological-feedstock','quinityn-slurry-syngas',
 'quinityn-foundry-melting','quinityn-asteroid-crushing']:
 assert 'quinityn-arrival' in ancestry(tech),tech
assert R['y_hps_purecopper']['categories']==['yuoki_smelter_recipe']
assert R['y_hps_pureiron']['categories']==['yuoki_smelter_recipe']
assert R['y_hps_steel']['categories']==['yuoki_smelter_recipe']
assert R['y_block_heat']['categories']==['yuoki_charger_recipe']
assert R['yi-molten-iron']['categories']==['metallurgy']
assert R['yi-molten-copper']['categories']==['metallurgy']
assert R['j_crushing_to_n4']['categories']==['crushing']
assert R['j_crushing_to_f7']['categories']==['crushing']
print('PASS: primitive surplus conversions, gated full Cimota atomics unchanged, water bootstrap intact')
print('PASS: refining split by chemical, biological, thermal, foundry and asteroid processing')
science=R['quinityn-research-data']
assert science['allow_productivity'] is True
assert science['allow_quality'] is False
assert {p['name']:p['amount'] for p in science['ingredients']}=={'y-unicomp-raw':1,'y-refined-yres2':1,'y_rwtechsign':1,'y-pol-waste':5}
assert science['results']==[{'type':'item','name':'quinityn-research-data','amount':5}]
assert science['energy_required']==5
assert science['categories']==['quinityn-science']
assert science['surface_conditions']==[{'property':'quinityn-industry','min':1,'max':1}]
for name in ['quinityn-hand-sort','quinityn-iron','quinityn-copper','quinityn-carbon','quinityn-stone','quinityn-timber',
 'quinityn-burner-separator','quinityn-water','quinityn-technic-sign','quinityn-low-density-structure',
 'quinityn-processing-unit','quinityn-foundation','quinityn-stone-to-uc','quinityn-wood-to-uc',
 'quinityn-uc-to-coal','quinityn-uc-to-iron','quinityn-uc-to-copper']:
 assert R[name].get('allow_productivity',False) is False,name
for name,slots in [('ye_fassembly1',3),('ye_fassembly2',3),('ye_fassembly_sp',2)]:
 machine=D['assembling-machine'][name]
 assert 'productivity' in machine['allowed_effects'],name
 assert 'quinityn-science' in machine['crafting_categories'],name
 assert machine['module_slots']==slots,name
print('PASS: industrial research data accepts productivity; other Quinityn recipes and factory slots unchanged')
