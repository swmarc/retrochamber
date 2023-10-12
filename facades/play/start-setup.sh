#!/bin/bash

set -eu -o pipefail

CWD_PS2="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_PS2=$(basename "${BASH_SOURCE[0]}" .sh)
exec > >(tee "${CWD_PS2}/../../logs/play-${SCRIPT_PS2}.log") 2>&1

source "${CWD_PS2}/../../lib/options.sh"
source "${CWD_PS2}/../../lib/print.sh"

COMMAND=("${CWD_PS2}/../../binaries/play.AppImage")

retrochamber.lib.print.info "${SCRIPT_PS2}" "Starting Play! in playing mode."
retrochamber.lib.print.debug "${SCRIPT_PS2}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_PS2}" "Play! emulation has stopped."
