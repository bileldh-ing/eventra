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

if command -v lcov >/dev/null 2>&1; then
  lcov --summary coverage/lcov.info || true
else
  python3 - <<'PY'
import re
hit = found = 0
for line in open("coverage/lcov.info"):
    if line.startswith("LH:"): hit += int(line[3:])
    elif line.startswith("LF:"): found += int(line[3:])
print(f"line coverage: {hit}/{found} = {100*hit/max(found,1):.1f}%")
PY
fi
