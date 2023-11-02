#!/bin/bash

set -eu -o pipefail

CWD_SCUMMVM="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_SCUMMVM=$(basename "${BASH_SOURCE[0]}" .sh)
exec > >(tee "${CWD_SCUMMVM}/../../logs/scummvm-${SCRIPT_SCUMMVM}.log") 2>&1

source "${CWD_SCUMMVM}/../../lib/options.sh"
source "${CWD_SCUMMVM}/../../lib/paths.sh"
source "${CWD_SCUMMVM}/../../lib/print.sh"

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
  retrochamber.lib.print.fail "${SCRIPT_SCUMMVM}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

GAME_PATH=$(retrochamber.lib.paths.unescape "$(retrochamber.lib.options.get "-rom")")
retrochamber.lib.options.remove "-rom"

COMMAND=("${CWD_SCUMMVM}/../../binaries/scummvm.AppImage")
for OPTION_KEY in "${!OPTIONS[@]}"; do
  COMMAND+=("${OPTION_KEY}" "${OPTIONS[${OPTION_KEY}]}")
done
COMMAND+=(" --config=\"${CWD_SCUMMVM}/../../.config/scummvm/scummvm.ini\"")
COMMAND+=(' --fullscreen')
COMMAND+=(' --stretch-mode="pixel-perfect"')
COMMAND+=(" --logfile=\"${CWD_SCUMMVM}/../../logs/scummvm.log\"")
COMMAND+=(" --debuglevel=1")
COMMAND+=(" --path=\"${GAME_PATH}\"")
COMMAND+=(" --savepath=\"${CWD_SCUMMVM}/../../.config/scummvm/saves\"")
COMMAND+=(' --auto-detect')

retrochamber.lib.print.info "${SCRIPT_SCUMMVM}" "Starting ScummVM in playing mode."
retrochamber.lib.print.debug "${SCRIPT_SCUMMVM}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_SCUMMVM}" "ScummVM emulation has stopped."
