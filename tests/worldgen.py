"""Check actual engine-generated terrain samples and stockpile distributions."""
import json,collections,re,sys
from pathlib import Path
output=Path(sys.argv[1]);maps=sorted((output/'runtime/script-output').glob('quinityn-map-*.json'))
assert len(maps)>=3
for p in maps:
 m=json.loads(p.read_text());rows=m['rows'];counts=collections.Counter(''.join(rows))
 assert '?' not in counts
 assert set(counts)==set('~.smardge'), 'Missing terrain variety, including the ash/soil transition'
 land=sum(counts.values())-counts['~']
 natural=(counts['d']+counts['g']+counts['e'])/land
 assert .2<natural<.7,'Old soil and dead turf should form substantial patches between industrial scars'
 # Sample actual generated boundaries, not the noise formula: most edges of
 # solid soil/turf should meet mixed ash/earth before reaching scarred ground.
 edges=collections.Counter()
 for y,row in enumerate(rows[:-1]):
  for x,a in enumerate(row[:-1]):
   for b in (row[x+1],rows[y+1][x]):
    if (a in 'dg') != (b in 'dg'):
     neighbor=b if a in 'dg' else a
     if neighbor!='~':edges['fringe' if neighbor=='e' else 'abrupt']+=1
 softened=edges['fringe']/sum(edges.values())
 assert softened>.75,'Most soil/turf edges should grade through mixed ash/earth'
 print(f"Seed {m['seed']}: {softened:.1%} of soil/turf boundaries meet the weathered fringe")
 assert .2<land/sum(counts.values())<.7,'Unexpected land/sea balance'
 frontier=collections.deque([(180,180)]);seen={(180,180)}
 while frontier:
  x,y=frontier.popleft()
  for a,b in [(x+1,y),(x-1,y),(x,y+1),(x,y-1)]:
   if 0<=a<360 and 0<=b<360 and rows[b][a]!='~' and (a,b) not in seen:
    seen.add((a,b));frontier.append((a,b))
 assert len(seen)/land>.75, 'Most land must connect to the starting district'
 starter=sum(e['x']**2+e['y']**2<160**2 for e in m['wrecks'])
 outer=sum(e['x']**2+e['y']**2>160**2 for e in m['wrecks'])
 bins=collections.Counter((int(e['x']//64),int(e['y']//64)) for e in m['wrecks'] if abs(e['x'])<320 and abs(e['y'])<320)
 assert starter>=15 and outer>=30,'Both starter and distant salvage required'
 assert len(bins)<50 and max(bins.values())>20,'Salvage should form sparse dense districts'
 print(f"Seed {m['seed']}: land {land/sum(counts.values()):.1%}, connected {len(seen)/land:.1%}, natural soil/turf {natural:.1%} of land, starter wrecks {starter}, outer wrecks {outer}, occupied districts {len(bins)}/100")
centroids=[]
for seed in [1,42,8675309]:
 text=(output/f'generate-{seed}.log').read_text()
 match=re.findall(r'STARTER CENTROID (y-res[12]) ([\d.e+-]+) ([\d.e+-]+)',text)
 assert len(match)==2
 centroids.append(tuple((n,round(float(x)),round(float(y))) for n,x,y in match))
assert len(set(centroids))==3,'Seed must change patch placement'
print('PASS: organic connected terrain, nine surface types with weathered transition zones, sparse dense salvage clusters and seed-varied starter placements')
