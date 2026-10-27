#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  play-adaptive-battery.sh --mascot NAME
  play-adaptive-battery.sh --mascot NAME --probe
  play-adaptive-battery.sh --mascot NAME --dry-run

Run a user-created adaptive battery mascot as a transient systemd user service. The
controller switches among six validated animation loops and survives terminal
closure. It shares the ordinary AniMe Matrix playback service, so only one
helper-managed animation owns the matrix at a time. No mascot packs are bundled.

Options:
  --mascot NAME  Required pack under assets/mascots/ (create it before playback)
  --probe       Print the state selected from the current battery, without playback
  --dry-run     Validate everything and print the launch command, without playback
  -h, --help    Show this help
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
controller="$script_dir/adaptive-battery-controller.py"
unit=asus-anime-matrix-playback.service
mode=play
mascot=

while (($#)); do
  case "$1" in
    --probe|--dry-run)
      [[ "$mode" == play ]] || {
        echo "Choose only one of --probe or --dry-run" >&2
        exit 2
      }
      mode="${1#--}"
      shift
      ;;
    --mascot)
      mascot="${2:?Missing value for --mascot}"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$mascot" ]] || { echo "--mascot NAME is required; no mascot packs are bundled" >&2; exit 2; }
[[ "$mascot" =~ ^[a-z0-9-]+$ ]] || {
  echo "--mascot must contain only lowercase letters, digits, and hyphens" >&2
  exit 2
}
manifest="$script_dir/../assets/mascots/$mascot/manifest.json"

[[ -x "$controller" ]] || { echo "Controller is not executable: $controller" >&2; exit 1; }
[[ -f "$manifest" ]] || { echo "Mascot manifest not found: $manifest" >&2; exit 1; }

if [[ "$mode" == probe ]]; then
  exec "$controller" --manifest "$manifest" --probe
fi

"$controller" --manifest "$manifest" --check

systemd_run="$(command -v systemd-run || true)"
[[ -n "$systemd_run" ]] || { echo "systemd-run is required" >&2; exit 1; }

launch=(
  "$systemd_run"
  --user
  "--unit=$unit"
  --collect
  --expand-environment=no
  --property=Restart=always
  --property=RestartSec=3s
  --property=TimeoutStopSec=5s
  "--description=Adaptive ${mascot^} AniMe Matrix battery mascot"
  --
  "$controller"
  --manifest
  "$manifest"
)

if [[ "$mode" == dry-run ]]; then
  printf 'Launch:'
  printf ' %q' "${launch[@]}"
  printf '\n'
  exit 0
fi

command -v systemctl >/dev/null 2>&1 || { echo "systemctl is required" >&2; exit 1; }
systemctl --user show-environment >/dev/null 2>&1 || {
  echo "Unable to reach the systemd user manager" >&2
  exit 1
}

# Validation completed above. Now replace only the shared helper-owned unit.
load_state="$(systemctl --user show "$unit" --property=LoadState --value 2>/dev/null || true)"
if [[ -n "$load_state" && "$load_state" != not-found ]]; then
  systemctl --user stop "$unit" >/dev/null
  systemctl --user reset-failed "$unit" >/dev/null 2>&1 || true
  for _ in {1..20}; do
    load_state="$(systemctl --user show "$unit" --property=LoadState --value 2>/dev/null || true)"
    [[ -z "$load_state" || "$load_state" == not-found ]] && break
    sleep 0.1
  done
  if [[ -n "$load_state" && "$load_state" != not-found ]]; then
    echo "Previous $unit did not unload; adaptive playback was not started" >&2
    exit 1
  fi
fi

"${launch[@]}"
state="$(systemctl --user is-active "$unit" 2>/dev/null || true)"
if [[ "$state" != active && "$state" != activating ]]; then
  systemctl --user status --no-pager "$unit" >&2 || true
  echo "Adaptive AniMe Matrix playback did not remain active" >&2
  exit 1
fi

echo "Adaptive mascot: ${mascot^}"
echo "Service: $unit"
echo "Stop with: $script_dir/play-anime-gif.sh --stop"
