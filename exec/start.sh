#!/bin/bash

set -eu

CWD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
# SCRIPT=$(basename "${BASH_SOURCE[0]}" .sh)
# exec > >(tee "${CWD}/logs/${SCRIPT}.log") 2>&1

source "${CWD}/../lib/banner.sh"
source "${CWD}/../lib/dependency/ubuntu.sh"
source "${CWD}/../lib/print.sh"

reset
retrochamber.lib.banner.print

if [[ " $(cat /proc/version) " =~ " Ubuntu " ]]; then
  retrochamber.lib.depedency.ubuntu.check_install
fi

if [ ! -f "${CWD}/SETUP" ]; then
  retrochamber.lib.print.success "RetroChamber" "Initializing first run."
  retrochamber.lib.print.success "RetroChamber" "This will take a short while."

  bash "${CWD}/update.sh"
  echo 0 > "${CWD}/SETUP"

  retrochamber.lib.print.success "RetroChamber" "Initializing finished."
fi

retrochamber.lib.print.success "RetroChamber" "Starting RetroChamber"
sleep 1

"${CWD}/../binaries/emulationstation-de.AppImage" \
  --home "${CWD}/../"
