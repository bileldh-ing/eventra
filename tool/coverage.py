#!/usr/bin/env python3
"""Line coverage of hand-written code from one or more lcov files.

usage: tool/coverage.py [--min PCT] [--merge-out FILE] lcov.info [more.info ...]

Generated code (*.g.dart, *.freezed.dart, lib/l10n/gen/) is excluded. Several
lcov files (e.g. one per test file) are merged by taking, per source line,
the highest hit count. Exits 1 when coverage is below --min.
"""
import argparse
import sys
from collections import defaultdict

EXCLUDE_SUFFIX = ('.g.dart', '.freezed.dart')
EXCLUDE_PART = ('lib/l10n/gen/',)


def skipped(path):
    return path.endswith(EXCLUDE_SUFFIX) or any(p in path for p in EXCLUDE_PART)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--min', type=float, default=0)
    ap.add_argument('--merge-out')
    ap.add_argument('--worst', type=int, default=0, help='list N weakest files')
    ap.add_argument('files', nargs='+')
    a = ap.parse_args()
    lines = defaultdict(dict)  # file -> line -> hits
    for f in a.files:
        sf = None
        for raw in open(f):
            raw = raw.strip()
            if raw.startswith('SF:'):
                sf = raw[3:]
                lines[sf]  # files with no DA lines still count
            elif raw.startswith('DA:') and sf:
                ln, hits = raw[3:].split(',')[:2]
                ln, hits = int(ln), int(hits)
                lines[sf][ln] = max(lines[sf].get(ln, 0), hits)
    if a.merge_out:
        with open(a.merge_out, 'w') as out:
            for sf in sorted(lines):
                out.write(f'SF:{sf}\n')
                for ln in sorted(lines[sf]):
                    out.write(f'DA:{ln},{lines[sf][ln]}\n')
                found = len(lines[sf])
                hit = sum(1 for v in lines[sf].values() if v > 0)
                out.write(f'LF:{found}\nLH:{hit}\nend_of_record\n')
    hit = found = 0
    per = []
    for sf, d in lines.items():
        if skipped(sf):
            continue
        h = sum(1 for v in d.values() if v > 0)
        hit += h
        found += len(d)
        if d:
            per.append((h / len(d), h, len(d), sf))
    pct = 100 * hit / max(found, 1)
    print(f'line coverage (excluding generated): {hit}/{found} = {pct:.2f}%')
    for frac, h, n, sf in sorted(per)[: a.worst]:
        print(f'  {100 * frac:5.1f}%  {h:4}/{n:<4} {sf}')
    if pct + 1e-9 < a.min:
        print(f'FAIL: coverage {pct:.2f}% is below the {a.min:.2f}% threshold')
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
