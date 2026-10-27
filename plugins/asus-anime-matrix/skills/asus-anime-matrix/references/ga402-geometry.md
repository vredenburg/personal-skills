# Verified GA402 geometry

Use this reference only for GA402-family AniMe Matrix work. It was verified
against the `asusctl` GA402 packet mapping and the GA402RK hardware targeted by
the original workflow.

## Coordinate systems

- Hardware: 1,449 LEDs arranged across 61 staggered physical rows, with at most
  34 LEDs in a row. This is not a 34x61 rectangle.
- `asusctl anime pixel-gif`: a 74x39 logical allocation.
- Active logical bounding box: columns `0..63`, rows `0..38` (64x39).
- Padding: logical columns `64..73` never map to GA402 LEDs.

Official implementation references:

- [`AnimeType` DMI and dimensions](https://gitlab.com/asus-linux/asusctl/-/blob/main/rog-anime/src/data.rs)
- [GA402 packet-coordinate mapping](https://gitlab.com/asus-linux/asusctl/-/blob/main/rog-anime/src/diagonal.rs)
- [Physical LED geometry](https://gitlab.com/asus-linux/asusctl/-/blob/main/rog-anime/src/image.rs)
- [`pixel-gif` frame decoding](https://gitlab.com/asus-linux/asusctl/-/blob/main/rog-anime/src/gif.rs)

## Exact active mask

For zero-based logical coordinates `(x, y)`:

```text
y = 0..29: min_x = 33-y;       max_x = min(34+y, 63)
y = 30..38: min_x = abs(y-33); max_x = min(93-y, 63)
```

Every integer `x` from `min_x` through `max_x`, inclusive, is active. All other
coordinates must be black. The bundled `assets/masks/ga402-74x39.png` encodes
these 1,449 coordinates.

Representative row extents:

```text
y=0    x=33..34    2 active coordinates
y=10   x=23..44   22 active coordinates
y=20   x=13..54   42 active coordinates
y=29   x=4..63    60 active coordinates
y=30   x=3..63    61 active coordinates
y=31   x=2..62    61 active coordinates
y=32   x=1..61    61 active coordinates
y=33   x=0..60    61 active coordinates
y=38   x=5..55    51 active coordinates
```

The largest completely active axis-aligned rectangle is 40x20 at
`x=14..53, y=19..38`. Treat this as a safe core, not as the whole display.

## Composition guidance

- Centered characters suit the footprint. Put the visual apex near the narrow
  top and the body in the broad lower rows.
- For side-on figures, keep the face and torso in the safe core; align staffs,
  beams, hair, and capes with the sloped boundary.
- For skylines, keep the horizon in the wide lower rows, put the tallest tower
  under the apex, and move moons or stars into active upper coordinates.
- Rain, sparks, stars, and other expendable ambience may intentionally approach
  the mask edge. Important contours should not.
- Do not merely mask a full rectangular composition when roughly one fifth of
  its important artwork would disappear. Recompose foreground and ambience as
  separate layers when necessary.

## Decoder invariant

The diagonal GIF decoder allocates the model-sized matrix once and updates it
frame by frame. Pixels whose alpha is not fully opaque may be skipped, leaving
the prior brightness value in the matrix. Therefore final device frames must be
full-canvas and opaque, with explicit black wherever an LED should turn off.
