#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  render-anime-gif.sh --input INPUT --output OUTPUT [options]

Options:
  --model auto|MODEL        Detect from DMI by default
  --size WIDTHxHEIGHT       Required when input differs from the model canvas
  --offset X,Y              Placement of the composition box (default: 0,0)
  --stretch                 Fill the box without preserving aspect ratio
  --threshold PERCENT       Convert to bilevel after resizing (0..100)
  --default-delay CS        Delay for source frames whose delay is zero (default: 10)
  --loop COUNT              GIF loop count; 0 means infinite (default: 0)
  --preview PATH            Create a 10x LED-dot simulation GIF
  --contact PATH            Create an enlarged contact sheet
  --force                   Replace explicitly named outputs if they exist
  -h, --help                Show this help
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$script_dir/.." && pwd)"
profiles_dir="$skill_dir/profiles"
detector="$script_dir/detect-anime-model.sh"
# shellcheck source=scripts/lib/model-profile.sh
source "$script_dir/lib/model-profile.sh"

input=""
output=""
requested_model=auto
size=""
offset=0,0
stretch=false
threshold=""
default_delay=10
loop_count=0
preview=""
contact=""
force=false

while (($#)); do
  case "$1" in
    --input) input="${2:?Missing value for --input}"; shift 2 ;;
    --output) output="${2:?Missing value for --output}"; shift 2 ;;
    --model) requested_model="${2:?Missing value for --model}"; shift 2 ;;
    --size) size="${2:?Missing value for --size}"; shift 2 ;;
    --offset) offset="${2:?Missing value for --offset}"; shift 2 ;;
    --stretch) stretch=true; shift ;;
    --threshold) threshold="${2:?Missing value for --threshold}"; shift 2 ;;
    --default-delay) default_delay="${2:?Missing value for --default-delay}"; shift 2 ;;
    --loop) loop_count="${2:?Missing value for --loop}"; shift 2 ;;
    --preview) preview="${2:?Missing value for --preview}"; shift 2 ;;
    --contact) contact="${2:?Missing value for --contact}"; shift 2 ;;
    --force) force=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$input" && -n "$output" ]] || {
  echo "--input and --output are required" >&2
  usage >&2
  exit 2
}
[[ -f "$input" ]] || { echo "Input not found: $input" >&2; exit 1; }
command -v magick >/dev/null 2>&1 || {
  echo "ImageMagick 7 (magick) is required" >&2
  exit 1
}

if [[ "${requested_model,,}" == auto ]]; then
  requested_model="$($detector)"
fi
load_anime_profile "$requested_model"
validate_anime_profile_assets

case "$output" in
  *.gif|*.GIF) ;;
  *) echo "Device output must use a .gif extension: $output" >&2; exit 2 ;;
esac

read -r source_width source_height < <(
  magick identify -format '%w %h\n' "$input" | head -n 1
)
if [[ -z "$size" ]]; then
  if [[ "$source_width" == "$canvas_width" && \
        "$source_height" == "$canvas_height" ]]; then
    size="${canvas_width}x${canvas_height}"
  else
    echo "Input is ${source_width}x${source_height}; choose --size and --offset after inspecting the $model composition" >&2
    exit 2
  fi
fi

[[ "$size" =~ ^([0-9]+)x([0-9]+)$ ]] || {
  echo "Invalid --size (expected WIDTHxHEIGHT): $size" >&2
  exit 2
}
box_width="${BASH_REMATCH[1]}"
box_height="${BASH_REMATCH[2]}"

[[ "$offset" =~ ^([0-9]+),([0-9]+)$ ]] || {
  echo "Invalid --offset (expected X,Y): $offset" >&2
  exit 2
}
offset_x="${BASH_REMATCH[1]}"
offset_y="${BASH_REMATCH[2]}"

((box_width > 0 && box_height > 0)) || {
  echo "Composition dimensions must be positive" >&2
  exit 2
}
((offset_x + box_width <= canvas_width && \
  offset_y + box_height <= canvas_height)) || {
  echo "Composition box ${size}+${offset_x}+${offset_y} exceeds the $model ${canvas_width}x${canvas_height} canvas" >&2
  exit 2
}
[[ "$default_delay" =~ ^[0-9]+$ && "$loop_count" =~ ^[0-9]+$ ]] || {
  echo "--default-delay and --loop must be non-negative integers" >&2
  exit 2
}
if [[ -n "$threshold" ]]; then
  [[ "$threshold" =~ ^([0-9]+([.][0-9]+)?)$ ]] || {
    echo "--threshold must be a number from 0 through 100" >&2
    exit 2
  }
  awk -v value="$threshold" 'BEGIN {exit !(value >= 0 && value <= 100)}' || {
    echo "--threshold must be a number from 0 through 100" >&2
    exit 2
  }
fi

for target in "$output" "$preview" "$contact"; do
  [[ -z "$target" ]] && continue
  if [[ -e "$target" && "$force" != true ]]; then
    echo "Output already exists (use --force to replace it): $target" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$target")"
done

if [[ "$(realpath -m "$input")" == "$(realpath -m "$output")" ]]; then
  echo "Refusing to overwrite the input animation" >&2
  exit 1
fi

task_tmp="$(mktemp -d /tmp/asus-anime-matrix.XXXXXX)"
trap 'rm -rf "$task_tmp"' EXIT

magick "$input" -coalesce "$task_tmp/source-%05d.png"
source_frames=("$task_tmp"/source-*.png)
mapfile -t delays < <(magick identify -format '%T\n' "$input")

if [[ "${#source_frames[@]}" -ne "${#delays[@]}" ]]; then
  echo "Frame/delay count mismatch in $input" >&2
  exit 1
fi

resize_geometry="${box_width}x${box_height}"
[[ "$stretch" == true ]] && resize_geometry+='!'
threshold_args=()
[[ -n "$threshold" ]] && threshold_args=(-threshold "${threshold}%")
canvas_geometry="${canvas_width}x${canvas_height}"

rendered_frames=()
gif_args=()
for index in "${!source_frames[@]}"; do
  rendered="$(printf '%s/frame-%05d.png' "$task_tmp" "$index")"
  delay="${delays[index]}"
  [[ "$delay" -gt 0 ]] || delay="$default_delay"

  magick -size "$canvas_geometry" xc:black \
    \( "${source_frames[index]}" -background black -alpha remove -alpha off \
       -filter box -resize "$resize_geometry" -gravity center \
       -extent "${box_width}x${box_height}" -colorspace gray \
       "${threshold_args[@]}" \) \
    -gravity northwest -geometry "+${offset_x}+${offset_y}" -compose over -composite \
    "$mask" -compose multiply -composite -alpha off "$rendered"

  rendered_frames+=("$rendered")
  gif_args+=(-delay "$delay" "$rendered")
done

magick -dispose none "${gif_args[@]}" -loop "$loop_count" -colors 256 \
  "$task_tmp/device.gif"
mv "$task_tmp/device.gif" "$output"

if [[ -n "$preview" ]]; then
  preview_width=$((canvas_width * 10))
  preview_height=$((canvas_height * 10))
  preview_geometry="${preview_width}x${preview_height}"
  preview_args=()
  for index in "${!rendered_frames[@]}"; do
    preview_frame="$(printf '%s/preview-%05d.png' "$task_tmp" "$index")"
    delay="${delays[index]}"
    [[ "$delay" -gt 0 ]] || delay="$default_delay"

    magick \
      \( -size 10x10 xc:black -fill '#282828' -draw 'circle 5,5 5,2' \
         -write mpr:dim_dot +delete -size "$preview_geometry" tile:mpr:dim_dot \
         \( "$mask" -filter point -resize "${preview_geometry}!" \) \
         -compose multiply -composite \) \
      \( -size 10x10 xc:black -fill white -draw 'circle 5,5 5,2' \
         -write mpr:lit_dot +delete -size "$preview_geometry" tile:mpr:lit_dot \
         \( "${rendered_frames[index]}" -filter point -resize "${preview_geometry}!" \) \
         -compose multiply -composite \) \
      -compose screen -composite "$preview_frame"
    preview_args+=(-delay "$delay" "$preview_frame")
  done
  magick -dispose none "${preview_args[@]}" -loop "$loop_count" \
    "$task_tmp/preview.gif"
  mv "$task_tmp/preview.gif" "$preview"
fi

if [[ -n "$contact" ]]; then
  contact_width=$((canvas_width * 5))
  contact_height=$((canvas_height * 5))
  magick montage "${rendered_frames[@]}" -bordercolor '#303030' -border 1 \
    -filter point -resize "${contact_width}x${contact_height}!" \
    -tile 3x -geometry +6+6 "$task_tmp/contact.png"
  mv "$task_tmp/contact.png" "$contact"
fi

echo "Created: $output"
echo "Model: $model ($PROFILE_STATUS)"
[[ -z "$preview" ]] || echo "Preview: $preview"
[[ -z "$contact" ]] || echo "Contact sheet: $contact"
