#!/bin/bash

set -eu -o pipefail

CWD_LINAPPLE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_LINAPPLE=$(basename "${0}" .sh)
exec > >(tee "${CWD_LINAPPLE}/../../logs/linapple-${SCRIPT_LINAPPLE}.log") 2>&1

source "${CWD_LINAPPLE}/../../lib/options.sh"
source "${CWD_LINAPPLE}/../../lib/print.sh"

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
  retrochamber.lib.print.fail "${SCRIPT_LINAPPLE}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

ROM=$(retrochamber.lib.options.get "-rom")
retrochamber.lib.options.remove "-rom"

COMMAND=("${CWD_LINAPPLE}/../../binaries/linapple.AppImage")
COMMAND+=(" --conf ${CWD_LINAPPLE}/../../.config/linapple/linapple.conf")
COMMAND+=(" -f")
COMMAND+=(" --autoboot")
COMMAND+=(" --d1 \"${ROM}\"")

retrochamber.lib.print.info "${SCRIPT_LINAPPLE}" "Starting LinApple playing mode."
retrochamber.lib.print.debug "${SCRIPT_LINAPPLE}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_LINAPPLE}" "LinApple emulation has stopped."
