#!/usr/bin/env bash
# install-test.sh BASE_URL
# Runs inside a clean distro container. Installs Git Revenge with the same commands the
# README gives, pointed at BASE_URL (a local copy of the site) instead of the live URL.
# Signatures are checked exactly as they are for users.
set -euo pipefail
base=$1
live=https://packages.gitrevenge.com

if command -v apt-get >/dev/null; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y -qq curl ca-certificates >/dev/null
  install -d -m 0755 /etc/apt/keyrings
  curl -fsSLo /etc/apt/keyrings/gitrevenge.asc "$base/gitrevenge.asc"
  cat > /etc/apt/sources.list.d/gitrevenge.sources <<EOF
Types: deb
URIs: $base/apt
Suites: stable
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/gitrevenge.asc
EOF
  apt-get update
  apt-get install -y gitrevenge
  dpkg -s gitrevenge | grep '^Version'
else
  el=$(rpm -E %rhel)
  if [ "$el" -ge 10 ]; then dnf install -y epel-release; fi
  curl -fsSLo /etc/yum.repos.d/gitrevenge.repo "$base/rpm/gitrevenge-el$el.repo"
  sed -i "s#$live#$base#g" /etc/yum.repos.d/gitrevenge.repo
  dnf install -y gitrevenge
  rpm -q gitrevenge
  # The package itself must carry a signature the imported key verifies.
  rpm -q --qf '%{RSAHEADER:pgpsig}\n' gitrevenge | tee /dev/stderr | grep -qi 1221f1357f3c5eca
fi
test -x /usr/bin/gitrevenge
