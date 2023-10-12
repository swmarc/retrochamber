#!/bin/bash

set -eu

CWD="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
SCRIPT_UPDATE=$(basename "${BASH_SOURCE[0]}" .sh)
GITHUB_TOKEN=""
TARGET_APPIMAGE_PATH="$(realpath "${CWD}/../binaries")"

source "${CWD}/../lib/access.sh"
source "${CWD}/../lib/print.sh"

if [ -f "${CWD}/GITHUB_TOKEN" ]; then
  GITHUB_TOKEN=$(cat "${CWD}/GITHUB_TOKEN")
fi

update_retroarch () {
  local ARCHIVE_FILENAME="" DOWNLOAD_URL="" RETROARCH_CONFIGS=()
  local RETROARCH_CONFIGS_PATH="" RSYNC_FILES=0 SOURCE_FILEPATH=""
  local TARGET_FILENAME="" VERSION="" VERSION_FILE=""
  local JSON_URL="https://buildbot.libretro.com/stable/altstore.json"

  PROJECT=$(retrochamber.lib.print.blue "RetroArch")
  ARCHIVE_FILENAME="RetroArch.7z"
  SOURCE_FILEPATH="RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage"
  TARGET_FILENAME="retroarch"
  RETROARCH_CONFIGS_PATH="RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch"
  RETROARCH_CONFIGS=(
    assets
    autoconfig
    database
    filters
    overlays
    shaders
  )

  VERSION=$(wget -q -O- "${JSON_URL}" | jq -r ".apps[0].versions[0].version")
  VERSION_FILE="${TARGET_APPIMAGE_PATH}/VERSION.${TARGET_FILENAME}"
  DOWNLOAD_URL="https://buildbot.libretro.com/stable/${VERSION}/linux/x86_64/${ARCHIVE_FILENAME}"

  if [ ! -f "${VERSION_FILE}" ]; then
    touch "${VERSION_FILE}"
  fi

  if [ "$(cat "${VERSION_FILE}")" == "${VERSION}" ]; then
    retrochamber.lib.print.info "${SCRIPT_UPDATE}" "No update for project '${PROJECT}'."
    return
  fi

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update available for project '${PROJECT}'. New version is '${VERSION}'."
  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Downloading archive '${ARCHIVE_FILENAME}'."
  wget -qc --show-progress -P "${CWD}/" "${DOWNLOAD_URL}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Extracting archive '${ARCHIVE_FILENAME}'."
  mkdir -p "${CWD}/.tmp"
  7z x -bso0 -bse1 -bsp1 -o"${CWD}/.tmp/" "${CWD}/${ARCHIVE_FILENAME}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Copying AppImage '${TARGET_FILENAME}.AppImage'."
  cp "${CWD}/.tmp/${SOURCE_FILEPATH}" "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage"
  chmod 764 "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Copying configurations. This can take a while."
  mkdir -p "${CWD}/../.retroarch"
  for RETROARCH_CONFIG in "${RETROARCH_CONFIGS[@]}"; do
    RSYNC_FILES=$(find "${CWD}/.tmp/${RETROARCH_CONFIGS_PATH}/${RETROARCH_CONFIG}/" | wc -l)

    retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Copying '${RETROARCH_CONFIG}'."
    mkdir -p "${CWD}/../.retroarch/${RETROARCH_CONFIG}/"
    chmod -R 755 "${CWD}/../.retroarch/${RETROARCH_CONFIG}"
    rsync -rh --no-i-r --inplace --delete-during --no-perms --no-owner --no-group --info=progress1 \
      "${CWD}/.tmp/${RETROARCH_CONFIGS_PATH}/${RETROARCH_CONFIG}/" \
      "${CWD}/../.retroarch/${RETROARCH_CONFIG}/" |\
      pv -ltaep -w 80 -s "${RSYNC_FILES}" \
      >/dev/null
  done
  echo "${VERSION}" > "${VERSION_FILE}"

  retroarch_libretro_cleanup
  rm -f "${CWD}/${ARCHIVE_FILENAME}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update done."
  sleep 0.5
}

update_libretro () {
  local ARCHIVE_FILENAME="" DOWNLOAD_URL="" RETROARCH_CONFIGS=()
  local RETROARCH_CONFIGS_PATH="" RSYNC_FILES=0 TARGET_FILENAME="" VERSION=""
  local VERSION_FILE=""
  local JSON_URL="https://buildbot.libretro.com/stable/altstore.json"

  PROJECT=$(retrochamber.lib.print.blue "libretro")
  ARCHIVE_FILENAME="RetroArch_cores.7z"
  TARGET_FILENAME="libretro"
  RETROARCH_CONFIGS_PATH="RetroArch-Linux-x86_64/RetroArch-Linux-x86_64.AppImage.home/.config/retroarch"
  RETROARCH_CONFIGS=(
    cores
  )

  VERSION=$(wget -q -O- "${JSON_URL}" | jq -r ".apps[0].versions[0].version")
  VERSION_FILE="${TARGET_APPIMAGE_PATH}/VERSION.${TARGET_FILENAME}"
  DOWNLOAD_URL="https://buildbot.libretro.com/stable/${VERSION}/linux/x86_64/${ARCHIVE_FILENAME}"

  if [ ! -f "${VERSION_FILE}" ]; then
    touch "${VERSION_FILE}"
  fi

  if [ "$(cat "${VERSION_FILE}")" == "${VERSION}" ]; then
    retrochamber.lib.print.info "${SCRIPT_UPDATE}" "No update for project '${PROJECT}'."
    return
  fi

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update available for project '${PROJECT}'. New version is '${VERSION}'."
  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Downloading archive '${ARCHIVE_FILENAME}'."
  wget -qc --show-progress -P "${CWD}/" "${DOWNLOAD_URL}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Extracting archive '${ARCHIVE_FILENAME}'."
  mkdir -p "${CWD}/.tmp"
  7z x -bso0 -bse1 -bsp1 -o"${CWD}/.tmp/" "${CWD}/${ARCHIVE_FILENAME}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Copying configurations."
  for RETROARCH_CONFIG in "${RETROARCH_CONFIGS[@]}"; do
    RSYNC_FILES=$(find "${CWD}/.tmp/${RETROARCH_CONFIGS_PATH}/${RETROARCH_CONFIG}/" | wc -l)

    retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Copying '${RETROARCH_CONFIG}'."
    mkdir -p "${CWD}/../.retroarch/${RETROARCH_CONFIG}/"
    chmod -R 755 "${CWD}/../.retroarch/${RETROARCH_CONFIG}"
    rsync -rh --no-i-r --inplace --delete-during --no-perms --no-owner --no-group --info=progress1 \
      "${CWD}/.tmp/${RETROARCH_CONFIGS_PATH}/${RETROARCH_CONFIG}/" \
      "${CWD}/../.retroarch/${RETROARCH_CONFIG}/" |\
      pv -ltaep -w 80 -s "${RSYNC_FILES}" \
      >/dev/null
  done
  echo "${VERSION}" > "${VERSION_FILE}"

  retroarch_libretro_cleanup
  rm -f "${CWD}/${ARCHIVE_FILENAME}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update done."
  sleep 0.5
}

retroarch_libretro_cleanup () {
  rm -rf "${CWD:?}/.tmp"
}

update_gitlab () {
  declare -A PROJECTS
  local PROJECTS
  local API_RESPONSE="" DOWNLOAD_URL="" PROJECT="" PROJECT_PRINT="" TAG_NAME=""
  local TARGET_FILENAME="" VERSION_FILE="" URL=""

  PROJECTS=(
    ["es-de/emulationstation-de"]="EmulationStation-DE-x64.AppImage"
  )
  URL="https://gitlab.com/api/v4/projects"
  URL_RELEASE="releases"

  for PROJECT in "${!PROJECTS[@]}"; do
    PROJECT_FILENAME="${PROJECTS[$PROJECT]}"

    PROJECT_PRINT=$(retrochamber.lib.print.blue "${PROJECT}")
    API_RESPONSE=$(curl --silent "${URL}/$(echo "${PROJECT}" | sed -e 's/\//%2F/g')/${URL_RELEASE}")
    TARGET_FILENAME=$(echo "${PROJECT}" | cut -d'/' -f2)
    VERSION_FILE="${TARGET_APPIMAGE_PATH}/VERSION.${TARGET_FILENAME}"
    TAG_NAME=$(echo "${API_RESPONSE}" | jq -r '.[0].tag_name')
    if [ -z "$(echo "${TAG_NAME}" | grep '[0-9]')" ]; then
      TAG_NAME=$(echo "${API_RESPONSE}" | jq -r '.[0].released_at')
    fi
    DOWNLOAD_URL=$(echo "${API_RESPONSE}" | jq -r "[.[].assets.links[] | select(.name | match(\"^${PROJECT_FILENAME}$\"))][0] | .direct_asset_url")

    if [ -z "${DOWNLOAD_URL}" ]; then
      retrochamber.lib.print.fail "${SCRIPT_UPDATE}" "Cannot find AppImage download URL for project '${PROJECT_PRINT}'."
      exit 10
    fi

    if [ ! -f "${VERSION_FILE}" ]; then
      touch "${VERSION_FILE}"
    fi

    if [ "$(cat "${VERSION_FILE}")" == "${TAG_NAME}" ]; then
      retrochamber.lib.print.info "${SCRIPT_UPDATE}" "No update for project '${PROJECT_PRINT}'."
      continue
    fi

    retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update available for project '${PROJECT_PRINT}'. New version is '${TAG_NAME}'."
    wget -q --show-progress -O "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage" "${DOWNLOAD_URL}"
    chmod 764 "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage"
    echo "${TAG_NAME}" > "${VERSION_FILE}"

    retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update done."
    sleep 0.5
  done
}

update_github () {
  declare -A PROJECTS
  local PROJECTS
  local API_RESPONSE="" DOWNLOAD_URL="" PROJECT="" PROJECT_PRINT=""
  local PROJECT_REDIRECT_PRINT="" TAG_NAME="" TARGET_FILENAME=""
  local VERSION_FILE="" URL=""

  PROJECTS=(
    ["cemu-project/cemu"]="Cemu-.*-x86_64.AppImage"
    ["monokuma9/dolphin-triforce-linux>dolphin-triforce"]="dolphin-emu-triforce-.*-x86_64.AppImage"
    ["flyinghead/flycast"]="flycast-x86_64.AppImage"
    ["garglk/garglk"]="Gargoyle-x86_64.AppImage"
    ["korkman/macemu-appimage-builder>basiliskii"]="BasiliskII-x86_64.AppImage"
    ["korkman/macemu-appimage-builder>sheepshaver"]="SheepShaver-x86_64.AppImage"
    ["mgba-emu/mgba"]="mGBA-.*-appimage-x64.appimage"
    ["pcsx2/pcsx2"]="pcsx2-.*-linux-appimage-x64-Qt.AppImage"
    ["rosalie241/rmg"]="RMG-Portable-Linux64-.*.AppImage"
    ["rpcs3/rpcs3-binaries-linux>rpcs3"]="rpcs3-.*_linux64.AppImage"
    ["snes9xgit/snes9x"]="Snes9x-.*-x86_64.AppImage"
    ["stenzek/duckstation"]="DuckStation-x64.AppImage"
    ["swmarc/emulation-appimages>atari800"]="atari800-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>blastem"]="blastem-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>cpcemu"]="cpcemu-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>dosbox-staging"]="dosbox-staging-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>dosbox-x"]="dosbox-x-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>easyrpg-player"]="easyrpg-player-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>fbneo"]="fbneo-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>fs-uae"]="fs-uae-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>fuse-archive"]="fuse-archive-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>fuse-sdl"]="fuse-sdl-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>gopher2600"]="gopher2600-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>linapple"]="linapple-git-x86_64.AppImage"
    ["swmarc/emulation-appimages>mame"]="mame-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>mednafen"]="mednafen-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>melonds"]="melonds-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>mount-zip"]="mount-zip-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>nestopia"]="nestopia-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>openmsx"]="openmsx-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>pico8"]="pico8-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>scummvm"]="scummvm-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>simcoupe"]="simcoupe-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>stella"]="stella-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>supermodel"]="supermodel-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>tsugaru-cui"]="tsugaru-cui-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>xroar"]="xroar-.*-x86_64.AppImage"
    ["swmarc/emulation-appimages>zesarux"]="zesarux-.*-x86_64.AppImage"
    ["xemu-project/xemu"]="xemu-v[0-9.]*-x86_64.AppImage"
    ["yuzu-emu/yuzu-mainline>yuzu"]="yuzu-mainline-.*.AppImage"
  )
  URL="https://api.github.com/repos"
  URL_RELEASE="releases"

  for PROJECT in "${!PROJECTS[@]}"; do
    PROJECT_FILENAME="${PROJECTS[$PROJECT]}"

    PROJECT_REDIRECT_PRINT=""
    TARGET_FILENAME=$(echo "${PROJECT}" | cut -d'/' -f2)
    if [ -n "$(echo "${PROJECT}" | grep '>')" ]; then
      TARGET_FILENAME=$(echo "${PROJECT}" | cut -d'>' -f2)
      PROJECT_REDIRECT_PRINT=">$(retrochamber.lib.print.blue "${TARGET_FILENAME}")"
      PROJECT=$(echo "${PROJECT}" | cut -d'>' -f1)
    fi

    PROJECT_PRINT=$(retrochamber.lib.print.blue "${PROJECT}")
    API_RESPONSE=$(curl -u "$GITHUB_TOKEN:x-oauth-basic" --silent "${URL}/${PROJECT}/${URL_RELEASE}")
    VERSION_FILE="${TARGET_APPIMAGE_PATH}/VERSION.${TARGET_FILENAME}"
    TAG_NAME=$(echo "${API_RESPONSE}" | jq -r "[.[].assets[] | select(.name | match(\"^${PROJECT_FILENAME}$\"))][0] | .created_at")
    DOWNLOAD_URL=$(echo "${API_RESPONSE}" | jq -r "[.[].assets[] | select(.name | match(\"^${PROJECT_FILENAME}$\"))][0] | .browser_download_url")

    if [ -z "${DOWNLOAD_URL}" ] || [ "${DOWNLOAD_URL}" == null ]; then
      retrochamber.lib.print.fail "${SCRIPT_UPDATE}" "Cannot find AppImage download URL for project '${PROJECT_PRINT}${PROJECT_REDIRECT_PRINT}'."
      exit 10
    fi

    if [ ! -f "${VERSION_FILE}" ]; then
      touch "${VERSION_FILE}"
    fi

    if [ "$(cat "${VERSION_FILE}")" == "${TAG_NAME}" ]; then
      retrochamber.lib.print.info "${SCRIPT_UPDATE}" "No update for project '${PROJECT_PRINT}${PROJECT_REDIRECT_PRINT}'."
      continue
    fi

    retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update available for project '${PROJECT_PRINT}${PROJECT_REDIRECT_PRINT}'. New version is '${TAG_NAME}'."
    wget -q --show-progress -O "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage" "${DOWNLOAD_URL}"
    chmod 764 "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage"
    echo "${TAG_NAME}" > "${VERSION_FILE}"

    retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update done."
    sleep 0.5
  done
}

update_github_from_tarball () {
  declare -A PROJECTS
  local PROJECTS
  local API_RESPONSE="" DOWNLOAD_URL="" PROJECT="" PROJECT_PRINT=""
  local PROJECT_REDIRECT_PRINT="" TAG_NAME="" TARGET_FILENAME=""
  local VERSION_FILE="" URL=""

  PROJECTS=(
    ["dirtbagxon/hypseus-singe"]="hypseus-singe_.*_SteamOS_ES-DE.tar.gz"
  )
  URL="https://api.github.com/repos"
  URL_RELEASE="releases"

  for PROJECT in "${!PROJECTS[@]}"; do
    PROJECT_FILENAME="${PROJECTS[$PROJECT]}"

    PROJECT_REDIRECT_PRINT=""
    TARGET_FILENAME=$(echo "${PROJECT}" | cut -d'/' -f2)
    if [ -n "$(echo "${PROJECT}" | grep '>')" ]; then
      TARGET_FILENAME=$(echo "${PROJECT}" | cut -d'>' -f2)
      PROJECT_REDIRECT_PRINT=">$(retrochamber.lib.print.blue "${TARGET_FILENAME}")"
      PROJECT=$(echo "${PROJECT}" | cut -d'>' -f1)
    fi

    PROJECT_PRINT=$(retrochamber.lib.print.blue "${PROJECT}")
    API_RESPONSE=$(curl -u "$GITHUB_TOKEN:x-oauth-basic" --silent "${URL}/${PROJECT}/${URL_RELEASE}")
    VERSION_FILE="${TARGET_APPIMAGE_PATH}/VERSION.${TARGET_FILENAME}"
    TAG_NAME=$(echo "${API_RESPONSE}" | jq -r "[.[].assets[] | select(.name | match(\"^${PROJECT_FILENAME}$\"))][0] | .created_at")
    DOWNLOAD_URL=$(echo "${API_RESPONSE}" | jq -r "[.[].assets[] | select(.name | match(\"^${PROJECT_FILENAME}$\"))][0] | .browser_download_url")

    if [ -z "${DOWNLOAD_URL}" ] || [ "${DOWNLOAD_URL}" == null ]; then
      retrochamber.lib.print.fail "${SCRIPT_UPDATE}" "Cannot find AppImage download URL for project '${PROJECT_PRINT}${PROJECT_REDIRECT_PRINT}'."
      exit 10
    fi

    if [ ! -f "${VERSION_FILE}" ]; then
      touch "${VERSION_FILE}"
    fi

    if [ "$(cat "${VERSION_FILE}")" == "${TAG_NAME}" ]; then
      retrochamber.lib.print.info "${SCRIPT_UPDATE}" "No update for project '${PROJECT_PRINT}${PROJECT_REDIRECT_PRINT}'."
      continue
    fi

    retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update available for project '${PROJECT_PRINT}${PROJECT_REDIRECT_PRINT}'. New version is '${TAG_NAME}'."
    mkdir -p "${CWD}/.tmp"
    (
      cd "${CWD}/.tmp"
      wget -q --show-progress -O- "${DOWNLOAD_URL}" | bsdtar -xf-
      find "${CWD}/.tmp" \
        -type f \
        -name "*.AppImage" \
        -exec mv {} "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage" \;
    )
    chmod 764 "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage"
    rm -rf "${CWD:?}/.tmp"
    echo "${TAG_NAME}" > "${VERSION_FILE}"

    retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update done."
    sleep 0.5
  done
}

update_github_citra () {
  local API_RESPONSE="" ARCHIVE_FILENAME="" TAG_NAME="" DOWNLOAD_URL=""
  local PROJECT="" PROJECT_PRINT="" SOURCE_FILENAME="" TARGET_FILENAME=""
  local VERSION_FILE="" URL=""

  PROJECT="citra-emu/citra-nightly"
  PROJECT_PRINT=$(retrochamber.lib.print.blue "${PROJECT}")
  URL="https://api.github.com/repos"
  URL_RELEASE="releases"
  SOURCE_FILENAME="citra-linux-appimage-.*.7z"
  TARGET_FILENAME="citra"

  API_RESPONSE=$(curl -u "$GITHUB_TOKEN:x-oauth-basic" --silent "${URL}/${PROJECT}/${URL_RELEASE}")
  VERSION_FILE="${TARGET_APPIMAGE_PATH}/VERSION.${TARGET_FILENAME}"
  TAG_NAME=$(echo "${API_RESPONSE}" | jq -r ".[0].tag_name")
  DOWNLOAD_URL=$(echo "${API_RESPONSE}" | jq -r ".[0].assets[] | select(.name | match(\"^${SOURCE_FILENAME}$\")) | .browser_download_url")
  ARCHIVE_FILENAME=$(echo "${DOWNLOAD_URL}" | rev | cut -d'/' -f1 | rev)

  if [ -z "${DOWNLOAD_URL}" ]; then
    retrochamber.lib.print.fail "${SCRIPT_UPDATE}" "Cannot find AppImage download URL for project '${PROJECT_PRINT}'."
    exit 10
  fi

  if [ ! -f "${VERSION_FILE}" ]; then
    touch "${VERSION_FILE}"
  fi

  if [ "$(cat "${VERSION_FILE}")" == "${TAG_NAME}" ]; then
    retrochamber.lib.print.info "${SCRIPT_UPDATE}" "No update for project '${PROJECT_PRINT}'."
    return
  fi

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update available for project '${PROJECT_PRINT}'. New version is '${TAG_NAME}'."
  wget -qc --show-progress -P "${CWD}/" "${DOWNLOAD_URL}"
  7z e -bso0 -bse1 -bsp1 -aoa -o"${TARGET_APPIMAGE_PATH}/" "${CWD}/${ARCHIVE_FILENAME}" "nightly/${TARGET_FILENAME}.AppImage"
  rm -f "${CWD}/${ARCHIVE_FILENAME}"
  chmod 764 "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage"
  echo "${TAG_NAME}" > "${VERSION_FILE}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update done."
  sleep 0.5
}

update_play_stable () {
  local BASE_URL="https://purei.org/downloads/play/stable"
  local DOWNLOAD_URL="" REMOTE_DIR="" REMOTE_FILE="" TARGET_FILENAME=""
  local PROJECT_PRINT="" VERSION_FILE=""

  PROJECT_PRINT=$(retrochamber.lib.print.blue "Play!")
  TARGET_FILENAME="play"

  REMOTE_DIR=$(
    rclone lsf \
      --http-url ${BASE_URL} :http: |\
      tail -n1
  )
  REMOTE_FILE=$(
    rclone lsf \
      --http-url ${BASE_URL}/${REMOTE_DIR} :http: |\
      grep -F 'AppImage' |\
      cut -d. -f1
  )

  DOWNLOAD_URL="${BASE_URL}/${REMOTE_DIR}/${REMOTE_FILE}.AppImage"

  if [ -z "${REMOTE_FILE}" ]; then
    retrochamber.lib.print.fail "${SCRIPT_UPDATE}" "Cannot find AppImage file for project '${PROJECT_PRINT}'."
    exit 10
  fi

  VERSION_FILE="${TARGET_APPIMAGE_PATH}/VERSION.${TARGET_FILENAME}"
  if [ ! -f "${VERSION_FILE}" ]; then
    touch "${VERSION_FILE}"
  fi

  if [ "$(cat "${VERSION_FILE}")" == "${REMOTE_FILE}" ]; then
    retrochamber.lib.print.info "${SCRIPT_UPDATE}" "No update for project '${PROJECT_PRINT}'."
    return
  fi

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update available for project '${PROJECT_PRINT}'. New version is '${REMOTE_FILE}'."
  wget -q --show-progress -O "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage" "${DOWNLOAD_URL}"
  chmod 764 "${TARGET_APPIMAGE_PATH}/${TARGET_FILENAME}.AppImage"
  echo "${REMOTE_FILE}" > "${VERSION_FILE}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update done."
  sleep 0.5
}

update_bios () {
  local API_RESPONSE="" DOWNLOAD_URL="" PROJECT="" PROJECT_PRINT=""
  local RSYNC_FILES="" TAG_NAME="" TARGET_FILENAME="" VERSION_FILE="" URL=""

  PROJECT="archtaurus/retropiebios"
  PROJECT_PRINT=$(retrochamber.lib.print.blue "${PROJECT}")
  URL="https://api.github.com/repos"
  URL_RELEASE="releases"

  API_RESPONSE=$(curl -u "$GITHUB_TOKEN:x-oauth-basic" --silent "${URL}/${PROJECT}/${URL_RELEASE}")
  TARGET_FILENAME=$(echo "${PROJECT}" | cut -d'/' -f2)
  VERSION_FILE="${TARGET_APPIMAGE_PATH}/VERSION.${TARGET_FILENAME}"
  TAG_NAME=$(echo "${API_RESPONSE}" | jq -r '.[0].tag_name')
  DOWNLOAD_URL=$(echo "${API_RESPONSE}" | jq -r ".[0].zipball_url")

  if [ -z "${DOWNLOAD_URL}" ]; then
    retrochamber.lib.print.fail "${SCRIPT_UPDATE}" "Cannot find zip download URL for project '${PROJECT_PRINT}'."
    exit 10
  fi

  if [ ! -f "${VERSION_FILE}" ]; then
    touch "${VERSION_FILE}"
  fi

  if [ "$(cat "${VERSION_FILE}")" == "${TAG_NAME}" ]; then
      retrochamber.lib.print.info "${SCRIPT_UPDATE}" "No update for project '${PROJECT_PRINT}'."
      return
  fi

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update available for project '${PROJECT_PRINT}'. New version is '${TAG_NAME}'."
  wget -qc --show-progress -O "${CWD}/${TARGET_FILENAME}.zip" "${DOWNLOAD_URL}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Mounting zip file."
  mkdir -p "${CWD}/.tmp"
  fuse-archive "${CWD}/${TARGET_FILENAME}.zip" "${CWD}/.tmp"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Copying 'system'."
  RSYNC_FILES=$(find "${CWD}/.tmp/"*"/BIOS/" | wc -l)
  rsync -rh --no-i-r --inplace --delete-during --no-perms --no-owner --no-group --info=progress1 \
    "${CWD}/.tmp/"*"/BIOS/" \
    "${CWD}/../.retroarch/system/" |\
    pv -ltaep -w 80 -s "${RSYNC_FILES}" \
    >/dev/null
  retrochamber.lib.access.fix_permissions "${CWD}/../.retroarch/"

  fusermount -u "${CWD}/.tmp"
  rm -f "${CWD}/${TARGET_FILENAME}.zip"
  rm -rf "${CWD:?}/.tmp"
  echo "${TAG_NAME}" > "${VERSION_FILE}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update done."
  sleep 0.5
}

update_bios_capsimg () {
  # Hard code, since it seems there won't be any newer version.
  local DOWNLOAD_URL="https://fs-uae.net/files/CAPSImg/Stable/5.1.4/CAPSImg_5.1.4_Linux_x86-64.tar.xz"
  local PROJECT="" PROJECT_FILE="" PROJECT_PRINT="" TAG_NAME="" VERSION_FILE=""

  PROJECT="CAPSImg"
  PROJECT_FILE="capsimg.so"
  PROJECT_PRINT=$(retrochamber.lib.print.blue "${PROJECT}")
  VERSION_FILE="${TARGET_APPIMAGE_PATH}/VERSION.capsimg"
  TAG_NAME=$(echo "${DOWNLOAD_URL}" | rev | cut -d/ -f2 | rev)

  if [ ! -f "${VERSION_FILE}" ]; then
    touch "${VERSION_FILE}"
  fi

  if [ "$(cat "${VERSION_FILE}")" == "${TAG_NAME}" ]; then
    retrochamber.lib.print.info "${SCRIPT_UPDATE}" "No update for project '${PROJECT}'."
    return
  fi

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update available for project '${PROJECT}'. New version is '${TAG_NAME}'."
  mkdir -p "${CWD}/.tmp"
  (
    cd "${CWD}/.tmp"
    wget -q --show-progress -O- "${DOWNLOAD_URL}" | bsdtar -xf-
    find "${CWD}/.tmp" \
      -type f \
      -name "${PROJECT_FILE}" \
      -exec mv {} "${CWD}/../.retroarch/system/" \;
  )
  retrochamber.lib.access.fix_permissions "${CWD}/../.retroarch/"
  rm -rf "${CWD:?}/.tmp"
  echo "${TAG_NAME}" > "${VERSION_FILE}"

  retrochamber.lib.print.success "${SCRIPT_UPDATE}" "Update done."
  sleep 0.5
}

update_retroarch
update_libretro
update_gitlab
update_github
update_github_citra
update_github_from_tarball
update_play_stable
update_bios
update_bios_capsimg
