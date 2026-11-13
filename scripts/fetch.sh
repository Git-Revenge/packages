#!/usr/bin/env bash
# fetch.sh RELEASES_JSON NAME_REGEX DEST
# Downloads every asset in RELEASES_JSON whose name matches NAME_REGEX into DEST and checks
# it against the sha256 digest GitHub recorded for it. Fails if a digest is missing.
set -euo pipefail
releases=$1 pattern=$2 dest=$3
mkdir -p "$dest"
found=0
while IFS=$'\t' read -r name url digest; do
  case "$digest" in
    sha256:*) ;;
    *) echo "::error::$name has no sha256 digest"; exit 1 ;;
  esac
  curl -fsSL --retry 3 -o "$dest/$name" "$url"
  echo "${digest#sha256:}  $dest/$name" | sha256sum -c -
  found=$((found + 1))
done < <(jq -r --arg p "$pattern" \
  '.[].assets[] | select(.name | test($p)) | [.name, .url, (.digest // "")] | @tsv' "$releases")
if [ "$found" -eq 0 ]; then echo "::error::No asset matches $pattern"; exit 1; fi
