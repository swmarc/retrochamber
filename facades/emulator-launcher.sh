#!/bin/bash

set -eu -o pipefail

export PRINT_DEBUG=1

CWD_LAUNCHER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_LAUNCHER=$(basename "${BASH_SOURCE[0]}" .sh)
exec > >(tee "${CWD_LAUNCHER}/../logs/${SCRIPT_LAUNCHER}.log") 2>&1

source "${CWD_LAUNCHER}/../lib/options.sh"
source "${CWD_LAUNCHER}/../lib/paths.sh"
source "${CWD_LAUNCHER}/../lib/print.sh"

# ES-DE sometimes escaped, sometimes unscaped paths.
# Unescape path since we will quote them.
retrochamber.lib.options.set "-rom" "$(retrochamber.lib.paths.unescape "$(retrochamber.lib.options.get "-rom")")"

OPTION_EMULATOR=$(retrochamber.lib.options.get "-emulator")
retrochamber.lib.print.debug "${SCRIPT_LAUNCHER}" "Emulator path: ${OPTION_EMULATOR}"

OPTION_ZIP_MOUNT=$(retrochamber.lib.options.get "-zip-mount")
retrochamber.lib.print.debug "${SCRIPT_LAUNCHER}" "Mount ZIP: ${OPTION_ZIP_MOUNT}"

OPTION_ROM_PATH=$(retrochamber.lib.options.get "-rom")
retrochamber.lib.print.debug "${SCRIPT_LAUNCHER}" "ROM path: ${OPTION_ROM_PATH}"

OPTION_MOUNT_AS_DIRECTORY=$(retrochamber.lib.options.get "-mount-as-directory" || true)
retrochamber.lib.print.debug "${SCRIPT_LAUNCHER}" "Mount as directory: ${OPTION_MOUNT_AS_DIRECTORY}"

retrochamber.lib.options.remove "-emulator"
retrochamber.lib.options.remove "-zip-mount"
retrochamber.lib.options.remove "-rom"
retrochamber.lib.options.remove "-mount-as-directory"

FILE_EXTENSIONS=(*.iso *.cue *.chd *.cso *.ciso *.gcz *.rvz *.gdi *.wia *.wux)
ZIP_EXTENSIONS=(zip rar 7z tgz xz)

ZIP_PATH="$(realpath "${CWD_LAUNCHER}/../tmp/archive")"
retrochamber.lib.print.debug "${SCRIPT_LAUNCHER}" "ZIP path: ${ZIP_PATH}"

ROM_NAME=$(echo "${OPTION_ROM_PATH}" | rev | cut -d/ -f1 | rev | cut -d. -f1)
FILE_EXTENSION=$(echo "${OPTION_ROM_PATH}" | rev | cut -d. -f1 | rev)

unmount_zip() {
  # shellcheck disable=2199
  IS_MOUNTED=$(cat /proc/mounts | grep "${ZIP_PATH}" || true)
  # shellcheck disable=2086
  if [ -n "$IS_MOUNTED" ]; then
    fusermount -uz "${ZIP_PATH}"
  fi
}
trap unmount_zip EXIT
trap unmount_zip SIGINT

# shellcheck disable=2076
# shellcheck disable=2199
if [ "${OPTION_ZIP_MOUNT}" -eq 1 ] && [[ " ${ZIP_EXTENSIONS[@]} " =~ " ${FILE_EXTENSION} " ]]; then
  unmount_zip

  retrochamber.lib.print.info "${SCRIPT_LAUNCHER}" "Mounting '${ROM_NAME}' from remote. This can take a while."

  FILE_SIZE=$(du -h "${OPTION_ROM_PATH}" | cut -f1)
  retrochamber.lib.print.info "${SCRIPT_LAUNCHER}" "File size is '${FILE_SIZE}'."

  "${CWD_LAUNCHER}/../binaries/mount-zip.AppImage" "${OPTION_ROM_PATH}" "${ZIP_PATH}"
  if [ -n "${OPTION_MOUNT_AS_DIRECTORY}" ]; then
    OPTION_ROM_PATH=${ZIP_PATH}
  fi

  if [ -z "${OPTION_MOUNT_AS_DIRECTORY}" ]; then
    retrochamber.lib.print.success "${SCRIPT_LAUNCHER}" "Archive mounted. Searching for ROM file extension."
    for EXT in "${FILE_EXTENSIONS[@]}"; do
      IS_AVAILABLE=$(ls "${ZIP_PATH}/"${EXT} 2>/dev/null || true)
      if [ -n "${IS_AVAILABLE}" ]; then
        # shellcheck disable=2012
        OPTION_ROM_PATH="${ZIP_PATH}/$(ls "${ZIP_PATH}/"${EXT} | rev | cut -d/ -f1 | rev)"
      fi
    done

    if [ -z "${OPTION_ROM_PATH}" ]; then
      retrochamber.lib.print.fail "${SCRIPT_LAUNCHER}" "No expected ROM file extension found in ZIP. Exiting."
      sleep 10
      exit 1
    fi
  fi
else
  retrochamber.lib.print.info "${SCRIPT_LAUNCHER}" "Not a ZIP archive or necessity to mount. Running without mounting."
fi

retrochamber.lib.print.debug "${SCRIPT_LAUNCHER}" "ROM path: ${OPTION_ROM_PATH}"
retrochamber.lib.print.success "${SCRIPT_LAUNCHER}" "ROM found."

COMMAND=("${OPTION_EMULATOR}")
for OPTION_KEY in "${!OPTIONS[@]}"; do
  COMMAND+=("${OPTION_KEY}" "${OPTIONS[${OPTION_KEY}]}")
done
COMMAND+=(" -rom \"${OPTION_ROM_PATH}\"")

retrochamber.lib.print.info "${SCRIPT_LAUNCHER}" "Starting emulator."
retrochamber.lib.print.debug "${SCRIPT_LAUNCHER}" "Command: ${COMMAND[*]}"
# shellcheck disable=2294
eval "${COMMAND[@]}"

retrochamber.lib.print.info "${SCRIPT_LAUNCHER}" "Emulation has stopped."
unmount_zip

sleep 5
