#!/usr/bin/env bash
# Pre-import safety gate. Usage: preimport-check.sh <repo-name> <clone-path>
# Exit 0 = safe to import. Exit 1 = flagged (open PRs or unreleased commits).
# gh is used read-only; clone ops by the caller must use the -op key.
set -euo pipefail

REPO="${1:?repo name required, e.g. terraform-aws-vpc}"
CLONE="${2:?clone path required}"
ORG="opstimus"
FLAGGED=0

# 1. Open PRs
OPEN_PRS=$(gh pr list --repo "${ORG}/${REPO}" --state open --json number --jq 'length')
if [ "${OPEN_PRS}" -gt 0 ]; then
  echo "FLAG ${REPO}: ${OPEN_PRS} open PR(s)"
  FLAGGED=1
fi

# 2. Unreleased commits (HEAD ahead of latest tag, or no tags)
DEFAULT_BRANCH=$(git -C "${CLONE}" symbolic-ref --short HEAD)
if ! LATEST_TAG=$(git -C "${CLONE}" describe --tags --abbrev=0 2>/dev/null); then
  echo "FLAG ${REPO}: no release tags"
  FLAGGED=1
else
  AHEAD=$(git -C "${CLONE}" rev-list "${LATEST_TAG}..${DEFAULT_BRANCH}" --count)
  if [ "${AHEAD}" -gt 0 ]; then
    echo "FLAG ${REPO}: ${AHEAD} unreleased commit(s) after ${LATEST_TAG}"
    FLAGGED=1
  fi
fi

if [ "${FLAGGED}" -eq 0 ]; then
  echo "OK ${REPO}: clean (latest tag ${LATEST_TAG:-none})"
fi
exit "${FLAGGED}"
