# Adaptive battery mascots

No mascot packs are bundled. Create six model-correct state loops and a manifest
before using the adaptive helpers. Keep generated packs under
`assets/mascots/<name>/` in the selected skill installation; the source collection
ignores this directory. Pack names use lowercase letters, digits, and hyphens.

## State model

The example manifest below uses these settings. Design each state's artwork to
make its battery level recognizable:

| State | Selection |
| --- | --- |
| `charging` | Battery reports charging below 98% |
| `full` | Battery reports full or is at least 90%, unless charging applies |
| `healthy` | 55–89% |
| `medium` | 30–54% |
| `low` | 15–29% |
| `critical` | Below 15% |

Three percentage points of hysteresis prevent threshold chatter. Non-power-mode
changes must remain stable for 20 seconds before switching. Charging transitions
and entry into the critical state are immediate. The controller samples every
five seconds and does not use the network.

Each pack stores its settings and state paths in
`assets/mascots/<name>/manifest.json`. Runtime GIFs are validated before the
controller starts. The controller is pack-independent; do not hard-code a
mascot name in its state logic.

## Manifest format

Create `assets/mascots/my-mascot/manifest.json` using this structure, replacing
the display name and animation paths with those of the newly created pack:

```json
{
  "mascot": "My mascot",
  "model": "GA402",
  "poll_seconds": 5,
  "minimum_dwell_seconds": 20,
  "hysteresis_percent": 3,
  "thresholds": {
    "critical": 15,
    "low": 30,
    "medium": 55,
    "full": 90,
    "charging_full": 98
  },
  "brightness": null,
  "animations": {
    "critical": "ga402/critical.gif",
    "low": "ga402/low.gif",
    "medium": "ga402/medium.gif",
    "healthy": "ga402/healthy.gif",
    "full": "ga402/full.gif",
    "charging": "ga402/charging.gif"
  }
}
```

All fields shown are required. Animation paths are relative to the manifest and
must define exactly these six states. The model must match detected hardware and
have a verified profile; validate every loop against that profile. Thresholds
are integer percentages ordered as
`0 < critical < low < medium < full <= charging_full <= 100`.
`poll_seconds` is at least 1, `minimum_dwell_seconds` is non-negative, and
`hysteresis_percent` is between 0 and 10. `brightness` is `null` to leave it
unspecified, or a number from 0 to 1.

The controller requires an explicit manifest, including for validation:

```bash
scripts/adaptive-battery-controller.py --manifest assets/mascots/my-mascot/manifest.json --check
```

## Playback ownership

`scripts/play-adaptive-battery.sh` runs the controller in the same
`asus-anime-matrix-playback.service` used by ordinary playback. This guarantees
one owner of the matrix: starting a normal GIF replaces adaptive mode, and
starting adaptive mode replaces a normal GIF.

Creating or reviewing adaptive assets does not authorize enabling the controller.
After an explicit request, run:

```bash
scripts/play-adaptive-battery.sh --mascot my-mascot
```

Read-only checks do not change playback:

```bash
scripts/play-adaptive-battery.sh --mascot my-mascot --probe
scripts/play-adaptive-battery.sh --mascot my-mascot --dry-run
```

Use `scripts/play-anime-gif.sh --status` and `--stop` for the shared service.
The transient service survives terminal closure but not reboot. Its logs are
available through `journalctl --user -u asus-anime-matrix-playback.service`.
