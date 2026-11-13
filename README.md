# Git Revenge packages

Signed apt and dnf repositories for [Git Revenge](https://gitrevenge.com/), served at
<https://packages.gitrevenge.com>.

## Ubuntu 24.04+ and Debian 13+ (apt)

```sh
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSLo /etc/apt/keyrings/gitrevenge.asc https://packages.gitrevenge.com/gitrevenge.asc
sudo tee /etc/apt/sources.list.d/gitrevenge.sources >/dev/null <<'EOF'
Types: deb
URIs: https://packages.gitrevenge.com/apt
Suites: stable
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/gitrevenge.asc
EOF
sudo apt update && sudo apt install gitrevenge
```

## RHEL, AlmaLinux and Rocky Linux 9 and 10 (dnf)

On 10, enable EPEL first (`sudo dnf install epel-release`), because WebKitGTK 4.1 comes from
there.

```sh
sudo curl -fsSLo /etc/yum.repos.d/gitrevenge.repo \
  "https://packages.gitrevenge.com/rpm/gitrevenge-el$(rpm -E %rhel).repo"
sudo dnf install gitrevenge
```

dnf asks you to accept the key the first time. Check that its fingerprint is
`03A4 C486 592C CA4D A332  B396 1221 F135 7F3C 5ECA`.

Upgrades then come with `apt upgrade` or `dnf upgrade`.

## How it works

The repositories follow the stable releases of
[Git-Revenge/GitRevenge](https://github.com/Git-Revenge/GitRevenge/releases) and keep the
newest three. Release candidates are not published here. The `Publish` workflow checks for
a new release every six hours. It downloads the `.deb` and `.rpm` assets, checks them against
the sha256 digests GitHub recorded, signs the RPMs and the repository metadata, installs
from the result on Ubuntu 24.04, Debian 13, AlmaLinux 9 and AlmaLinux 10, and only then
deploys to GitHub Pages. No package files are committed to this repository.

The signing key's private half is the `GPG_PRIVATE_KEY` Actions secret. Its public half is
[`gitrevenge.asc`](gitrevenge.asc).
