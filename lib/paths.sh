#!/bin/bash

set -eu -o pipefail

CWD_LIB_PATHS="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
LIB_PATHS=$(basename "${BASH_SOURCE[0]}" .sh)

source "${CWD_LIB_PATHS}/print.sh"

retrochamber.lib.paths.escape () {
  local VALUE=${1:-}

  if [ -z "${VALUE}" ]; then
    retrochamber.lib.print.fail "${LIB_PATHS}" "Path value is empty."
    exit 1
  fi

  printf '%q' "${VALUE}"
}

retrochamber.lib.paths.unescape () {
  local VALUE=${1:-}

  if [ -z "${VALUE}" ]; then
    retrochamber.lib.print.fail "${LIB_PATHS}" "Path value is empty."
    exit 1
  fi

  # shellcheck disable=1003
  echo "${VALUE}" | tr -d '\\'
}
