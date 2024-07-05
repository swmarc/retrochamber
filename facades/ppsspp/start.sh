#!/bin/bash

set -eu -o pipefail

CWD_PPSSPP="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_PPSSPP=$(basename "${0}" .sh)
exec > >(tee "${CWD_PPSSPP}/../../logs/PPSSPP-${SCRIPT_PPSSPP}.log") 2>&1

source "${CWD_PPSSPP}/../../lib/options.sh"
source "${CWD_PPSSPP}/../../lib/print.sh"

declare -a OPTIONS_REQUIRED
OPTIONS_REQUIRED=(
  -rom
)

OPTIONS_DIFF=$(
  comm -23 \
  <(printf '%s\n' "${OPTIONS_REQUIRED[@]}" | sort) \
  <(printf '%s\n' "${!OPTIONS[@]}" | sort)
)
if [ -n "${OPTIONS_DIFF[*]}" ]; then
  OPTIONS_JOINED=$(echo "${OPTIONS_DIFF[@]}" | tr '\n' ',')
  retrochamber.lib.print.fail "${SCRIPT_PPSSPP}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

ROM=$(retrochamber.lib.options.get "-rom")
retrochamber.lib.options.remove "-rom"

COMMAND=("${CWD_PPSSPP}/../../binaries/ppsspp.AppImage")
COMMAND+=(" --fullscreen")
COMMAND+=(" --pause-menu-exit")
COMMAND+=(" -- \"${ROM}\"")

HOME_CONFIG="${CWD_PPSSPP}/../../.config/ppsspp"
mkdir -p "${HOME_CONFIG}"

retrochamber.lib.print.info "${SCRIPT_PPSSPP}" "Starting PPSSPP in playing mode."
retrochamber.lib.print.debug "${SCRIPT_PPSSPP}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
HOME="${HOME_CONFIG}" eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_PPSSPP}" "PPSSPP emulation has stopped."
