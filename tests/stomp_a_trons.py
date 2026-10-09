"""Loaded engine contracts for the approved half-size hybrid enemy family."""
import json, sys
from pathlib import Path

D = json.loads(Path(sys.argv[1]).read_text())
sizes = ['small', 'medium', 'big']
names = ['quinityn-' + size + '-stomp-a-tron' for size in sizes]

def walk(value):
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from walk(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk(child)

def vector(value):
    return [value['x'], value['y']] if isinstance(value, dict) else value

def check_half(a, b):
    assert all(abs(x - y * .5) < 1e-8 for x, y in zip(vector(a), vector(b))), (a, b)

def weight(points, evolution):
    if evolution <= points[0][0]:
        return points[0][1]
    for (x, y), (xx, yy) in zip(points, points[1:]):
        if evolution <= xx:
            return y + (yy-y) * (evolution-x) / (xx-x)
    return points[-1][1]

body_tints = []
for size, name, laser, salvage, data in zip(sizes, names, [3, 7, 11],
        [(1, 2), (3, 4), (6, 9)], [('y-crystal2', 1, 5), ('y-crystal2', 4, 7), ('y_crystal2_combined', 1, 1)]):
    unit = D['spider-unit'][name]
    source = D['spider-unit'][size + '-stomper-pentapod']
    assert unit['surface_conditions'] == [{'property': 'quinityn-industry', 'min': 1, 'max': 1}]
    assert not unit.get('autoplace') and not unit.get('minable') and not unit.get('buildable_entities')
    assert not unit.get('dying_trigger_effect')
    assert unit['absorptions_to_join_attack'] == {'pollution': 25}
    assert unit['max_health'] == source['max_health']
    assert unit['attack_parameters']['range'] == source['attack_parameters']['range'] * .5
    for emission, original in zip(unit['attack_parameters']['projectile_creation_parameters'],
                                  source['attack_parameters']['projectile_creation_parameters']):
        assert emission[0] == original[0]
        check_half(emission[1], original[1])
    for box in ['collision_box', 'selection_box', 'sticker_box']:
        for a, b in zip(unit[box], source[box]):
            check_half(a, b)
    resistance = {r['type']: r for r in unit['resistances']}
    assert resistance.pop('laser') == {'type': 'laser', 'percent': laser, 'decrease': 0}
    assert resistance == {r['type']: r for r in source['resistances'] if r['type'] != 'laser'}
    loot = {x['name']: x for x in unit['loot']}
    assert set(loot) == {'quinityn-salvage', data[0]}
    for item, bounds in [('quinityn-salvage', salvage), (data[0], data[1:])]:
        assert (loot[item]['amount_min'], loot[item]['amount_max']) == tuple(bounds)
        assert loot[item]['independent_probability'] == 1
    graphics = unit['graphics_set']
    assert 'spidertron-body.png' in graphics['animation']['layers'][0]['filename']
    body_tints.append(graphics['animation']['layers'][1]['tint'])
    assert 'eye_light' not in graphics and 'light_positions' not in graphics
    sensors = graphics['animation']['layers'][-1]
    assert sensors['filename'] == '__yuoki-quinityn__/graphics/stomp-a-tron-sensors.png'
    assert sensors['direction_count'] == 64 and sensors['draw_as_glow']
    assert sensors['scale'] == graphics['animation']['layers'][0]['scale']
    assert sensors['shift'] == graphics['animation']['layers'][0]['shift']
    assert 'tint' not in sensors and not sensors.get('apply_runtime_tint')
    assert len(unit['spider_engine']['legs']) == 5
    corpse, original_corpse = D['corpse'][unit['corpse']], D['corpse'][source['corpse']]
    for field in ['animation', 'decay_animation', 'water_reflection']:
        sprites = [x for x in walk(corpse[field]) if 'scale' in x and ('filename' in x or 'filenames' in x)]
        originals = [x for x in walk(original_corpse[field]) if 'scale' in x and ('filename' in x or 'filenames' in x)]
        assert sprites and len(sprites) == len(originals)
        assert all(abs(a['scale']-b['scale']*.5) < 1e-8 for a,b in zip(sprites, originals))
        if field != 'water_reflection':
            assert all('tint' in sprite for sprite in sprites)
    for mount, original in zip(unit['spider_engine']['legs'], source['spider_engine']['legs']):
        check_half(mount['mount_position'], original['mount_position'])
        check_half(mount['ground_position'], original['ground_position'])
        areas = [x['radius'] for x in walk(mount) if x.get('type') == 'area']
        native = [x['radius'] for x in walk(original) if x.get('type') == 'area']
        assert areas == [r*.5 for r in native]
        leg = D['spider-leg'][mount['leg']]
        original_leg = D['spider-leg'][original['leg']]
        assert leg['resistances'] == unit['resistances']
        for key in ['upper_part', 'lower_part', 'joint', 'foot', 'joint_shadow', 'foot_shadow']:
            sprites = [x for x in walk(leg['graphics_set'][key]) if 'scale' in x and ('filename' in x or 'filenames' in x)]
            originals = [x for x in walk(original_leg['graphics_set'][key]) if 'scale' in x and ('filename' in x or 'filenames' in x)]
            assert sprites and len(sprites) == len(originals)
            assert all(abs(a['scale']-b['scale']*.5) < 1e-8 for a,b in zip(sprites, originals))

    # Follow actual referenced attack/death/leg/remains entities, including
    # nested projectile, fire, sticker and particle effects, not just the unit.
    entities = {n: value for kind in D.values() if isinstance(kind, dict) for n, value in kind.items()
                if isinstance(value, dict) and 'type' in value}
    pending = [name]; seen = set()
    reference_keys = {'entity_name', 'projectile', 'stream', 'sticker', 'smoke_name',
                      'particle_name', 'corpse', 'dying_explosion', 'leg'}
    while pending:
        current = pending.pop()
        if current in seen: continue
        seen.add(current)
        prototype = entities[current]
        for node in walk(prototype):
            for key, value in node.items():
                if isinstance(value, str):
                    if not value.startswith('__'):
                        assert 'wriggler' not in value and 'pentapod-egg' not in value and 'gleba-spawner' not in value, (current, key, value)
                    if key in reference_keys and value in entities: pending.append(value)

assert len({str(tint) for tint in body_tints}) == 3
for kind in ['biter', 'spitter']:
    results = dict(D['unit-spawner']['quinityn-' + kind + '-spawner']['result_units'])
    for size, name in zip(sizes, names):
        curve = results[name]; ordinary = results['quinityn-' + size + '-' + kind]
        for i in range(1001):
            evolution = i/1000
            w, native = weight(curve, evolution), weight(ordinary, evolution)
            assert abs(w - native*.1) < 1e-9
            assert (w == 0 and native == 0) or 0 < w < native
    assert weight(results[names[2]], 0) == 0
for name, nest in D['unit-spawner'].items():
    if name not in ['quinityn-biter-spawner', 'quinityn-spitter-spawner']:
        assert not any(result[0] in names for result in nest['result_units']), name
for name, planet in D['planet'].items():
    if name != 'quinityn':
        assert planet.get('surface_properties', {}).get('quinityn-industry', 0) != 1
print('PASS: half-size hybrids, loot, laser resistance, isolated evolution curves and no egg/wriggler effect graph')
