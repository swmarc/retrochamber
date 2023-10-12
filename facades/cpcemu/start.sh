#!/bin/bash

set -eu -o pipefail

CWD_CPCEMU="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_CPCEMU=$(basename "${0}" .sh)
exec > >(tee "${CWD_CPCEMU}/../../logs/cpcemu-${SCRIPT_CPCEMU}.log") 2>&1

source "${CWD_CPCEMU}/../../lib/options.sh"
source "${CWD_CPCEMU}/../../lib/print.sh"

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
  retrochamber.lib.print.fail "${SCRIPT_CPCEMU}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

ROM=$(retrochamber.lib.options.get "-rom")
retrochamber.lib.options.remove "-rom"

COMMAND=("${CWD_CPCEMU}/../../binaries/cpcemu.AppImage")
COMMAND+=(" /c ${CWD_CPCEMU}/../../.config/cpcemu.cfg")
COMMAND+=(" \"${ROM}\"")

retrochamber.lib.print.info "${SCRIPT_CPCEMU}" "Starting CPCemu in playing mode."
retrochamber.lib.print.debug "${SCRIPT_CPCEMU}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_CPCEMU}" "CPCemu emulation has stopped."
