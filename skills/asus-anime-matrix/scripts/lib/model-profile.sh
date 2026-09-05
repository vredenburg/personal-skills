#!/usr/bin/env bash

# Shared profile loading and validation for AniMe Matrix helpers.

normalize_anime_model() {
  local requested="${1:?model is required}"
  printf '%s\n' "${requested^^}"
}

available_anime_profiles() {
  local profile
  local found=false

  for profile in "$profiles_dir"/*.conf; do
    [[ -f "$profile" ]] || continue
    found=true
    basename "${profile%.conf}" | tr '[:lower:]' '[:upper:]'
  done

  if [[ "$found" == false ]]; then
    printf '%s\n' none
  fi
}

load_anime_profile() {
  local requested="${1:?model is required}"
  local normalized
  local profile_path
  local required

  normalized="$(normalize_anime_model "$requested")"
  profile_path="$profiles_dir/${normalized,,}.conf"
  if [[ ! -f "$profile_path" ]]; then
    echo "No installed AniMe Matrix profile for $normalized" >&2
    echo "Available profiles: $(available_anime_profiles | paste -sd, -)" >&2
    return 3
  fi

  unset PROFILE_MODEL PROFILE_STATUS CANVAS_WIDTH CANVAS_HEIGHT
  unset ACTIVE_LED_COUNT MASK_RELATIVE_PATH GEOMETRY_REFERENCE
  unset HARDWARE_VERIFICATION
  # Profiles are trusted, skill-owned declarative shell assignments.
  # shellcheck disable=SC1090
  source "$profile_path"

  for required in PROFILE_MODEL PROFILE_STATUS CANVAS_WIDTH CANVAS_HEIGHT \
    ACTIVE_LED_COUNT MASK_RELATIVE_PATH GEOMETRY_REFERENCE; do
    if [[ -z "${!required:-}" ]]; then
      echo "Profile $profile_path is missing $required" >&2
      return 3
    fi
  done

  if [[ "$PROFILE_MODEL" != "$normalized" ]]; then
    echo "Profile identity mismatch: requested $normalized, found $PROFILE_MODEL" >&2
    return 3
  fi
  if [[ "$PROFILE_STATUS" != verified ]]; then
    echo "Profile $PROFILE_MODEL is not hardware-verified (status: $PROFILE_STATUS)" >&2
    return 3
  fi
  if [[ ! "$CANVAS_WIDTH" =~ ^[1-9][0-9]*$ || \
        ! "$CANVAS_HEIGHT" =~ ^[1-9][0-9]*$ || \
        ! "$ACTIVE_LED_COUNT" =~ ^[1-9][0-9]*$ ]]; then
    echo "Profile $PROFILE_MODEL contains invalid numeric geometry" >&2
    return 3
  fi
  if [[ "$MASK_RELATIVE_PATH" == /* || "$MASK_RELATIVE_PATH" == *..* || \
        "$GEOMETRY_REFERENCE" == /* || "$GEOMETRY_REFERENCE" == *..* ]]; then
    echo "Profile $PROFILE_MODEL must use skill-relative resource paths" >&2
    return 3
  fi

  model="$PROFILE_MODEL"
  canvas_width="$CANVAS_WIDTH"
  canvas_height="$CANVAS_HEIGHT"
  active_led_count="$ACTIVE_LED_COUNT"
  mask="$skill_dir/$MASK_RELATIVE_PATH"
  geometry_reference="$skill_dir/$GEOMETRY_REFERENCE"
  profile_file="$profile_path"
}

validate_anime_profile_assets() {
  local mask_width mask_height mask_opaque mask_pixels
  local mask_colors mask_min mask_max gray_difference

  [[ -f "$mask" ]] || {
    echo "$model mask not found: $mask" >&2
    return 3
  }
  [[ -f "$geometry_reference" ]] || {
    echo "$model geometry reference not found: $geometry_reference" >&2
    return 3
  }

  read -r mask_width mask_height mask_opaque < <(
    magick identify -format '%w %h %[opaque]\n' "$mask"
  )
  if [[ "$mask_width" != "$canvas_width" || \
        "$mask_height" != "$canvas_height" || \
        "$mask_opaque" != True ]]; then
    echo "Invalid $model mask geometry: ${mask_width}x${mask_height}, opaque=$mask_opaque; expected ${canvas_width}x${canvas_height}, opaque=True" >&2
    return 3
  fi

  gray_difference="$(magick compare -metric AE "$mask" \
    \( "$mask" -colorspace gray \) null: 2>&1 || true)"
  gray_difference="${gray_difference%% *}"
  if [[ "$gray_difference" != 0 ]]; then
    echo "$model mask contains non-grayscale pixels" >&2
    return 3
  fi

  read -r mask_colors mask_min mask_max < <(
    magick "$mask" -format '%k %[fx:minima] %[fx:maxima]\n' info:
  )
  if [[ "$mask_colors" != 2 || "$mask_min" != 0 || "$mask_max" != 1 ]]; then
    echo "$model mask must contain only opaque black and white pixels" >&2
    return 3
  fi

  mask_pixels="$(magick "$mask" -threshold 50% \
    -format '%[fx:round(mean*w*h)]' info:)"
  if [[ "$mask_pixels" != "$active_led_count" ]]; then
    echo "Invalid $model mask: expected $active_led_count active coordinates, found $mask_pixels" >&2
    return 3
  fi
}
