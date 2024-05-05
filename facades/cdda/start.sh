#!/bin/bash

set -eu -o pipefail

CWD_CDDA="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_CDDA=$(basename "${0}" .sh)
exec > >(tee "${CWD_CDDA}/../../logs/cdda-${SCRIPT_CDDA}.log") 2>&1
TMP_DIR=$(TMPDIR=/dev/shm mktemp -d)
INPUT_PIPE="${TMP_DIR}/input"

source "${CWD_CDDA}/../../lib/options.sh"
source "${CWD_CDDA}/../../lib/print.sh"

cleanup () {
  rm -rf "${INPUT_PIPE:?}"
}
trap cleanup EXIT
trap cleanup SIGINT

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
  retrochamber.lib.print.fail "${SCRIPT_CDDA}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

ROM=$(retrochamber.lib.options.get "-rom")
retrochamber.lib.options.remove "-rom"

retrochamber.lib.print.info "${SCRIPT_CDDA}" "Starting CDDA in playing mode."
retrochamber.lib.print.debug "${SCRIPT_CDDA}" "Command: ${COMMAND[*]}"

ROM_PATH=$(dirname "${ROM}")
mkfifo "${INPUT_PIPE}"
cat "${ROM_PATH}"/*.bin > "${INPUT_PIPE}" &

sox -t raw -r 44100 -e signed -b 16 -c 2 "${INPUT_PIPE}" -t wav - | \
  ffplay -fs -autoexit -hide_banner -ac 2 -ar 44100 -f wav -

retrochamber.lib.print.info "${SCRIPT_CDDA}" "CDDA emulation has stopped."
