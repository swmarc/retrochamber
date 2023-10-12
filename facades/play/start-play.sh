#!/bin/bash

set -eu -o pipefail

CWD_PS2="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_PS2=$(basename "${BASH_SOURCE[0]}" .sh)
exec > >(tee "${CWD_PS2}/../../logs/play-${SCRIPT_PS2}.log") 2>&1

source "${CWD_PS2}/../../lib/options.sh"
source "${CWD_PS2}/../../lib/paths.sh"
source "${CWD_PS2}/../../lib/print.sh"

declare -a OPTIONS_REQUIRED
OPTIONS_REQUIRED=(
  -fullscreen
  -rom
)

OPTIONS_DIFF=$(
  comm -23 \
  <(printf '%s\n' "${OPTIONS_REQUIRED[@]}" | sort) \
  <(printf '%s\n' "${!OPTIONS[@]}" | sort)
)
if [ -n "${OPTIONS_DIFF[*]}" ]; then
  OPTIONS_JOINED=$(echo "${OPTIONS_DIFF[@]}" | tr '\n' ',')
  retrochamber.lib.print.fail "${SCRIPT_PS2}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

ROM=$(retrochamber.lib.options.get "-rom")
retrochamber.lib.options.remove "-rom"
retrochamber.lib.options.remove "-fullscreen"

COMMAND=("${CWD_PS2}/../../binaries/play.AppImage")
COMMAND+=(" --fullscreen")
# Play! does not acept quoted ROM path.
COMMAND+=(" --disc \"${ROM}\"")

retrochamber.lib.print.info "${SCRIPT_PS2}" "Starting Play! in playing mode."
retrochamber.lib.print.debug "${SCRIPT_PS2}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_PS2}" "Play! emulation has stopped."
