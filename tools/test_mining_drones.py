#!/usr/bin/env python3
"""Native Mining Drones selector ownership, mining and save-upgrade regression."""
import argparse
import json
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--factorio', type=Path, required=True)
    parser.add_argument('--dependencies', type=Path, required=True)
    parser.add_argument('--mining-drones', type=Path, required=True)
    parser.add_argument('--output', type=Path, default=ROOT / 'build/mining-drones')
    args = parser.parse_args()
    engine = args.factorio.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    output = Path(tempfile.mkdtemp(prefix='run-', dir=args.output.resolve()))
    print('Run directory:', output, flush=True)

    def environment(name, addon):
        folder = output / name
        mods = folder / 'mods'
        mods.mkdir(parents=True)
        sources = [('Yuoki', args.dependencies / 'Yuoki'),
                   ('yi_engines', args.dependencies / 'yi_engines'),
                   ('Mining_Drones', args.mining_drones)]
        if addon:
            sources.append(('yuoki-quinityn', ROOT))
        for mod, source in sources:
            (mods / mod).symlink_to(source.resolve(), target_is_directory=True)
        harness = mods / 'quinityn-tests'
        harness.mkdir()
        (harness / 'info.json').write_text(json.dumps({
            'name': 'quinityn-tests', 'version': '0.1.0', 'factorio_version': '2.1',
            'title': 'Mining Drones tests', 'author': 'jatmn',
            'dependencies': [mod for mod, _ in sources]}))
        (harness / 'control.lua').write_text((ROOT / 'tests/mining_drones.lua').read_text())
        (harness / 'parameters.lua').write_text('return {legacy=false}\n')
        names = ['base', 'space-age', 'quality', 'elevated-rails', 'quinityn-tests']
        names += [mod for mod, _ in sources]
        (mods / 'mod-list.json').write_text(json.dumps({
            'mods': [{'name': mod, 'enabled': True} for mod in names]}))
        config = folder / 'config.ini'
        config.write_text(f'[path]\nread-data={engine.parents[2] / "data"}\nwrite-data={folder / "write"}\n')
        return folder, harness, [str(engine), '--config', str(config), '--mod-directory', str(mods)]

    def run(env, name, options, marker):
        result = subprocess.run(env[2] + options, capture_output=True, text=True, timeout=180)
        text = result.stdout + result.stderr
        (env[0] / (name + '.log')).write_text(text)
        assert result.returncode == 0 and marker in text, name + ':\n' + text[-6000:]
        print('PASS', env[0].name, name, flush=True)

    before = environment('control', False)
    after = environment('candidate', True)
    for env in [before, after]:
        run(env, 'dump', ['--dump-data'], 'Factorio initialised')
    baseline = json.loads((before[0] / 'write/script-output/data-raw-dump.json').read_text())
    candidate = json.loads((after[0] / 'write/script-output/data-raw-dump.json').read_text())

    def selectors(dump):
        return {name: recipe for name, recipe in dump['recipe'].items()
                if 'mining-depot' in recipe.get('categories', [recipe.get('category')])}

    expected, actual = selectors(baseline), selectors(candidate)
    assert expected and actual.keys() == expected.keys(), 'generated selector set changed'
    for name in expected:
        assert actual[name] == expected[name], 'Quinityn mutated selector: ' + name

    def unlocks(dump):
        return sorted((name, effect['recipe']) for name, tech in dump['technology'].items()
                      for effect in tech.get('effects', []) if effect.get('recipe') in actual)

    assert unlocks(candidate) == unlocks(baseline), 'selector unlock ownership changed'
    assert not any(name.startswith('quinityn-') for name, _ in unlocks(candidate)), 'Quinityn selector unlock'
    assert not candidate['recipe']['y-crusher']['enabled'], 'manufacturing leaked'
    print('PASS complete selector equality and zero Quinityn effects:', len(actual), flush=True)
    for env in [before, after]:
        save = env[0] / 'fresh.zip'
        run(env, 'fresh-create', ['--create', str(save)], 'MINING FRESH SETUP')
        run(env, 'fresh-mining', ['--benchmark', str(save), '--benchmark-ticks', '6001',
                                '--benchmark-runs', '1'], 'MINING PASSED')

    # Reconstruct the reported direct gate and a hidden bridge on the other ore.
    # The upstream mod stays intact. Reload must also preserve built depots.
    legacy = after[1] / 'data-final-fixes.lua'
    legacy.write_text('''
data.raw.recipe["mine-y-res1"].enabled = false
data.raw.recipe["mine-y-res2"].enabled = false
table.insert(data.raw.technology["quinityn-refining"].effects,
  {type="unlock-recipe", recipe="mine-y-res1"})
local bridge = table.deepcopy(data.raw.technology["quinityn-refining"])
bridge.name = "quinityn-bridge-refining-mining-test"
bridge.hidden = true
bridge.prerequisites = {"quinityn-refining"}
bridge.effects = {{type="unlock-recipe", recipe="mine-y-res2"}}
data:extend({bridge})
''')
    (after[1] / 'parameters.lua').write_text('return {legacy=true}\n')
    save = after[0] / 'legacy.zip'
    try:
        run(after, 'legacy-create', ['--create', str(save)], 'MINING LEGACY SETUP')
    finally:
        legacy.unlink()
        (after[1] / 'parameters.lua').write_text('return {legacy=false}\n')
    run(after, 'upgrade-mining', ['--benchmark', str(save), '--benchmark-ticks', '6001',
                                '--benchmark-runs', '1'], 'MINING UPGRADE PASSED')
    print('MINING UPGRADE PASSED', flush=True)


if __name__ == '__main__':
    main()
