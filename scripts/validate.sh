#!/usr/bin/env bash
set -euo pipefail

# Validate all packs and check for cross-pack conflicts (duplicate names, ID prefixes)
# Requires: me, yq (mikefarah/yq)

PACKS_DIR="${1:-packs}"
RESULTS=$(mktemp)
trap 'rm -f "$RESULTS"' EXIT

# 1. Validate each pack, collect YAML results
failed=0
for f in "$PACKS_DIR"/*.yaml "$PACKS_DIR"/*.yml; do
  [ -f "$f" ] || continue
  if ! me pack validate --yaml "$f" >> "$RESULTS"; then
    failed=1
  fi
done

if [ ! -s "$RESULTS" ]; then
  echo "No pack files found in $PACKS_DIR"
  exit 1
fi

if [ "$failed" -ne 0 ]; then
  echo "FAIL: One or more packs failed validation"
  cat "$RESULTS"
  exit 1
fi

# 2. Check for duplicate pack names
dupes=$(yq ea '[.name] | group_by(.) | map(select(length > 1)) | length' "$RESULTS")
if [ "$dupes" != "0" ]; then
  echo "FAIL: Duplicate pack names:"
  yq ea '[.name] | group_by(.) | .[] | select(length > 1)' "$RESULTS"
  exit 1
fi

# 3. Check for duplicate ID prefixes
dupes=$(yq ea '[.id_prefix] | group_by(.) | map(select(length > 1)) | length' "$RESULTS")
if [ "$dupes" != "0" ]; then
  echo "FAIL: Duplicate ID prefix reservations:"
  yq ea '[.id_prefix] | group_by(.) | .[] | select(length > 1)' "$RESULTS"
  exit 1
fi

count=$(yq ea '[.name] | length' "$RESULTS")
echo "OK: $count pack(s) validated, no conflicts"
