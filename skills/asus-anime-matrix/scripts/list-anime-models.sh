#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$script_dir/.." && pwd)"
profiles_dir="$skill_dir/profiles"

found=false
for profile in "$profiles_dir"/*.conf; do
  [[ -f "$profile" ]] || continue
  found=true
  unset PROFILE_MODEL PROFILE_STATUS CANVAS_WIDTH CANVAS_HEIGHT
  unset ACTIVE_LED_COUNT HARDWARE_VERIFICATION
  # Profiles are trusted, skill-owned declarative shell assignments.
  # shellcheck disable=SC1090
  source "$profile"
  printf '%-8s %-10s %sx%s  %s LEDs' \
    "$PROFILE_MODEL" "$PROFILE_STATUS" "$CANVAS_WIDTH" "$CANVAS_HEIGHT" \
    "$ACTIVE_LED_COUNT"
  if [[ -n "${HARDWARE_VERIFICATION:-}" ]]; then
    printf '  verified on %s' "$HARDWARE_VERIFICATION"
  fi
  printf '\n'
done

if [[ "$found" == false ]]; then
  echo "No AniMe Matrix profiles installed" >&2
  exit 1
fi
