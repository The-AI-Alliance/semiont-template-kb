#!/usr/bin/env bash
#
# Guard: the template must stay a fixed set of scaffolding files.
#
# Running the stack in a working tree writes runtime artifacts — per-resource
# event streams under .semiont/events/, demo output, e2e seeds — which can then
# get committed by accident (this has happened). This check rejects any tracked
# file not in .template-allowlist, and flags any allowlisted file that has gone
# missing. It is deliberately a whitelist: it fails on cruft shapes nobody has
# seen yet, not only the known ones.
#
# When you intentionally add, remove, or rename a tracked file, regenerate the
# manifest in the same change:
#
#     git ls-files | LC_ALL=C sort > .template-allowlist
#
# Removed from forks by .github/workflows/template-init.yml — forks deliberately
# outgrow the template's frozen file set (corpus, events, generated resources).

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if [ ! -f .template-allowlist ]; then
  echo "✗ .template-allowlist not found at repo root" >&2
  exit 1
fi

actual="$(git ls-files | LC_ALL=C sort)"
allowed="$(LC_ALL=C sort .template-allowlist)"

if [ "$actual" = "$allowed" ]; then
  echo "✓ tracked tree matches .template-allowlist ($(printf '%s\n' "$actual" | wc -l | tr -d ' ') files)"
  exit 0
fi

echo "✗ tracked tree has drifted from .template-allowlist:" >&2
echo >&2
diff <(printf '%s\n' "$allowed") <(printf '%s\n' "$actual") >&2 || true
echo >&2
echo "  '<' = in allowlist but not tracked (deleted scaffolding?)" >&2
echo "  '>' = tracked but not in allowlist (runtime/test cruft?)" >&2
echo >&2
echo "  If the change is intentional, regenerate the manifest and commit it:" >&2
echo "      git ls-files | LC_ALL=C sort > .template-allowlist" >&2
exit 1
