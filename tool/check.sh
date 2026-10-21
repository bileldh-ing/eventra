#!/usr/bin/env bash
# Single quality gate: format check, static analysis, tests with coverage.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> dart format (check)"
dart format --output=none --set-exit-if-changed lib test

echo "==> flutter analyze"
flutter analyze --no-pub

echo "==> flutter test --coverage"
flutter test --no-pub --coverage "$@"

if true; then
  python3 - <<'PY'
import re
# Hand-written code only: generated *.g.dart / *.freezed.dart are excluded.
hit = found = 0
skip = False
for line in open("coverage/lcov.info"):
    if line.startswith("SF:"):
        skip = line.strip().endswith((".g.dart", ".freezed.dart"))
    elif skip:
        continue
    elif line.startswith("LH:"): hit += int(line[3:])
    elif line.startswith("LF:"): found += int(line[3:])
print(f"line coverage (excluding generated): {hit}/{found} = {100*hit/max(found,1):.1f}%")
PY
fi
