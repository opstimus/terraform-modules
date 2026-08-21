#!/usr/bin/env bash
# Regenerates the "Module Versions" table in README.md from git tags.
# Usage: scripts/generate-versions-table.sh
# Tags follow <module>/vX.Y.Z (see .github/workflows/release.yml). Modules
# under modules/ with no matching tag print as unreleased.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="${REPO_ROOT}/README.md"
START_MARKER="<!-- VERSIONS:START -->"
END_MARKER="<!-- VERSIONS:END -->"

cd "$REPO_ROOT"
git fetch --tags --quiet || true

TABLE=$(
  {
    echo "| Module | Latest Version |"
    echo "|--------|-----------------|"
    for dir in modules/*/; do
      mod=$(basename "$dir")
      latest=$(git tag -l "${mod}/v*" | sed "s#^${mod}/v##" | sort -V | tail -n1)
      if [ -z "$latest" ]; then
        echo "| \`${mod}\` | — (unreleased) |"
      else
        tag="${mod}/v${latest}"
        echo "| \`${mod}\` | [v${latest}](https://github.com/opstimus/terraform-modules/tree/${tag}) |"
      fi
    done
  }
)

awk -v table="$TABLE" -v start="$START_MARKER" -v end="$END_MARKER" '
  { line = $0; sub(/\r$/, "", line) }
  line == start { print; print table; skip=1; next }
  line == end { skip=0 }
  !skip { print }
' "$README" > "${README}.tmp"
mv "${README}.tmp" "$README"
