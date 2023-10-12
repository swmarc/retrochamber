#!/bin/bash

set -eu -o pipefail

retrochamber.lib.print.get_date_time () {
  printf "%s" "$(date -u --rfc-3339=seconds)"
}
