#!/bin/bash

set -eu -o pipefail

LIB_PATHS=$(basename "${BASH_SOURCE[0]}" .sh)

retrochamber.lib.paths.escape () {
  local VALUE=${1:-}

  if [ -z "${VALUE}" ]; then
    echo "[${LIB_PATHS}] [+++] <$(date -u --rfc-3339=seconds)> Path value is empty."
    exit 1
  fi

  printf '%q' "${VALUE}"
}

retrochamber.lib.paths.unescape () {
  local VALUE=${1:-}

  if [ -z "${VALUE}" ]; then
    echo "[${LIB_PATHS}] [+++] <$(date -u --rfc-3339=seconds)> Path value is empty."
    exit 1
  fi

  # shellcheck disable=1003
  echo "${VALUE}" | tr -d '\\'
}
