#!/bin/bash

set -eu -o pipefail

CWD_LIB_DEPENDENCY="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "${CWD_LIB_DEPENDENCY}/print.sh"

retrochamber.lib.depedency.check_commands () {
  local LIST_COMMANDS=${1:-}
  local EXIT_ON_FAIL=${2:-1}
  local FAIL=0

  while read -r -d " " COMMAND; do
    if [ -z "$(command -v "${COMMAND}")" ]; then
      FAIL=1
      echo "${COMMAND}"
    fi
  done <<<"${LIST_COMMANDS[@]}"

  if [ "${EXIT_ON_FAIL}" -eq 0 ]; then
    return
  fi

  if [ $FAIL -eq 1 ]; then
    exit 1
  fi
}
