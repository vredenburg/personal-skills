#!/usr/bin/env bash

set -euo pipefail

dmi_path="${ASUS_ANIME_DMI_PATH:-/sys/class/dmi/id/board_name}"

if [[ ! -r "$dmi_path" ]]; then
  echo "Unable to read the DMI board name at $dmi_path" >&2
  exit 1
fi

read -r board_name < "$dmi_path"
board_name="${board_name^^}"

case "$board_name" in
  *GA401I*|*GA401Q*) echo GA401 ;;
  *GA402R*|*GA402X*|*GA402N*) echo GA402 ;;
  *GU604V*) echo GU604 ;;
  *G635L*) echo G635L ;;
  *G835L*) echo G835L ;;
  *)
    echo "Unsupported AniMe Matrix board: $board_name" >&2
    exit 2
    ;;
esac
