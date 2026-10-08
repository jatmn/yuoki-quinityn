#!/usr/bin/env python3
"""Fetch the exact 2.1 dependency sources; never modify upstream branches."""
import argparse, json, subprocess
from pathlib import Path
LOCK={
 'Yuoki':{'url':'https://github.com/jatmn/Yuoki-Factorio-2.x.git','commit':'c865cf05d5009d7f2224b32900272d4b1f012f21'},
 'yi_engines':{'url':'https://github.com/jatmn/Yuoki-Engines-Factorio-2.0.git','commit':'dd13f421f68010fd0180cda4fb9273f9b582198e'},
}
def main():
 p=argparse.ArgumentParser();p.add_argument('--directory',type=Path,default=Path('build/dependencies'));a=p.parse_args()
 for name,source in LOCK.items():
  path=a.directory/name
  if not path.exists():
   subprocess.run(['git','clone','--no-checkout',source['url'],str(path)],check=True)
   subprocess.run(['git','-C',str(path),'checkout','--detach',source['commit']],check=True)
  actual=subprocess.check_output(['git','-C',str(path),'rev-parse','HEAD'],text=True).strip()
  if actual!=source['commit']:raise SystemExit(f'{path}: expected {source["commit"]}, found {actual}; use an empty directory')
  if subprocess.check_output(['git','-C',str(path),'status','--porcelain'],text=True).strip():raise SystemExit(f'{path}: modified; will not overwrite')
  print(name,actual)
if __name__=='__main__':main()
