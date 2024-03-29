#!/bin/bash

set -eu -o pipefail

CWD_DOLPHIN="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_DOLPHIN=$(basename "${0}" .sh)
exec > >(tee "${CWD_DOLPHIN}/../../logs/dolphin-${SCRIPT_DOLPHIN}.log") 2>&1

source "${CWD_DOLPHIN}/../../lib/print.sh"

COMMAND=("${CWD_DOLPHIN}/../../binaries/dolphin-emu.AppImage")
COMMAND+=(" --user=\"${CWD_DOLPHIN}/../../.config/dolphin-emu\"")

retrochamber.lib.print.info "${SCRIPT_DOLPHIN}" "Starting Dolphin in setup mode."
retrochamber.lib.print.debug "${SCRIPT_DOLPHIN}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_DOLPHIN}" "Dolphin emulation has stopped."
