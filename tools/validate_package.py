#!/usr/bin/env python3
"""Validate addon metadata and the distributable ZIP without loading Factorio."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import zipfile
from package import development_files
from release_notes import split_pending

ROOT = Path(__file__).resolve().parents[1]


def version_tuple(value):
    if not re.fullmatch(r'(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)', value):
        raise ValueError(f'Invalid Factorio version: {value!r}')
    result = tuple(map(int, value.split('.')))
    if result == (0, 0, 0) or max(result) > 65535:
        raise ValueError(f'Factorio version out of range: {value}')
    return result


def validate_changelog(text, version):
    """Validate Factorio's line grammar, section ordering and current version."""
    versions = []
    category = None
    entry = False
    date_seen = False
    entries = set()
    lines = text.splitlines()
    for index, line in enumerate(lines):
        if '\t' in line or line != line.rstrip():
            raise ValueError(f'changelog.txt:{index + 1}: tabs or trailing whitespace')
        if not line:
            continue
        if line == '-' * 99:
            if index + 1 >= len(lines) or not lines[index + 1].startswith('Version: '):
                raise ValueError('Changelog separator must immediately precede Version')
            category = None
            entry = date_seen = False
            entries = set()
        elif line.startswith('Version: '):
            if index == 0 or lines[index - 1] != '-' * 99:
                raise ValueError('Changelog version needs a 99-dash separator')
            current = version_tuple(line[9:])
            if versions and current >= versions[-1]:
                raise ValueError('Changelog versions must be unique and newest first')
            versions.append(current)
        elif not versions:
            raise ValueError('Changelog content before first version')
        elif line.startswith('Date: '):
            if date_seen:
                raise ValueError('Duplicate changelog date')
            date_seen = True
        elif re.fullmatch(r'  [^ ].*:', line):
            category = line[2:-1]
            entry = False
        elif line.startswith('    - ') or line.startswith('      '):
            continuation = not line.startswith('    - ')
            if not category or (continuation and not entry):
                raise ValueError('Changelog entry needs a category and continuation needs an entry')
            key = (category, line[6:])
            if key in entries:
                raise ValueError('Duplicate changelog entry line')
            entries.add(key)
            entry = True
        else:
            raise ValueError(f'changelog.txt:{index + 1}: unrecognized line')
    if not versions or versions[0] != version_tuple(version):
        raise ValueError(f'changelog.txt needs a top section for {version}')


def validate(output, nightly=False, tag=None):
    info = json.loads((ROOT / 'info.json').read_text())
    version_tuple(info['version'])
    manifest = json.loads((ROOT / '.github/release-please-manifest.json').read_text())
    if manifest['.'] != info['version'] or (ROOT / '.github/version.txt').read_text().strip() != info['version']:
        raise ValueError('Release manifest, version.txt and info.json versions must match')
    changelog = (ROOT / 'changelog.txt').read_text()
    pending, history = split_pending(changelog)
    validate_changelog(history, info['version'])
    if tag is not None and pending is not None:
        raise ValueError('Stable releases must finalize Unreleased notes before tagging')
    overrides = development_files(info, changelog, nightly)
    if overrides:
        info = json.loads(overrides['info.json'])
    if tag is not None and (nightly or tag != 'v' + info['version']):
        raise ValueError('Stable tag must match info.json exactly')
    for key in ('name', 'version', 'title', 'author', 'factorio_version'):
        if not isinstance(info.get(key), str) or not info[key].strip():
            raise ValueError(f'info.json: {key} must be a nonempty string')
    for key, pattern in [('name', r'[A-Za-z0-9_-]+'),
                         ('version', r'\d+\.\d+\.\d+'),
                         ('factorio_version', r'\d+\.\d+')]:
        if not re.fullmatch(pattern, info[key]):
            raise ValueError(f'info.json: invalid {key}: {info[key]!r}')
    dependencies = info.get('dependencies')
    if not isinstance(dependencies, list) or not dependencies or not all(
        isinstance(value, str) and value.strip() for value in dependencies
    ):
        raise ValueError('info.json: dependencies must be a nonempty list of strings')
    if not isinstance(info.get('space_travel_required'), bool):
        raise ValueError('info.json: space_travel_required must be a boolean')

    name = f'{info["name"]}_{info["version"]}'
    archive = output / f'{name}.zip'
    tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
    # The release contract excludes developer files and hidden/generated content.
    expected = {
        file for file in tracked if file
        and Path(file).parts[0] not in {'tests', 'tools', 'docs', 'AGENTS.md', 'CONTRIBUTING.md'}
        and not any(part.startswith('.') or part in {'build', '__pycache__'} for part in Path(file).parts)
    }
    required = {'info.json', 'changelog.txt', 'data.lua', 'control.lua', 'LICENSE', 'NOTICE', 'graphics/README.md'}
    if not required <= expected:
        raise ValueError(f'Missing required release sources: {sorted(required - expected)}')
    with zipfile.ZipFile(archive) as package:
        names = package.namelist()
        if len(names) != len(set(names)) or set(names) != {f'{name}/{file}' for file in expected}:
            raise ValueError('ZIP entries differ from the expected tracked release files')
        if package.testzip() is not None:
            raise ValueError('ZIP failed its CRC check')
        for file in expected:
            if package.read(f'{name}/{file}') != overrides.get(file, (ROOT / file).read_bytes()):
                raise ValueError(f'ZIP content differs from source: {file}')
        validate_changelog(package.read(f'{name}/changelog.txt').decode(), info['version'])
    checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
    if (output / 'SHA256SUMS').read_text() != f'{checksum}  {archive.name}\n':
        raise ValueError('SHA256SUMS does not match the addon ZIP')
    print(f'PASS metadata, {len(expected)} packaged files, notices and checksum')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=ROOT / 'build/dist')
    parser.add_argument('--nightly', action='store_true')
    parser.add_argument('--tag', help='Expected stable release tag')
    args = parser.parse_args()
    validate(args.output, args.nightly, args.tag)
