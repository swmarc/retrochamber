#!/bin/bash

set -eu -o pipefail

CWD_MEDNAFEN_APPLE2="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_MEDNAFEN_APPLE2=$(basename "${0}" .sh)
exec > >(tee "${CWD_MEDNAFEN_APPLE2}/../../logs/mednafen-apple2-${SCRIPT_MEDNAFEN_APPLE2}.log") 2>&1

source "${CWD_MEDNAFEN_APPLE2}/../../lib/options.sh"
source "${CWD_MEDNAFEN_APPLE2}/../../lib/print.sh"

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
  retrochamber.lib.print.fail "${SCRIPT_MEDNAFEN_APPLE2}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

ROM=$(retrochamber.lib.options.get "-rom")
retrochamber.lib.options.remove "-rom"

COMMAND=("MEDNAFEN_HOME=\"${CWD_MEDNAFEN_APPLE2}/../../.config/mednafen\"")
COMMAND+=("${CWD_MEDNAFEN_APPLE2}/../../binaries/mednafen.AppImage")
COMMAND+=(" -filesys.path_firmware \"${CWD_MEDNAFEN_APPLE2}/../../.retroarch/system\"")
COMMAND+=(" -video.fs 1")
COMMAND+=(" \"${ROM}\"")

retrochamber.lib.print.info "${SCRIPT_MEDNAFEN_APPLE2}" "Starting Mednafen (apple2) in playing mode."
retrochamber.lib.print.debug "${SCRIPT_MEDNAFEN_APPLE2}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_MEDNAFEN_APPLE2}" "Mednafen (apple2) emulation has stopped."
