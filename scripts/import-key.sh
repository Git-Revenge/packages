#!/usr/bin/env bash
# Imports the signing key from $GPG_PRIVATE_KEY and checks that it is the key whose public
# half is committed as gitrevenge.asc (fingerprint $KEY_FINGERPRINT), so a wrong secret
# can never sign a repository that users' keyrings would reject.
set -euo pipefail
if [ -z "${GPG_PRIVATE_KEY:-}" ]; then echo "::error::The GPG_PRIVATE_KEY secret is not set"; exit 1; fi
printf '%s\n' "$GPG_PRIVATE_KEY" | gpg --batch --import
have=$(gpg --list-secret-keys --with-colons | awk -F: '/^fpr/ {print $10; exit}')
want=$(gpg --show-keys --with-colons gitrevenge.asc | awk -F: '/^fpr/ {print $10; exit}')
if [ "$have" != "$KEY_FINGERPRINT" ] || [ "$want" != "$KEY_FINGERPRINT" ]; then
  echo "::error::Secret key $have, gitrevenge.asc $want, expected $KEY_FINGERPRINT"
  exit 1
fi
