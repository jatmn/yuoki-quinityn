"""Resolve explicit and implicit Quinityn locale contracts against installed English dictionaries."""
import json,re,sys
from pathlib import Path
D=json.loads(Path(sys.argv[1]).read_text());root=Path(__file__).resolve().parents[1]
keys={}
for mod in [root,*[Path(p) for p in sys.argv[2:]]]:
 for file in (mod/'locale/en').glob('*.cfg'):
  section='';seen=set()
  for line in file.read_text(encoding='utf-8-sig').splitlines():
   if line.startswith('['):section=line.strip()[1:-1]
   elif '=' in line and not line.startswith(';'):
    key,value=line.split('=',1);full=section+'.'+key
    if mod==root:assert full not in seen, 'Duplicate localization: '+full
    seen.add(full);keys[full]=value

def localized(value,owner):
 if isinstance(value,list):
  if value and isinstance(value[0],str) and re.match(r'^[a-z-]+\.',value[0]):
   assert value[0] in keys, f'Missing {value[0]} in {owner}'
  for child in value:localized(child,owner)
 elif isinstance(value,dict):
  for key,child in value.items():
   if key.endswith('_key') and isinstance(child,str):assert child in keys,(owner,child)
   if isinstance(child,(list,dict)):localized(child,owner)

fallback={'item':'item-name','tool':'item-name','recipe':'recipe-name','tile':'tile-name',
 'assembling-machine':'entity-name','simple-entity':'entity-name','planet':'space-location-name',
 'space-connection':'space-connection-name','technology':'technology-name',
 'surface-property':'surface-property-name','item-subgroup':'item-subgroup-name',
 'recipe-category':'recipe-category-name','optimized-decorative':'decorative-name',
 'noise-expression':'noise-expression-name','tips-and-tricks-item':'tips-and-tricks-item-name',
 'tips-and-tricks-item-category':'tips-and-tricks-item-category-name'}
checked=0
for kind,group in D.items():
 for name,p in group.items():
  if not ('quinityn' in name):continue
  localized(p,kind+'/'+name)
  if kind in fallback and not p.get('localised_name'):
   assert fallback[kind]+'.'+name in keys, 'Missing implicit name: '+kind+'/'+name
  if kind=='surface-property':assert 'surface-property-unit.'+name in keys
  checked+=1
print(f'PASS: {checked} Quinityn prototypes have resolved explicit and visible fallback English locale keys')
