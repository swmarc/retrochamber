#!/bin/bash

set -eu -o pipefail

CWD_PS2="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_PS2=$(basename "${BASH_SOURCE[0]}" .sh)
exec > >(tee "${CWD_PS2}/../../logs/pcsx2-${SCRIPT_PS2}.log") 2>&1

source "${CWD_PS2}/../../lib/options.sh"
source "${CWD_PS2}/../../lib/print.sh"

declare -a OPTIONS_REQUIRED
OPTIONS_REQUIRED=(-setupwizard)

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

COMMAND=("${CWD_PS2}/../../binaries/pcsx2.AppImage")
for OPTION_KEY in "${!OPTIONS[@]}"; do
  COMMAND+=("${OPTION_KEY}" "${OPTIONS[${OPTION_KEY}]}")
done

HOME_CONFIG="${CWD_PS2}/../../.config/pcsx2"
mkdir -p "${HOME_CONFIG}"

retrochamber.lib.print.info "${SCRIPT_PS2}" "Starting PCSX2 in setup mode."
retrochamber.lib.print.debug "${SCRIPT_PS2}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
HOME="${HOME_CONFIG}" eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_PS2}" "PCSX2 emulation has stopped."
