#!/bin/bash

set -eu -o pipefail

CWD_DUCKSTATION="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_DUCKSTATION=$(basename "${0}" .sh)
exec > >(tee "${CWD_DUCKSTATION}/../../logs/duckstation-${SCRIPT_DUCKSTATION}.log") 2>&1

source "${CWD_DUCKSTATION}/../../lib/options.sh"
source "${CWD_DUCKSTATION}/../../lib/print.sh"

declare -a OPTIONS_REQUIRED
OPTIONS_REQUIRED=(
  -setupwizard
)

OPTIONS_DIFF=$(
  comm -23 \
  <(printf '%s\n' "${OPTIONS_REQUIRED[@]}" | sort) \
  <(printf '%s\n' "${!OPTIONS[@]}" | sort)
)
if [ -n "${OPTIONS_DIFF[*]}" ]; then
  OPTIONS_JOINED=$(echo "${OPTIONS_DIFF[@]}" | tr '\n' ',')
  retrochamber.lib.print.fail "${SCRIPT_DUCKSTATION}" "Missing option(s) ${OPTIONS_JOINED%,}."
  exit 1
fi

COMMAND=("${CWD_DUCKSTATION}/../../binaries/duckstation.AppImage")
for OPTION_KEY in "${!OPTIONS[@]}"; do
  COMMAND+=("${OPTION_KEY}" "${OPTIONS[${OPTION_KEY}]}")
done

HOME_CONFIG="${CWD_DUCKSTATION}/../../.config/duckstation"
mkdir -p "${HOME_CONFIG}"

retrochamber.lib.print.info "${SCRIPT_DUCKSTATION}" "Starting DuckStation in setup mode."
retrochamber.lib.print.debug "${SCRIPT_DUCKSTATION}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
HOME="${HOME_CONFIG}" eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_DUCKSTATION}" "DuckStation emulation has stopped."
