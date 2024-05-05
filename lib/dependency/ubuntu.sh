#!/bin/bash

set -eu -o pipefail

CWD_LIB_DEPENDENCY_UBUNTU="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
LIB_DEPENDENCY_UBUNTU=$(basename "${BASH_SOURCE[0]}" .sh)

source "${CWD_LIB_DEPENDENCY_UBUNTU}/../dependency.sh"
source "${CWD_LIB_DEPENDENCY_UBUNTU}/../print.sh"

retrochamber.lib.depedency.ubuntu.check_install () {
  declare -A MAPPING
  local MAPPING=(
    ["7z"]="p7zip"
    ["bsdtar"]="bsdtar"
    ["curl"]="curl"
    ["ffmpeg"]="ffmpeg"
    ["jq"]="jq"
    ["pv"]="pv"
    ["rclone"]="rclone"
    ["rsync"]="rsync"
    ["sed"]="sed"
    ["sox"]="sox"
    ["wget"]="wget"
  )
  local INSTALLATION="" LIST_MISSING="" MISSING="" TO_INSTALL=""

  LIST_MISSING=$(retrochamber.lib.depedency.check_commands "${!MAPPING[*]}" 0)
  if [ -n "${LIST_MISSING}" ]; then
    while read -r MISSING; do
      TO_INSTALL+="${MAPPING[$MISSING]} "
    done <<<"${LIST_MISSING[@]}"

    retrochamber.lib.print.info "${LIB_DEPENDENCY_UBUNTU}" "You have missing dependencies required for running RetroChamber."
    retrochamber.lib.print.info "${LIB_DEPENDENCY_UBUNTU}" "Packages missing: $(echo "${TO_INSTALL}" | xargs)."
    retrochamber.lib.print.info "${LIB_DEPENDENCY_UBUNTU}" "Should we install them for you? (y/n)"
    read -r -p "Choice: " INSTALLATION

    if [ "${INSTALLATION}" != "y" ]; then
      echo -en "\033[1A\033[2K"
      retrochamber.lib.print.info "${LIB_DEPENDENCY_UBUNTU}" "Dependencies not met. Exiting in 5s."
      sleep 5
      exit 1
    fi

    sudo apt update && sudo apt install -y "$(echo "${TO_INSTALL}" | xargs)"
  fi
}
