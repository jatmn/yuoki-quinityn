"""Validate gameplay contracts against the actual engine prototype dump."""
import json,re,sys
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
for n in ['iron','copper','stone','carbon','timber','hand-sort']:
 assert R['quinityn-'+n]['categories']==['hand-crafting']
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
for n in ['quinityn-mining-productivity','quinityn-plasma-damage']:
 assert T[n]['max_level']=='infinite'
 assert ['quinityn-research-data',2] in T[n]['unit']['ingredients']
 assert T[n]['unit']['count_formula']=='1000*1.5^(L-1)'
tips=[n for n in D['tips-and-tricks-item'] if n.startswith('quinityn-')]
assert len(tips)==17
# Localized rich-text links must point at actual prototypes.
text=(root/'locale/en/quinityn.cfg').read_text()
for kind,name in re.findall(r'\[(item|entity|fluid|recipe|technology|planet)=([^\]]+)\]',text):
 exists=name in D.get(kind,{})
 if kind=='item':exists=exists or name in D.get('tool',{})
 if kind=='entity':exists=any(name in group for group in D.values() if isinstance(group,dict))
 assert exists,f'Broken guide link: {kind}={name}'
for name in ['quinityn-basalt','quinityn-slag','quinityn-ruined-district','quinityn-unicomp-sea']:
 assert tiles[name]['absorptions_per_second']['pollution']==.000001
print(f'PASS: {len(owned)} named upstream recipe gates; technology DAG; 17 guide chapters; foundations; science sinks; pollution')
# A compact reviewable manifest is generated from the engine, not a parallel source of truth.
manifest={n:[e['recipe'] for e in t.get('effects',[]) if e['type']=='unlock-recipe'] for n,t in T.items() if n.startswith('quinityn-')}
(root/'docs/recipe-unlocks.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')
