# Adding an AniMe Matrix model

Add a profile only from the model's installed or current upstream `asusctl`
mapping. A visually similar lid or matching logical canvas does not establish
that two models share coordinates.

## Profile contract

Create `profiles/<lowercase-model>.conf` with trusted shell assignments:

```bash
PROFILE_MODEL=MODEL
PROFILE_STATUS=candidate
CANVAS_WIDTH=WIDTH
CANVAS_HEIGHT=HEIGHT
ACTIVE_LED_COUNT=COUNT
MASK_RELATIVE_PATH=assets/masks/model-WIDTHxHEIGHT.png
GEOMETRY_REFERENCE=references/model-geometry.md
HARDWARE_VERIFICATION=
```

The generic helpers refuse any status other than `verified`. Keep a source-only
profile as `candidate` until the hardware checks below pass; then record the
tested board identifier in `HARDWARE_VERIFICATION` and change the status.

The mask must be a full-canvas, opaque grayscale PNG. White coordinates are
mapped LEDs and black coordinates are unavailable or decoder padding. Its white
pixel count must equal `ACTIVE_LED_COUNT` exactly.

## Derive the geometry

1. Confirm the board maps to a distinct `AnimeType` in `rog-anime` and that the
   installed `asusctl` and daemon agree on that type.
2. Record the logical image dimensions used by `pixel-gif`, not the visual
   width and height advertised for the physical lid.
3. Follow the type's diagonal/image conversion and enumerate every logical
   coordinate that contributes a byte to the device buffer.
4. Generate the binary mask from that enumeration. Do not scale, crop, or
   rename another model's mask.
5. Document row extents, padding, active count, a largest useful safe region,
   orientation, and the exact upstream source in the geometry reference.
6. Add or update the DMI match in `scripts/detect-anime-model.sh` only when the
   upstream classifier recognizes that board family.

The upstream implementation is authoritative:

- `rog-anime/src/usb.rs` for DMI classification
- `rog-anime/src/data.rs` for canvas dimensions and data lengths
- `rog-anime/src/diagonal.rs` and `image.rs` for coordinate conversion
- `rog-anime/tests/` for byte-level fixtures

## Offline checks

Run `scripts/list-anime-models.sh`, `bash -n` on every shell helper, and the
skill-creator quick validator. Use `--model MODEL` only for offline validation
when DMI is unavailable.

Exercise the generic renderer with opaque grayscale multi-frame input and check:

- canvas dimensions and frame delays are preserved
- no light survives outside the profile mask
- previews are exactly 10x the model canvas
- an unknown, missing, or candidate profile fails before writing output
- compatibility wrappers still match their generic equivalent

## Hardware verification

Display an ordered test sequence containing an all-off frame, the full mask,
single points at the apex and each extremity, horizontal and vertical bands, a
border, a diagonal stripe, and a slow one-pixel sweep. Verify on the exact board:

- orientation and mirroring
- row starts and ends
- gaps and padding
- the first and last mapped LED
- frame clearing, brightness levels, and timing

Correct the source-derived profile if the observed layout differs. Do not mark
the profile verified from a simulator or visual resemblance alone.
