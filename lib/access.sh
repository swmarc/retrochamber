#!/bin/bash

set -eu -o pipefail

CWD_ACCESS="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
LIB_ACCESS=$(basename "${BASH_SOURCE[0]}" .sh)

source "${CWD_ACCESS}/print.sh"

retrochamber.lib.access.fix_permissions () {
  local DIRECTORY="$1"

  retrochamber.lib.print.info "${LIB_ACCESS}" "Adjusting permissions."
  chmod -R ugo-x,o-w,u+rwX,g+rwX,o+rX "${DIRECTORY}"
}
