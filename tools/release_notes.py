#!/usr/bin/env python3
"""Finalize manually authored pending notes; never generate gameplay prose from commits."""
import argparse
from datetime import date
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEPARATOR = '-' * 99 + '\n'
PENDING = SEPARATOR + 'Version: Unreleased\n'


def split_pending(changelog):
    if not changelog.startswith(PENDING):
        return None, changelog
    body, separator, history = changelog[len(PENDING):].partition(SEPARATOR)
    if any(line.startswith('Date: ') for line in body.splitlines()):
        raise ValueError('Unreleased notes must not have a date; automation assigns it')
    return body, separator + history


def next_patch(version):
    major, minor, patch = map(int, version.split('.'))
    if patch >= 65535:
        raise ValueError('Upcoming patch would exceed Factorio version limits')
    return f'{major}.{minor}.{patch + 1}'


def render(changelog, version, release_date=None, nightly=False):
    body, history = split_pending(changelog)
    header = SEPARATOR + f'Version: {version}\n'
    if body is None and history.startswith(header) and not nightly:
        return history  # Already finalized: preserve its date and notes on retries.
    if release_date is not None:
        header += f'Date: {date.fromisoformat(release_date).isoformat()}\n'
    if nightly:
        header += '  Info:\n    - Development snapshot; see its GitHub release for build details.\n'
    elif not body or not body.strip():
        header += '  Info:\n    - No player-facing changes.\n'
    return header + (body or '') + history


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--date', required=True, help='Release preparation date in UTC (YYYY-MM-DD)')
    args = parser.parse_args()
    # Import here to share the strict archive grammar without a module import cycle.
    from validate_package import validate_changelog
    version = json.loads((ROOT / 'info.json').read_text())['version']
    path = ROOT / 'changelog.txt'
    result = render(path.read_text(), version, args.date)
    validate_changelog(result, version)
    path.write_text(result)
