#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: validate-anime-gif.sh [--model auto|MODEL] ANIMATION.gif

Checks the selected model profile: full opaque frames at the logical canvas
size, grayscale content, exact mask compatibility, and no illuminated pixels
outside mapped LED coordinates.
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$script_dir/.." && pwd)"
profiles_dir="$skill_dir/profiles"
detector="$script_dir/detect-anime-model.sh"
# shellcheck source=scripts/lib/model-profile.sh
source "$script_dir/lib/model-profile.sh"
requested_model=auto

if [[ "${1:-}" == --model ]]; then
  requested_model="${2:?Missing value for --model}"
  shift 2
fi
if [[ "${1:-}" == -h || "${1:-}" == --help ]]; then
  usage
  exit 0
fi
[[ "$#" -eq 1 ]] || { usage >&2; exit 2; }
input="$1"

[[ -f "$input" ]] || { echo "Animation not found: $input" >&2; exit 1; }
command -v magick >/dev/null 2>&1 || {
  echo "ImageMagick 7 (magick) is required" >&2
  exit 1
}

if [[ "${requested_model,,}" == auto ]]; then
  requested_model="$($detector)"
fi
load_anime_profile "$requested_model"
validate_anime_profile_assets

mapfile -t raw_metadata < <(magick identify -format '%w %h %X %Y %[opaque]\n' "$input")
errors=0
for index in "${!raw_metadata[@]}"; do
  read -r width height offset_x offset_y opaque <<< "${raw_metadata[index]}"
  if [[ "$width" != "$canvas_width" || "$height" != "$canvas_height" || \
        ( "$offset_x" != 0 && "$offset_x" != +0 ) || \
        ( "$offset_y" != 0 && "$offset_y" != +0 ) ]]; then
    echo "Frame $index is not a full ${canvas_width}x${canvas_height}+0+0 frame: ${raw_metadata[index]}" >&2
    errors=$((errors + 1))
  fi
  if [[ "$opaque" != True ]]; then
    echo "Frame $index contains transparency" >&2
    errors=$((errors + 1))
  fi
done

task_tmp="$(mktemp -d /tmp/asus-anime-validate.XXXXXX)"
trap 'rm -rf "$task_tmp"' EXIT
magick "$input" -coalesce "$task_tmp/frame-%05d.png"
frames=("$task_tmp"/frame-*.png)

for index in "${!frames[@]}"; do
  leak="$(magick "${frames[index]}" \( "$mask" -negate \) \
    -compose multiply -composite -format '%[fx:mean*w*h]' info:)"
  if ! awk -v value="$leak" 'BEGIN {exit !(value == 0)}'; then
    echo "Frame $index illuminates coordinates outside the $model mask (energy: $leak)" >&2
    errors=$((errors + 1))
  fi

  gray_difference="$(magick compare -metric AE "${frames[index]}" \
    \( "${frames[index]}" -colorspace gray \) null: 2>&1 || true)"
  gray_difference="${gray_difference%% *}"
  if [[ "$gray_difference" != 0 ]]; then
    echo "Frame $index contains non-grayscale pixels" >&2
    errors=$((errors + 1))
  fi
done

if ((errors > 0)); then
  echo "FAIL: $errors $model validation error(s) in $input" >&2
  exit 1
fi

echo "PASS: ${#frames[@]} opaque ${canvas_width}x${canvas_height} grayscale frame(s), $active_led_count-coordinate $model mask, no outside illumination"
