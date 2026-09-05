---
name: asus-anime-matrix
description: Create, adapt, preview, validate, and optionally play ASUS AniMe Matrix image/GIF animations and reactive battery mascots with verified, model-specific LED profiles. Use for asusctl anime pixel-gif, AniMe Matrix artwork, clipped corners, model geometry, adaptive displays, or custom laptop-lid animations. Never substitute one model's mask for another.
---

# ASUS AniMe Matrix

Build artwork for the LEDs that actually exist, not for an assumed rectangular
canvas. Preserve the user's originals and make output filenames model-specific.

## Model profiles

Run `scripts/detect-anime-model.sh` before choosing geometry, then confirm the
detected model appears as `verified` in `scripts/list-anime-models.sh`. Rendering
and validation load canvas dimensions, active count, mask, and geometry reference
from `profiles/<model>.conf`. Detection alone does not mean a profile is installed.

Fail closed when a model has no verified profile. Never resize, reinterpret, or
override a different model's mask. For adding support, read
[`references/adding-models.md`](references/adding-models.md).

For GA402 geometry or composition decisions, read
[`references/ga402-geometry.md`](references/ga402-geometry.md).

## Workflow

1. Inspect the input animation and any higher-resolution sources. Prefer
   re-rendering clean source art to shrinking an already pixelated GIF.
2. Decide composition from the exact footprint. Keep faces, silhouettes, and
   other important details in the broad central/lower region; allow only
   expendable particles, rain, or ambience near clipped edges.
3. Keep every animation frame full-canvas and opaque. Use opaque black for off
   pixels; transparency can retain values from a preceding `pixel-gif` frame.
4. For a straightforward fit, run `scripts/render-anime-gif.sh`. It preserves
   frame delays, loads the selected model profile, applies its exact mask, and
   creates an LED-dot preview. More complex foreground/background recomposition
   may be done separately, then passed through the renderer at the profile's
   full canvas size and offset `0,0`.
5. Run `scripts/validate-anime-gif.sh` on every final device GIF. Also inspect
   the preview visually; structural validation does not prove recognizability.
   A contact sheet may be generated temporarily for internal review, but do not
   retain or report it unless the user asks for diagnostic or source material.
6. Do not start, replace, or stop playback unless the user explicitly asks for
   that live-device change. Creating an asset does not authorize displaying it.
   For authorized playback, use `scripts/play-anime-gif.sh` rather than invoking
   `asusctl anime pixel-gif` directly; the helper validates the GIF and runs it
   as a transient systemd user service so terminal closure does not stop it.
7. By default, retain exactly two deliverables: the device-ready GIF and its
   10x LED-dot preview. Keep source sheets, extracted frames, prompts, contact
   sheets, and build-specific helpers temporary unless the user explicitly asks
   for editable sources or reproducibility artifacts.

For a battery-reactive mascot, read
[`references/adaptive-battery.md`](references/adaptive-battery.md). Adaptive packs
may retain their validated per-state runtime loops under `assets/mascots/`; these
are generated pack assets and are not included in the source collection. No
mascot packs are bundled; create a pack before using the adaptive helpers. Building or
previewing a reactive pack still does not authorize enabling it on the matrix.

## Helpers

Detect the current laptop model:

```bash
scripts/detect-anime-model.sh
```

Fit an existing animation into an intentionally chosen composition box:

```bash
scripts/render-anime-gif.sh \
  --input source.gif \
  --output scene-ga402-74x39.gif \
  --size 42x28 \
  --offset 11,11 \
  --threshold 25 \
  --preview scene-ga402-preview.gif
```

The renderer refuses to guess a placement when input dimensions differ from the
selected model canvas. Choose `--size` and `--offset` after visual inspection.
It preserves aspect ratio by default; use `--stretch` only when deliberate
distortion is acceptable.

Validate the device GIF:

```bash
scripts/validate-anime-gif.sh scene-ga402-74x39.gif
```

After an explicit request to display a validated animation, launch it independently
of the terminal:

```bash
scripts/play-anime-gif.sh --path scene-ga402-74x39.gif
```

Use `--status` or `--stop` when the user requests those actions. Starting a new
animation replaces only the helper-owned `asus-anime-matrix-playback.service`.
Infinite looping is the default; finite `--loops` playback is not restarted after
successful completion. The transient service survives terminal closure but not a
reboot. If sandboxing blocks access to the user service manager, retry the exact
authorized helper invocation with the required elevation rather than falling back
to foreground playback.

The legacy `render-ga402-gif.sh` and `validate-ga402-gif.sh` names remain as
compatibility wrappers. Use `--model MODEL` only for offline work where DMI is
unavailable. Do not use it to override a known different laptop model.

## Output expectations

- exactly two retained outputs by default: a versioned, model-labelled device
  GIF and its enlarged 10x LED-dot preview
- for an adaptive pack, keep any state loops internal and report only the
  showcase device GIF and 10x preview as deliverables
- no silently overwritten source and no retained intermediates unless requested
- exact profile canvas with no illuminated samples outside its verified mask
- full opaque grayscale frames and preserved timing
- concise report containing the two saved paths and whether anything was
  displayed live
