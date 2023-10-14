#!/bin/bash

set -eu -o pipefail

CWD_FBNEO="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_FBNEO=$(basename "${0}" .sh)
exec > >(tee "${CWD_FBNEO}/../../logs/fbneo-${SCRIPT_FBNEO}.log") 2>&1

source "${CWD_FBNEO}/../../lib/options.sh"
source "${CWD_FBNEO}/../../lib/print.sh"

declare -a OPTIONS_REQUIRED
OPTIONS_REQUIRED=(
  -gamedir
  -rom
)

OPTIONS_DIFF=$(
  comm -23 \
  <(printf '%s\n' "${OPTIONS_REQUIRED[@]}" | sort) \
  <(printf '%s\n' "${!OPTIONS[@]}" | sort)
)
if [ -n "${OPTIONS_DIFF[*]}" ]; then
  OPTIONS_JOINED=$(echo "${OPTIONS_DIFF[@]}" | tr '\n' ',')
  retrochamber.lib.print.fail "${SCRIPT_FBNEO}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

FBNEO_REALPATH=$(realpath "${CWD_FBNEO}/../../binaries/fbneo.AppImage")
ROM=$(retrochamber.lib.options.get "-rom")
GAME_DIR=$(retrochamber.lib.options.get "-gamedir")
retrochamber.lib.options.remove "-rom"
retrochamber.lib.options.remove "-gamedir"

COMMAND=("${FBNEO_REALPATH}")
COMMAND+=(" -fullscreen")
COMMAND+=(" -integerscale")
COMMAND+=(" -joy")
COMMAND+=(" \"${ROM}\"")

retrochamber.lib.print.info "${SCRIPT_FBNEO}" "Starting FinalBurn Neo in playing mode."
retrochamber.lib.print.debug "${SCRIPT_FBNEO}" "Command: ${COMMAND[*]}"
(
  export XDG_HOME_CONFIG="/home/marc/github/retrochamber/.config/fbneo"
  export XDG_HOME_DATA="/home/marc/github/retrochamber/.config/fbneo"
  cd "${GAME_DIR}"
  # shellcheck disable=2294
  eval "${COMMAND[@]}"
)

retrochamber.lib.print.info "${SCRIPT_FBNEO}" "FinalBurn Neo emulation has stopped."
