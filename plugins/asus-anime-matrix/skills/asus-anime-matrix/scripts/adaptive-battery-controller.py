#!/usr/bin/env python3

import argparse
import json
import shutil
import signal
import subprocess
import sys
import time
from pathlib import Path


STATES = ("critical", "low", "medium", "healthy", "full", "charging")
BANDS = ("critical", "low", "medium", "healthy", "full")


class ConfigurationError(RuntimeError):
    pass


def read_text(path):
    return path.read_text(encoding="utf-8").strip()


def load_manifest(path):
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ConfigurationError(f"Unable to load manifest {path}: {error}") from error

    required = {
        "mascot", "model", "poll_seconds", "minimum_dwell_seconds",
        "hysteresis_percent", "thresholds", "brightness", "animations",
    }
    missing = sorted(required - data.keys())
    if missing:
        raise ConfigurationError(f"Manifest is missing: {', '.join(missing)}")
    if not isinstance(data["animations"], dict) or set(data["animations"]) != set(STATES):
        raise ConfigurationError("Manifest must define exactly the six adaptive states")
    if not isinstance(data["mascot"], str) or not data["mascot"].strip():
        raise ConfigurationError("mascot must be a non-empty string")
    if not isinstance(data["model"], str) or not data["model"].strip():
        raise ConfigurationError("model must be a non-empty string")
    if not all(isinstance(path, str) and path for path in data["animations"].values()):
        raise ConfigurationError("Animation paths must be non-empty strings")

    thresholds = data["thresholds"]
    names = ("critical", "low", "medium", "full", "charging_full")
    if any(name not in thresholds for name in names):
        raise ConfigurationError("Manifest has incomplete battery thresholds")
    values = [thresholds[name] for name in names]
    if not all(isinstance(value, int) and not isinstance(value, bool) for value in values):
        raise ConfigurationError("Battery thresholds must be integers")
    if not (0 < thresholds["critical"] < thresholds["low"] <
            thresholds["medium"] < thresholds["full"] <=
            thresholds["charging_full"] <= 100):
        raise ConfigurationError("Battery thresholds are not strictly ordered")
    if not isinstance(data["poll_seconds"], (int, float)) or data["poll_seconds"] < 1:
        raise ConfigurationError("poll_seconds must be at least 1")
    if (not isinstance(data["minimum_dwell_seconds"], (int, float)) or
            data["minimum_dwell_seconds"] < 0):
        raise ConfigurationError("minimum_dwell_seconds must be non-negative")
    if (not isinstance(data["hysteresis_percent"], (int, float)) or
            not 0 <= data["hysteresis_percent"] <= 10):
        raise ConfigurationError("hysteresis_percent must be from 0 through 10")
    brightness = data["brightness"]
    if brightness is not None:
        if (not isinstance(brightness, (int, float)) or
                isinstance(brightness, bool) or not 0 <= brightness <= 1):
            raise ConfigurationError("brightness must be null or from 0 through 1")
    return data


def detect_model(skill_dir):
    detector = skill_dir / "scripts" / "detect-anime-model.sh"
    result = subprocess.run([str(detector)], check=False, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode != 0:
        raise ConfigurationError(result.stderr.strip() or "Unable to detect AniMe model")
    return result.stdout.strip()


def resolve_animations(manifest_path, manifest):
    animations = {}
    for state, relative_path in manifest["animations"].items():
        path = (manifest_path.parent / relative_path).resolve()
        if not path.is_file():
            raise ConfigurationError(f"Missing {state} animation: {path}")
        animations[state] = path
    return animations


def validate_animations(skill_dir, model, animations):
    validator = skill_dir / "scripts" / "validate-anime-gif.sh"
    for state in STATES:
        result = subprocess.run(
            [str(validator), "--model", model, str(animations[state])],
            check=False, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        if result.returncode != 0:
            message = result.stderr.strip() or result.stdout.strip()
            raise ConfigurationError(f"Invalid {state} animation: {message}")


def find_system_battery():
    candidates = []
    for supply in Path("/sys/class/power_supply").glob("*"):
        try:
            if read_text(supply / "type").lower() != "battery":
                continue
            if not (supply / "capacity").is_file() or not (supply / "status").is_file():
                continue
            scope_path = supply / "scope"
            scope = read_text(scope_path).lower() if scope_path.is_file() else "system"
        except OSError:
            continue
        # Bluetooth mice, keyboards, and similar peripherals may expose a
        # power_supply entry. Never use those as the laptop's battery.
        if scope == "device":
            continue
        score = 0
        if supply.name.upper().startswith("BAT"):
            score -= 20
        candidates.append((score, supply.name, supply))
    if not candidates:
        raise ConfigurationError("No system battery with capacity and status was found")
    return min(candidates)[2]


def find_mains_supply():
    candidates = []
    for supply in Path("/sys/class/power_supply").glob("*"):
        try:
            supply_type = read_text(supply / "type").lower()
        except OSError:
            continue
        if supply_type in {"mains", "usb", "usb_c", "usb_pd"} and (supply / "online").is_file():
            score = 0 if supply.name.upper().startswith("AC") else 10
            candidates.append((score, supply.name, supply))
    return min(candidates)[2] if candidates else None


def read_power_state(battery, mains):
    try:
        capacity = int(read_text(battery / "capacity"))
        status = read_text(battery / "status")
        online = int(read_text(mains / "online")) if mains else None
    except (OSError, ValueError) as error:
        raise RuntimeError(f"Unable to read power state: {error}") from error
    if not 0 <= capacity <= 100:
        raise RuntimeError(f"Invalid battery capacity: {capacity}")
    return capacity, status, online


def raw_band(capacity, thresholds):
    if capacity < thresholds["critical"]:
        return "critical"
    if capacity < thresholds["low"]:
        return "low"
    if capacity < thresholds["medium"]:
        return "medium"
    if capacity < thresholds["full"]:
        return "healthy"
    return "full"


def band_with_hysteresis(capacity, thresholds, hysteresis, previous):
    if previous not in BANDS:
        return raw_band(capacity, thresholds)
    index = BANDS.index(previous)
    lower_bounds = (0, thresholds["critical"], thresholds["low"],
                    thresholds["medium"], thresholds["full"])
    upper_bounds = (thresholds["critical"], thresholds["low"],
                    thresholds["medium"], thresholds["full"], 101)
    lower = lower_bounds[index] - (hysteresis if index > 0 else 0)
    upper = upper_bounds[index] + (hysteresis if index < len(BANDS) - 1 else 0)
    if lower <= capacity < upper:
        return previous
    return raw_band(capacity, thresholds)


def choose_state(capacity, status, manifest, previous):
    thresholds = manifest["thresholds"]
    if status.lower() == "charging" and capacity < thresholds["charging_full"]:
        return "charging"
    if status.lower() == "full":
        return "full"
    return band_with_hysteresis(
        capacity, thresholds, manifest["hysteresis_percent"], previous,
    )


class Player:
    def __init__(self, asusctl, animations, brightness):
        self.asusctl = asusctl
        self.animations = animations
        self.brightness = brightness
        self.process = None

    def stop(self):
        if self.process is None:
            return
        if self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait(timeout=2)
        self.process = None

    def start(self, state):
        self.stop()
        command = [self.asusctl, "anime", "pixel-gif", "--path",
                   str(self.animations[state]), "--loops", "0"]
        if self.brightness is not None:
            command.extend(("--bright", str(self.brightness)))
        self.process = subprocess.Popen(command)
        time.sleep(0.2)
        return_code = self.process.poll()
        if return_code is not None:
            self.process = None
            raise RuntimeError(f"asusctl exited immediately with status {return_code}")

    def ensure_running(self):
        if self.process is not None and self.process.poll() is not None:
            return_code = self.process.returncode
            self.process = None
            raise RuntimeError(f"asusctl playback exited with status {return_code}")


def prepare(manifest_path):
    skill_dir = Path(__file__).resolve().parent.parent
    manifest = load_manifest(manifest_path)
    model = detect_model(skill_dir)
    if model != manifest["model"]:
        raise ConfigurationError(
            f"{manifest['mascot']} assets target {manifest['model']}; detected {model}"
        )
    animations = resolve_animations(manifest_path, manifest)
    validate_animations(skill_dir, model, animations)
    battery = find_system_battery()
    mains = find_mains_supply()
    asusctl = shutil.which("asusctl")
    if not asusctl:
        raise ConfigurationError("asusctl is required")
    return manifest, model, animations, battery, mains, asusctl


def run_controller(manifest, animations, battery, mains, asusctl):
    stop_requested = False

    def request_stop(_signum, _frame):
        nonlocal stop_requested
        stop_requested = True

    signal.signal(signal.SIGTERM, request_stop)
    signal.signal(signal.SIGINT, request_stop)
    player = Player(asusctl, animations, manifest["brightness"])
    current = None
    candidate = None
    candidate_since = None
    previous_status = None

    try:
        while not stop_requested:
            player.ensure_running()
            capacity, status, online = read_power_state(battery, mains)
            target = choose_state(capacity, status, manifest, current)
            now = time.monotonic()
            power_transition = previous_status is not None and status != previous_status
            immediate = (current is None or "charging" in {current, target} or
                         target == "critical" or power_transition)

            if target == current:
                candidate = None
                candidate_since = None
            elif immediate:
                player.start(target)
                current = target
                candidate = None
                candidate_since = None
                print(f"{manifest['mascot']} state={current} battery={capacity}% status={status} ac={online}",
                      flush=True)
            elif candidate != target:
                candidate = target
                candidate_since = now
            elif now - candidate_since >= manifest["minimum_dwell_seconds"]:
                player.start(target)
                current = target
                candidate = None
                candidate_since = None
                print(f"{manifest['mascot']} state={current} battery={capacity}% status={status} ac={online}",
                      flush=True)

            previous_status = status
            deadline = time.monotonic() + manifest["poll_seconds"]
            while not stop_requested and time.monotonic() < deadline:
                time.sleep(min(0.25, max(0.0, deadline - time.monotonic())))
    finally:
        player.stop()


def main():
    parser = argparse.ArgumentParser(description="Adaptive AniMe Matrix battery mascot controller")
    parser.add_argument("--manifest", type=Path, required=True,
                        help="path to a user-created mascot manifest; no packs are bundled")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="validate configuration and assets")
    mode.add_argument("--probe", action="store_true", help="print the currently selected state")
    args = parser.parse_args()

    try:
        manifest, model, animations, battery, mains, asusctl = prepare(args.manifest.resolve())
        if args.check:
            mains_name = mains.name if mains else "none"
            print(f"PASS: {manifest['mascot']} {model}, six validated states, battery={battery.name}, mains={mains_name}")
            return 0
        if args.probe:
            capacity, status, online = read_power_state(battery, mains)
            state = choose_state(capacity, status, manifest, None)
            print(f"state={state} battery={capacity}% status={status} ac={online}")
            return 0
        run_controller(manifest, animations, battery, mains, asusctl)
        return 0
    except (ConfigurationError, RuntimeError) as error:
        print(f"Adaptive battery mascot error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
