#!/bin/bash

set -eu -o pipefail

RETROCHAMBER_LIB_PRINT_CWD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
PRINT_DEBUG=${PRINT_DEBUG:-0}

source "${RETROCHAMBER_LIB_PRINT_CWD}/datetime.sh"

retrochamber.lib.print.blue () {
  echo -ne "\033[1;94m${1}\033[0m"
}

retrochamber.lib.print.green () {
  echo -ne "\033[1;92m${1}\033[0m"
}

retrochamber.lib.print.purple () {
  echo -ne "\033[1;95m${1}\033[0m"
}

retrochamber.lib.print.red () {
  echo -ne "\033[1;91m${1}\033[0m"
}

retrochamber.lib.print.yellow () {
  echo -ne "\033[1;93m${1}\033[0m"
}

retrochamber.lib.print.on_previous_line () {
  echo -ne "\033[1K\r${1}"
}

retrochamber.lib.print.blink () {
  echo -ne "\033[5m${1}\033[25m"
}

retrochamber.lib.print.bold () {
  echo -ne "\033[1m${1}\033[0m"
}

retrochamber.lib.print.success () {
  local SCRIPT=${1}
  local TEXT=${2}
  local SELF="retrochamber.lib.print"

  $SELF.bold "["; $SELF.blue "${SCRIPT}"; $SELF.bold "] ";
  $SELF.bold "["; $SELF.green "+++"; $SELF.bold "] ";
  $SELF.bold "["; $SELF.green "$(retrochamber.lib.print.get_date_time)"; $SELF.bold "] ";
  $SELF.bold "${TEXT}\n"
}

retrochamber.lib.print.info () {
  local SCRIPT=${1}
  local TEXT=${2}
  local SELF="retrochamber.lib.print"

  $SELF.bold "["; $SELF.blue "${SCRIPT}"; $SELF.bold "] ";
  $SELF.bold "["; $SELF.yellow "***"; $SELF.bold "] ";
  $SELF.bold "["; $SELF.yellow "$(retrochamber.lib.print.get_date_time)"; $SELF.bold "] ";
  $SELF.bold "${TEXT}\n"
}

retrochamber.lib.print.fail () {
  local SCRIPT=${1}
  local TEXT=${2}
  local SELF="retrochamber.lib.print"

  $SELF.bold "["; $SELF.blue "${SCRIPT}"; $SELF.bold "] ";
  $SELF.bold "["; $SELF.red "$($SELF.blink "!!!")"; $SELF.bold "] ";
  $SELF.bold "["; $SELF.red "$(retrochamber.lib.print.get_date_time)"; $SELF.bold "] ";
  $SELF.bold "${TEXT}\n"
}

retrochamber.lib.print.debug () {
  local SCRIPT=${1}
  local TEXT=${2}
  local SELF="retrochamber.lib.print"

  if [ "${PRINT_DEBUG}" -eq 1 ]; then
    $SELF.bold "["; $SELF.blue "${SCRIPT}"; $SELF.bold "] ";
    $SELF.bold "["; $SELF.purple "$($SELF.blink "===")"; $SELF.bold "] ";
    $SELF.bold "["; $SELF.purple "$(retrochamber.lib.print.get_date_time)"; $SELF.bold "] ";
    $SELF.purple "${TEXT}\n"
  fi
}
