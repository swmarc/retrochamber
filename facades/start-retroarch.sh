#!/bin/bash

set -eu -o pipefail

CWD_RETROARCH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_RETROARCH=$(basename "${BASH_SOURCE[0]}" .sh)
exec > >(tee "${CWD_RETROARCH}/../logs/${SCRIPT_RETROARCH}.log") 2>&1

source "${CWD_RETROARCH}/../lib/options.sh"
source "${CWD_RETROARCH}/../lib/paths.sh"
source "${CWD_RETROARCH}/../lib/print.sh"

export PRINT_DEBUG=1

declare -a OPTIONS_REQUIRED
OPTIONS_REQUIRED=(
  -core
  -rom
)

OPTIONS_DIFF=$(
  comm -23 \
  <(printf '%s\n' "${OPTIONS_REQUIRED[@]}" | sort) \
  <(printf '%s\n' "${!OPTIONS[@]}" | sort)
)
if [ -n "${OPTIONS_DIFF[*]}" ]; then
  OPTIONS_JOINED=$(echo "${OPTIONS_DIFF[@]}" | tr '\n' ',')
  retrochamber.lib.print.fail "${SCRIPT_RETROARCH}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

CORE=$(retrochamber.lib.options.get "-core")
ROM_PATH="$(retrochamber.lib.paths.unescape "$(retrochamber.lib.options.get "-rom")")"
COMMAND=("${CWD_RETROARCH}/../binaries/retroarch.AppImage")
COMMAND+=(" -c \"${CWD_RETROARCH}/../.retroarch/retroarch.cfg\"")
COMMAND+=(" --verbose")
COMMAND+=(" --log-file \"${CWD_RETROARCH}/../logs/retroarch.log\"")
COMMAND+=(" --fullscreen")
COMMAND+=(" -L \"${CORE}\"")
COMMAND+=(" \"${ROM_PATH}\"")

retrochamber.lib.print.info "${SCRIPT_RETROARCH}" "Starting RetroArch core '$(echo "${CORE}" | rev | cut -d. -f2- | rev)'."
retrochamber.lib.print.debug "${SCRIPT_RETROARCH}" "Command: ${COMMAND[*]}"
echo "Command: ${COMMAND[*]}"
# shellcheck disable=2294
eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_RETROARCH}" "RetroArch emulation has stopped."
