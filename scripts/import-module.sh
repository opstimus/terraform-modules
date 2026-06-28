#!/usr/bin/env bash
# Import a source repo into modules/<key>/ with history + prefixed tags.
# Usage (from monorepo root): import-module.sh <repo-name> <key>
#   e.g. import-module.sh terraform-aws-vpc aws-vpc
# Requires: git-filter-repo, push-capable SSH key, a clean working tree.
#
# SSH key: override with GIT_SSH_COMMAND (or SSH_KEY) if your key differs from
# the default below.
set -euo pipefail

REPO="${1:?repo name required}"
KEY="${2:?module key required, e.g. aws-vpc}"
ORG="opstimus"
WORK="$(mktemp -d)"
CLONE="${WORK}/${REPO}"
SSH_KEY="${SSH_KEY:-${HOME}/.ssh/id_rsa_op_gh}"
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -i ${SSH_KEY} -o IdentitiesOnly=yes}"

echo ">> Pre-import safety check"
git clone "git@github.com:${ORG}/${REPO}.git" "${CLONE}"
"$(dirname "$0")/preimport-check.sh" "${REPO}" "${CLONE}"

echo ">> Rewriting history into modules/${KEY}"
# Pass 1: drop per-module meta that lives at the monorepo root.
git -C "${CLONE}" filter-repo --invert-paths --path .github --path LICENSE
# Pass 2: move everything into modules/<key> and prefix all tags with <key>/.
git -C "${CLONE}" filter-repo --force \
  --to-subdirectory-filter "modules/${KEY}" \
  --tag-rename ":${KEY}/"

echo ">> Merging into monorepo"
REMOTE="import_$(echo "${KEY}" | tr '/' '_')"
DEFAULT_BRANCH=$(git -C "${CLONE}" symbolic-ref --short HEAD)
git remote add "${REMOTE}" "${CLONE}"
git fetch "${REMOTE}" --tags
git merge --allow-unrelated-histories --no-edit \
  -m "Import ${KEY} module with history" "${REMOTE}/${DEFAULT_BRANCH}"
git remote remove "${REMOTE}"
rm -rf "${WORK}"

echo ">> Done: modules/${KEY}"
git -C . tag -l "${KEY}/v*" | sort -V | tail -n3
