#!/usr/bin/env bash
# Single quality gate: format check, static analysis, tests with coverage.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> dart format (check)"
dart format --output=none --set-exit-if-changed lib test

echo "==> flutter gen-l10n (must be committed)"
flutter gen-l10n
git diff --exit-code -- lib/l10n/gen

echo "==> flutter analyze"
flutter analyze --no-pub

echo "==> flutter test --coverage"
flutter test --no-pub --coverage "$@"

python3 tool/coverage.py --min "$(cat tool/coverage_threshold.txt)" coverage/lcov.info
