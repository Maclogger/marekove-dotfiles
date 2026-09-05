#!/usr/bin/env bash
#
# Installs the root half of the MX Master 4 scroll-mode toggle:
#
#   /usr/local/bin/mx-scroll-mode   root:root 0755
#   /etc/sudoers.d/mx-scroll-mode   root:root 0440
#
# This package is installed BY COPY, never with stow, unlike mx-master. Both
# files must be real root-owned files:
#
#   * sudo silently ignores anything in /etc/sudoers.d that is not a regular
#     root-owned file, so a stow symlink would quietly kill the NOPASSWD rule;
#   * mx-scroll-mode runs as root under that rule, so pointing it at a file in
#     this user-writable repo would turn the rule into a way to run anything
#     as root.
#
# Re-run this after editing either file here.
set -euo pipefail
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

[[ $EUID -eq 0 ]] || { echo "run this with sudo" >&2; exit 1; }

install -o root -g root -m 0755 \
  "$here/usr/local/bin/mx-scroll-mode" /usr/local/bin/mx-scroll-mode

# Validate before putting it in place — a broken sudoers file locks out sudo.
install -o root -g root -m 0440 \
  "$here/etc/sudoers.d/mx-scroll-mode" /etc/sudoers.d/.mx-scroll-mode.new
if visudo -cf /etc/sudoers.d/.mx-scroll-mode.new; then
  mv -f /etc/sudoers.d/.mx-scroll-mode.new /etc/sudoers.d/mx-scroll-mode
else
  rm -f /etc/sudoers.d/.mx-scroll-mode.new
  echo "sudoers snippet failed validation; nothing installed" >&2
  exit 1
fi

echo
ls -l /usr/local/bin/mx-scroll-mode /etc/sudoers.d/mx-scroll-mode
echo
echo "Current mode: $(/usr/local/bin/mx-scroll-mode status)"
