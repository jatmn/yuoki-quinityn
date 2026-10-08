#!/usr/bin/env python3
"""Produce deterministic installable zips; source and dependency assets stay separate."""
import argparse, hashlib, json, zipfile
from pathlib import Path
from release_notes import next_patch, render, split_pending
ROOT=Path(__file__).resolve().parents[1]
def development_files(info, changelog, nightly=False):
 """Package pending notes as a numeric upcoming-patch snapshot; leave source alone."""
 if not nightly and split_pending(changelog)[0] is None:return {}
 info={**info,'version':next_patch(info['version'])}
 return {'info.json':(json.dumps(info,indent=2)+'\n').encode(),
         'changelog.txt':render(changelog,info['version'],nightly=True).encode()}

def pack(root,out,addon=False,nightly=False):
 info=json.loads((root/'info.json').read_text())
 overrides=development_files(info,(root/'changelog.txt').read_text(),nightly) if addon else {}
 if overrides:info=json.loads(overrides['info.json'])
 name=f'{info["name"]}_{info["version"]}';target=out/(name+'.zip')
 with zipfile.ZipFile(target,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
  for p in sorted(root.rglob('*')):
   rel=p.relative_to(root)
   if not p.is_file() or any(x.startswith('.') or x in {'build','__pycache__'} for x in rel.parts):continue
   if addon and rel.parts[0] in {'tests','tools','docs','AGENTS.md','CONTRIBUTING.md'}:continue
   zi=zipfile.ZipInfo(name+'/'+rel.as_posix(),date_time=(2026,10,6,0,0,0));zi.compress_type=zipfile.ZIP_DEFLATED
   zi.external_attr=0o644<<16;z.writestr(zi,overrides.get(rel.as_posix(),p.read_bytes()))
 print(target)
 return target
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--dependencies',type=Path);p.add_argument('--output',type=Path,default=ROOT/'build/dist');p.add_argument('--nightly',action='store_true');a=p.parse_args()
 if a.nightly and a.dependencies:p.error('Nightlies package only the addon')
 a.output.mkdir(parents=True,exist_ok=True)
 files=[pack(ROOT,a.output,True,a.nightly)]
 if a.dependencies:
  for name in ['Yuoki','yi_engines']:files.append(pack(a.dependencies/name,a.output))
 (a.output/'SHA256SUMS').write_text(''.join(hashlib.sha256(f.read_bytes()).hexdigest()+'  '+f.name+'\n' for f in files))
