#!/bin/bash

set -eu -o pipefail

CWD_DOLPHIN="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_DOLPHIN=$(basename "${0}" .sh)
exec > >(tee "${CWD_DOLPHIN}/../../logs/dolphin-${SCRIPT_DOLPHIN}.log") 2>&1

source "${CWD_DOLPHIN}/../../lib/options.sh"
source "${CWD_DOLPHIN}/../../lib/print.sh"

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
  retrochamber.lib.print.fail "${SCRIPT_DOLPHIN}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

ROM=$(retrochamber.lib.options.get "-rom")
retrochamber.lib.options.remove "-rom"

COMMAND=("${CWD_DOLPHIN}/../../binaries/dolphin-emu.AppImage")
COMMAND+=(" --user=\"${CWD_DOLPHIN}/../../.config/dolphin-emu\"")
COMMAND+=(" --config=Dolphin:Core:AutoDiscChange=True")
COMMAND+=(" --config=Dolphin:Display:Fullscreen=True")
COMMAND+=(" --config=Dolphin:Interface:ConfirmStop=false")
COMMAND+=(" --batch")
COMMAND+=(" --exec=\"${ROM}\"")

retrochamber.lib.print.info "${SCRIPT_DOLPHIN}" "Starting Dolphin in playing mode."
retrochamber.lib.print.debug "${SCRIPT_DOLPHIN}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_DOLPHIN}" "Dolphin emulation has stopped."
