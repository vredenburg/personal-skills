#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  play-anime-gif.sh --path ANIMATION.gif [--bright 0.0-1.0] [--loops COUNT]
  play-anime-gif.sh --status
  play-anime-gif.sh --stop

Run validated AniMe Matrix playback as a transient systemd user service so it
survives terminal closure. Infinite playback is the default. Starting a new
animation replaces only the service managed by this helper.

Options:
  --path PATH       Device-ready GIF to validate and play
  --bright VALUE    Optional asusctl brightness from 0.0 through 1.0
  --loops COUNT     Loop count; 0 means infinite (default: 0)
  --status          Show playback service status
  --stop            Stop playback managed by this helper
  --dry-run         Validate and print the launch command without changing state
  -h, --help        Show this help
EOF
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
validator="$script_dir/validate-anime-gif.sh"
unit=asus-anime-matrix-playback.service
action=play
path=""
brightness=""
loops=0
dry_run=false
action_was_set=false

while (($#)); do
  case "$1" in
    --path) path="${2:?Missing value for --path}"; shift 2 ;;
    --bright) brightness="${2:?Missing value for --bright}"; shift 2 ;;
    --loops) loops="${2:?Missing value for --loops}"; shift 2 ;;
    --status|--stop)
      if [[ "$action_was_set" == true ]]; then
        echo "Choose only one of --status or --stop" >&2
        exit 2
      fi
      action="${1#--}"
      action_was_set=true
      shift
      ;;
    --dry-run) dry_run=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

command -v systemctl >/dev/null 2>&1 || {
  echo "systemctl is required" >&2
  exit 1
}

if [[ "$action" != play ]]; then
  [[ -z "$path" && -z "$brightness" && "$loops" == 0 && "$dry_run" == false ]] || {
    echo "Playback options cannot be combined with --$action" >&2
    exit 2
  }
  systemctl --user show-environment >/dev/null 2>&1 || {
    echo "Unable to reach the systemd user manager" >&2
    exit 1
  }

  if [[ "$action" == status ]]; then
    exec systemctl --user status --no-pager "$unit"
  fi

  load_state="$(systemctl --user show "$unit" --property=LoadState --value 2>/dev/null || true)"
  if [[ -z "$load_state" || "$load_state" == not-found ]]; then
    echo "No AniMe Matrix playback service is running"
    exit 0
  fi
  systemctl --user stop "$unit"
  echo "Stopped AniMe Matrix playback"
  exit 0
fi

[[ -n "$path" ]] || {
  echo "--path is required for playback" >&2
  usage >&2
  exit 2
}
[[ "$loops" =~ ^[0-9]+$ ]] || {
  echo "--loops must be a non-negative integer" >&2
  exit 2
}
if [[ -n "$brightness" ]]; then
  [[ "$brightness" =~ ^([0-9]+([.][0-9]+)?|[.][0-9]+)$ ]] || {
    echo "--bright must be a number from 0.0 through 1.0" >&2
    exit 2
  }
  awk -v value="$brightness" 'BEGIN {exit !(value >= 0 && value <= 1)}' || {
    echo "--bright must be a number from 0.0 through 1.0" >&2
    exit 2
  }
fi

[[ -f "$path" ]] || { echo "Animation not found: $path" >&2; exit 1; }
path="$(realpath -e "$path")"
"$validator" "$path" >/dev/null

systemd_run="$(command -v systemd-run || true)"
asusctl_bin="$(command -v asusctl || true)"
[[ -n "$systemd_run" ]] || { echo "systemd-run is required" >&2; exit 1; }
[[ -n "$asusctl_bin" ]] || { echo "asusctl is required" >&2; exit 1; }

restart_policy=on-failure
[[ "$loops" == 0 ]] && restart_policy=always

launch=(
  "$systemd_run"
  --user
  "--unit=$unit"
  --collect
  --expand-environment=no
  "--property=Restart=$restart_policy"
  --property=RestartSec=3s
  --property=TimeoutStopSec=5s
  '--description=ASUS AniMe Matrix playback'
  --
  "$asusctl_bin"
  anime
  pixel-gif
  --path
  "$path"
  --loops
  "$loops"
)
[[ -z "$brightness" ]] || launch+=(--bright "$brightness")

if [[ "$dry_run" == true ]]; then
  echo "Validated: $path"
  printf 'Launch:'
  printf ' %q' "${launch[@]}"
  printf '\n'
  exit 0
fi

systemctl --user show-environment >/dev/null 2>&1 || {
  echo "Unable to reach the systemd user manager" >&2
  exit 1
}

# Validate the replacement first, then touch only the helper's fixed unit.
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
    echo "Previous $unit did not unload; playback was not replaced" >&2
    exit 1
  fi
fi

"${launch[@]}"
state="$(systemctl --user is-active "$unit" 2>/dev/null || true)"
if [[ "$state" != active && "$state" != activating ]]; then
  systemctl --user status --no-pager "$unit" >&2 || true
  echo "AniMe Matrix playback did not remain active" >&2
  exit 1
fi

echo "Playing: $path"
echo "Service: $unit"
echo "Stop with: $script_dir/play-anime-gif.sh --stop"
